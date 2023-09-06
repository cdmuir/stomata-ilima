source("r/header.R")

plot_gmaxratio_aa = read_rds("objects/plot_gmaxratio_aa.rds") +
  theme(legend.position = "none")

plot_thickness_aa = read_rds("objects/plot_thickness_aa.rds") +
  theme(legend.position = "top")

habitat_legend = get_legend(plot_thickness_aa)

plot_thickness_aa = plot_thickness_aa +
  theme(legend.position = "none")

gp1 = plot_grid(plot_thickness_aa, plot_gmaxratio_aa, nrow = 1, labels = "AUTO")

gp = grid.arrange(grobs = list(habitat_legend, gp1), ncol = 1, nrow = 2, 
                  heights = c(0.1, 0.9))

ggsave("figures/traits-aa.pdf", gp, width = 6.5, height = 4)
