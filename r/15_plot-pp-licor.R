source("r/header.R")

fit_licor = read_rds("objects/fit_licor.rds")

pp_licor = pp_check(fit_licor, ndraws = 4e3)

pp_licor +
  xlab(expression(paste(italic(A), ' [', mu, 'mol ', m^-2, ' ', s^-1, ']'))) +
  ylab("probability density") +
  scale_color_manual(values = c("black", "grey"),
                     name = NULL, labels = c("data", "posterior\npredictions")) +
  theme(
    axis.text.y = element_text(),
    axis.ticks.y = element_line(),
    axis.title.y = element_text(),
    legend.position = "top"
  )

ggsave("figures/pp-licor.pdf", width = 4, height = 4)
