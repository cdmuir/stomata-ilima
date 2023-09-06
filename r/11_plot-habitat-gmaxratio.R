source("r/header.R")

site = read_rds("processed-data/site.rds")
gmaxratio_site = read_rds("objects/gmaxratio_site.rds")
gmaxratio_ind = read_rds("objects/gmaxratio_ind.rds")

# Prepare data for plotting habitat and site vs. gsmax-ratio
df_site = gmaxratio_site |>
  group_by(site_code) |>
  point_interval(gmax_ratio) |>
  left_join(site, by = join_by(site_code)) |>
  mutate(
    habitat = factor(site_type, levels = c("montane", "coastal")),
    site_code1 = fct_reorder(site_code, gmax_ratio)
  )

df_ind = gmaxratio_ind |>
  group_by(site_code, ind) |>
  point_interval(gmax_ratio) |>
  left_join(site, by = join_by(site_code)) |>
  mutate(
    habitat = factor(site_type, levels = c("montane", "coastal")),
    site_code1 = factor(site_code, levels(df_site$site_code1))
  )

ggplot(
  df_site,
  aes(
    habitat,
    gmax_ratio,
    ymin = .lower,
    ymax = .upper,
    color = habitat,
    group = site_code1
  )
) +
  geom_pointinterval(
    data = df_ind,
    position = position_jitterdodge(
      jitter.width = 0.1,
      dodge.width = 1,
      seed = 20230823
    ),
    linewidth = NA,
    alpha = 0.5
  ) +
  geom_pointinterval(
    position = position_dodgenudge(x = 0.1),
    size = 10,
    shape = 21,
    fill = "white",
    linewidth = 1
  ) +
  ylab(expression(italic(g)[paste("smax, ratio")])) +
  ylim(0, 0.5) +
  scale_color_manual(values = c("steelblue", "tomato"), guide = NULL)

ggsave("figures/habitat-gmaxratio.pdf", width = 4, height = 4)
