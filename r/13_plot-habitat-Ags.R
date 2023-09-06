source("r/header.R")

site = read_rds("processed-data/site.rds")
licor = read_rds("processed-data/licor.rds")

site_Ags = licor |>
  filter(aperture == "two-sided") |>
  group_by(site_code) |>
  summarise(across(gsw:A, max), Tleaf = Tleaf[which.max(A)]) |>
  left_join(site, join_by(site_code)) |>
  select(site_code, site_type, island, A, gsw, Tleaf) |>
  pivot_longer(cols = A:gsw) |>
  mutate(
    name2 = case_when(
      name == "A" ~ "paste(italic(A), ' [', mu, 'mol ', m^-2, ' ', s^-1, ']')",
      name == "gsw" ~ "paste(italic(g)[sw], ' [mol ', m^-2, ' ', s^-1, ']')"
    ),
    habitat = factor(site_type, levels = c("montane", "coastal"))
  )

ggplot(site_Ags, aes(habitat, value, color = habitat)) +
  facet_wrap(~ name2, scales = "free_y", labeller = label_parsed) +
  geom_point(position = position_nudge(x = 0.1)) +
  stat_summary(geom = "pointinterval", shape = 21, fill = "white",
               fun.data = mean_se, size = 5) +
  ylab("trait value") +
  scale_color_manual(values = c("steelblue", "tomato"), guide = NULL)

fit_habitat_Ags = site_Ags |>
  split(~ name) |>
  map(\(.x) {
    t.test(value ~ site_type, data = .x)
  })

ggsave("figures/habitat-Ags.pdf", width = 5, height = 4)
write_rds(site_Ags, "objects/site_Ags.rds")
write_rds(fit_habitat_Ags, "objects/fit_habitat_Ags.rds")
