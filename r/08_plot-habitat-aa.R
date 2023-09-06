source("r/header.R")

site = read_rds("processed-data/site.rds")
aa = read_rds("objects/aa.rds")

# Prepare data for plotting habitat and site vs. AA
df1 = aa |>
  group_by(site_code) |>
  point_interval(AA) |>
  left_join(site, by = join_by(site_code)) |>
  mutate(
    habitat = factor(site_type, levels = c("montane", "coastal")),
    site_code1 = fct_reorder(site_code, AA)
  )

# Prepare and write estimated difference in AA between habitats
habitat_aa = aa |>
  select(site_code, draw, AA) |>
  left_join(select(site, site_code, site_type), by = join_by(site_code)) |>
  summarize(AA = mean(AA), .by = c("site_type", "draw"))

write_rds(habitat_aa, "objects/habitat_aa.rds") # all data

habitat_aa1 = aa |>
  select(site_code, draw, AA) |>
  filter(!(site_code %in% c("pkpp", "knhp"))) |>
  left_join(select(site, site_code, site_type), by = join_by(site_code)) |>
  summarize(AA = mean(AA), .by = c("site_type", "draw"))

write_rds(habitat_aa1, "objects/habitat_aa1.rds") # removing two sites with extrapolation

# Prepare data for plotting habitat vs. average AA
df2 = habitat_aa |>
  summarize(AA = median(AA), .by = "site_type") |>
  mutate(habitat = factor(site_type, levels = c("montane", "coastal")))

ggplot(df1, aes(habitat, AA, ymin = .lower, ymax = .upper, color = habitat, 
                group = site_code1)) +
  geom_hline(yintercept = 0, color = "grey") +
  geom_spoke(data = df2, aes(habitat, AA, color = habitat), 
             inherit.aes = FALSE, angle = 0, radius = 0.45) +
  geom_spoke(data = df2, aes(habitat, AA, color = habitat), 
             inherit.aes = FALSE, angle = 0, radius = -0.45) +
  geom_pointinterval(position = position_dodge()) +
  ylab("amphistomy advantage") +
  ylim(-0.1, 0.3) +
  scale_color_manual(values = c("steelblue", "tomato"), guide = NULL)

ggsave("figures/habitat-aa.pdf", width = 3, height = 4)
