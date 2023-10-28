source("r/header.R")

trait = read_rds("processed-data/trait.rds") |>
  summarize(
    site_type = first(site_type),
    `MAT~group('[', paste(phantom()*degree, 'C'), ']')` = first(tair_ann),
    `MAP~group('[', mm, ']')` = first(rf_ann),                
    `Solar~radiation~group('[', W~m^-2, ']')` = first(cl_sw_ann),
    `Vegetation~height~group('[', m, ']')` = first(veg_ht_ann),
    .by = "site_code"
  ) |>
  pivot_longer(`MAT~group('[', paste(phantom()*degree, 'C'), ']')`:`Vegetation~height~group('[', m, ']')`) |>
  mutate(habitat = factor(site_type, levels = c("montane", "coastal"))) |>
  select(-site_type)

df_stat = trait |>
  group_by(name) |>
  t_test(value ~ habitat, var.equal = FALSE) |>
  add_significance() |>
  full_join(
    trait |>
      summarize(y.position = max(value) * 1.1, .by = "name") |>
      mutate(xmin = 1, xmax = 2),
    by = join_by(name)
  )

gp = trait |>
  ggplot(aes(habitat, value, color = habitat)) +
  facet_wrap(. ~ name, scales = "free_y", labeller = label_parsed) +
  geom_jitter(width = 0.1, pch = 21) +
  stat_summary(position = position_nudge(x = 0.25), fun.data = mean_se) +
  stat_pvalue_manual(df_stat) +
  scale_color_manual(values = c("steelblue", "tomato")) +
  scale_y_continuous(expand = expansion(mult = 0.1)) +
  theme(legend.position = "none") 

plot_grid(gp, labels = "D")

ggsave("figures/habitat-climate.pdf", width = 5, height = 5)

write_rds(df_stat, "objects/habitat-climate-stats.rds")
