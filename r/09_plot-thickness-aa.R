source("r/header.R")

site = read_rds("processed-data/site.rds")
aa = read_rds("objects/aa.rds")
fit_thickness = read_rds("objects/fit_thickness.rds")

# Summarize population-level posteriors of AA and leaf thickness
df_thickness_aa = fit_thickness |>
  as_draws_df() |>
  select(
    "b_Intercept",
    "b_site_typemontane",
    matches("^r_site_code\\[[a-z]{4},Intercept\\]$"),
    draw = .draw
  ) |>
  pivot_longer(matches("^r_site_code\\[[a-z]{4},Intercept\\]$")) |>
  mutate(site_code = str_replace(name, "^r_site_code\\[([a-z]{4}),Intercept\\]$", "\\1")) |>
  left_join(select(site, site_code, site_type), by = join_by(site_code)) |>
  mutate(
    log_leaf_thickness_um = b_Intercept +
      (site_type == "montane") * b_site_typemontane + value,
    site_code = factor(site_code, levels = unique(aa$site_code))
  ) |>
  select(site_code, site_type, draw, log_leaf_thickness_um) |>
  full_join(aa, by = join_by(site_code, draw)) |>
  filter(!is.na(AA))

# Plot leaf thickness vs. AA

## dataframe for plotting points
df_points = df_thickness_aa |>
  group_by(site_code, site_type) |>
  point_interval(log_leaf_thickness_um, AA) |>
  mutate(
    leaf_thickness_um = exp(log_leaf_thickness_um),
    leaf_thickness_um.lower = exp(log_leaf_thickness_um.lower),
    leaf_thickness_um.upper = exp(log_leaf_thickness_um.upper),
    habitat = factor(site_type, levels = c("montane", "coastal"))
  ) 

## dataframe for estimates and CIs of coefficients
df_coef = df_thickness_aa |>
  split(~ draw) |>
  map_dfr(\(.d) {
    fit = lm(AA ~ site_type + log_leaf_thickness_um, data = .d)
    b = coef(fit)
    tibble(intercept = b[1], b_montane = b[2], slope = b[3])
  })

## dataframe for plotting lines
df_line = df_coef |>
  cross_join(
    df_points |>
      ungroup() |>
      summarize(
        min_log_leaf_thickness_um = min(log_leaf_thickness_um),
        max_log_leaf_thickness_um = max(log_leaf_thickness_um),
        .by = "habitat"
      ) |>
      crossing(i = seq(0, 1, length.out = 1e2)) |>
      mutate(
        r = max_log_leaf_thickness_um - min_log_leaf_thickness_um,
        log_leaf_thickness_um = min_log_leaf_thickness_um + r * i
      ) |>
      select(habitat, log_leaf_thickness_um)
  ) |>
  mutate(
    AA = intercept + b_montane * (habitat == "montane") +
           slope * log_leaf_thickness_um,
    leaf_thickness_um = exp(log_leaf_thickness_um)
  ) |>
  group_by(habitat, leaf_thickness_um) |>
  point_interval(AA)

gp = ggplot(df_points, aes(leaf_thickness_um, AA, color = habitat)) +
    geom_lineribbon(
      data = df_line, 
      mapping = aes(ymin = .lower, ymax = .upper, fill = habitat), alpha = 0.5
    ) +
  geom_pointinterval(
    aes(ymin = AA.lower, ymax = AA.upper), size = 0, linewidth = 1
  ) +
    geom_pointinterval(
      aes(xmin = leaf_thickness_um.lower, xmax = leaf_thickness_um.upper, 
          color = habitat), linewidth = 1
    ) +
    scale_x_log10() +
    xlab(expression(paste("log(leaf thickness, ", mu, "m)"))) +
    ylab("amphistomy advantage") +
    ylim(-0.1, 0.3) +
  scale_color_manual(values = c("steelblue", "tomato")) +
  scale_fill_manual(values = c("steelblue", "tomato"))
  
# Write
write_rds(df_coef, "objects/coef_thickness_aa.rds")
write_rds(gp, "objects/plot_thickness_aa.rds")
