source("r/header.R")

aa = read_rds("objects/aa.rds") |>
  rename(.draw = draw)
gmaxratio_ind = read_rds("objects/gmaxratio_ind.rds")
gmaxratio_leaf = read_rds("objects/gmaxratio_leaf.rds")
trait = read_rds("processed-data/trait.rds") |>
  select(site_code, ind = individual, leaf = leaf_number, licor_leaf) |>
  crossing(.draw = unique(aa$.draw))

df_gmaxratio_aa = gmaxratio_ind |>
  full_join(trait, by = join_by(.draw, site_code, ind)) |>
  full_join(aa, by = join_by(.draw, site_code)) |>
  filter(licor_leaf)

# Plot gmaxratio vs. AA

## dataframe for plotting points
df_points = df_gmaxratio_aa |>
  group_by(site_code, site_type) |>
  point_interval(gmax_ratio, AA) |>
  mutate(habitat = factor(site_type, levels = c("montane", "coastal"))) 

## dataframe for estimates and CIs of coefficients
df_coef = df_gmaxratio_aa |>
  split(~ .draw) |>
  map_dfr(\(.d) {
    fit = lm(AA ~ site_type + gmax_ratio, data = .d)
    b = coef(fit)
    tibble(intercept = b[1], b_montane = b[2], slope = b[3])
  })

## dataframe for plotting lines
df_line = df_coef |>
  cross_join(
    df_points |>
      ungroup() |>
      summarize(
        min_gmax_ratio = min(gmax_ratio),
        max_gmax_ratio = max(gmax_ratio),
        .by = "habitat"
      ) |>
      crossing(i = seq(0, 1, length.out = 1e2)) |>
      mutate(
        r = max_gmax_ratio - min_gmax_ratio,
        gmax_ratio = min_gmax_ratio + r * i
      ) |>
      select(habitat, gmax_ratio)
  ) |>
  mutate(
    AA = intercept + b_montane * (habitat == "montane") +
           slope * gmax_ratio,
  ) |>
  group_by(habitat, gmax_ratio) |>
  point_interval(AA)

gp = ggplot(df_points, aes(gmax_ratio, AA, color = habitat)) +
    geom_lineribbon(
      data = df_line, 
      mapping = aes(ymin = .lower, ymax = .upper, fill = habitat), alpha = 0.5
    ) +
  geom_pointinterval(
    aes(ymin = AA.lower, ymax = AA.upper), size = 0, linewidth = 1
  ) +
    geom_pointinterval(
      aes(xmin = gmax_ratio.lower, xmax = gmax_ratio.upper, 
          color = habitat), linewidth = 1
    ) +
    xlab(expression(italic(g)[paste("smax,ratio")])) +
    ylab("amphistomy advantage") +
    ylim(-0.1, 0.3) +
  scale_color_manual(values = c("steelblue", "tomato")) +
  scale_fill_manual(values = c("steelblue", "tomato"))
  
# Write
write_rds(df_coef, "objects/coef_gmaxratio_aa.rds")
write_rds(gp, "objects/plot_gmaxratio_aa.rds")
