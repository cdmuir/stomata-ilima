source("r/header.R")

licor = read_rds("processed-data/licor.rds")

# fit_licor = brm(bf(
#   A ~ site_code_aperture + s(gsw) + s(gsw, by = site_code_aperture)),
#   data = licor,
#   chains = 4L,
#   cores = 4L,
#   seed = 744874146,
#   backend = "cmdstanr",
#   control = list(max_treedepth = 11),
#   silent = 0
# )

fit_licor = brm(bf(
  A ~ log(gsw) * site_code_aperture, sigma ~ 1 + (1|site_code_aperture)),
  data = licor,
  iter = 4e3,
  thin = 2e0,
  chains = 4L,
  cores = 4L,
  seed = 744874146,
  backend = "cmdstanr",
  control = list(max_treedepth = 12),
  silent = 0
)

write_rds(fit_licor, "objects/fit_licor.rds")
