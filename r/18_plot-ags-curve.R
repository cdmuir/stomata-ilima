source("r/header.R")

# Example time course and A-gsw curve ----
x1 = seq(-5, 5, 0.01)
x2 = seq(5, 15, 0.01)

df = tibble(
  x = c(x1, x2),
  y = c(plogis(x1), 2 * (plogis(rev(x2 - 10))) - 1)
)

## Time course
gp1 = ggplot(df, aes(x, y)) +
  annotate("rect", xmin = 5, xmax = 15, ymin = -Inf, ymax = Inf, color = NA, fill = "grey") +
  geom_segment(
    data = filter(df, x %in% 5:15),
    mapping = aes(x = x, xend = x, y = y, yend = -Inf),
    linetype = "dashed"
  ) +
  geom_line(linewidth = 1.1) +
  geom_point(data = filter(df, x %in% 5:15), size = 3) +
  geom_point(data = filter(df, x == 5), size = 20, shape = "*") +
  xlab("time") +
  ylab(expression(paste(italic(g)[sw], " and ", italic(A)))) +
  annotate("text", x = 0, y = 1.275, label = "Acclimate\nRH = 70%\nstomata open") +
  annotate("text", x = 10, y = 1.275, label = "Log data\nRH = 10%\nstomata close") +
  ylim(-1, 1.45) +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )

## Connecting arrow
gp2 = ggplot() +
  annotate("segment", x = 0, xend = 1, y = 0, yend = 0, arrow = arrow(length = unit(0.1, "inches"))) +
  theme_void()

## A-gsw curve
gp3 = df |>
  filter(x %in% 5:15) %>%
  mutate(y1 = y + rnorm(nrow(.), 0, 0.01)) |>
  ggplot(aes(y, y1)) +
  geom_smooth(color = "grey", method = "lm", formula = 'y ~ x') +
  geom_point(size = 2) +
  annotate("point", x = 1, y = 1, size = 15, shape = "*") +
  xlab(expression(paste(italic(g)[sw], " [mol ", m ^ -2 ~ s ^ -1, "]"))) +
  ylab(expression(paste(italic(A), " [", mu, "mol ", m ^ -2 ~ s ^ -1, "]"))) +
  coord_equal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )

## Combine into plot row
plot_row = plot_grid(gp1, gp2, gp3, nrow = 1, rel_widths = c(0.6, 0.05, 0.35),
                     labels = c("A", "", "B"))

## Add title
title = ggdraw() +
  draw_label(
    expression(paste(bold(Idealized~example~of~bolditalic(A)), "-", bold(bolditalic(g)[sw]~curve))),
    fontface = 'bold', x = 0, hjust = 0
  ) +
  theme(plot.margin = margin(0, 0, 0, 7))

## Put title and plots together
pg1 = plot_grid(title, plot_row, ncol = 1, rel_heights = c(0.1, 1))

# Interpretation curve ----
scenarios = c("No amphistomy\nadvantage", "Significant amphistomy\nadvantage")
treatments = c("pseudohypo\nlower surface only", "amphi\nboth surfaces")

df_aa = crossing(
  nesting(
    scenario = factor(scenarios, levels = scenarios),
    aa = c(0.2, 1)
  ),
  `Gas exchange\nthrough:` = treatments,
  nesting(x = -1, xend = 1)
) |>
  mutate(
    y = x - aa * (`Gas exchange\nthrough:` == treatments[1]),
    yend = xend - aa * (`Gas exchange\nthrough:` == treatments[1])
  )

df_aa1 = df_aa |>
  group_by(scenario) |>
  summarize(
    x = first(xend) * 1.2, xend = first(xend) * 1.2,
    y = first(yend), yend = nth(yend, 2),
    `Gas exchange\nthrough:` = NA
  ) |>
  mutate(
    label = case_when(
      scenario == scenarios[1] ~ "no change",
      scenario == scenarios[2] ~ "significant\ndifference"
    )
  )

gp_aa = ggplot(df_aa, aes(x, y, xend = xend, yend = yend, color = `Gas exchange\nthrough:`)) +
  facet_grid(. ~ scenario) +
  geom_segment(size = 2, lineend = "round") +
  xlim(-1, 2.5) +
  geom_segment(data = df_aa1, lineend = "round", size = 1.5) +
  geom_text(data = df_aa1, mapping = aes(y = (y + yend) / 2, label = label),
            hjust = -0.1, color = "black") +
  scale_color_manual(values = c("black", "grey"), na.translate = FALSE) +
  xlab(expression(paste(italic(g)[sw], " [mol ", m ^ -2 ~ s ^ -1, "]"))) +
  ylab(expression(paste(italic(A), " [", mu, "mol ", m ^ -2 ~ s ^ -1, "]"))) +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_text(size = 12),
    title = element_text(size = 12)
  )

## Add title
title = ggdraw() +
  draw_label(
    "Interpretation of idealized amphi and pseudohypo curves",
    fontface = 'bold', x = 0, hjust = 0
  ) +
  theme(plot.margin = margin(0, 0, 0, 7))

pg2 = plot_grid(title, gp_aa, ncol = 1, rel_heights = c(0.1, 1),
                labels = c("", "C"))

## Combine figures ----
plot_grid(pg1, pg2, nrow = 2)
ggsave("figures/ags-curve.pdf", width = 6.5, height = 6.5)
