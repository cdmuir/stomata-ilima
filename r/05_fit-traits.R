source("r/header.R")

trait = read_rds("processed-data/trait.rds") |>
  unite(ind, site_code, individual, remove = FALSE) |>
  unite(leaf, site_code, individual, leaf_number, remove = FALSE)

# Fit all traits except leaf thickness ----
# Need separate data for leaf thickness because no leaf replication
# 
# There were too many missing values for leaf thickness because it was measured
# on a small subset of leaves. Therefore, the model did not converge well when
# it was included among all traits.
bform =
  bf(lower_number_of_stomata ~ site_type + (1|p|leaf) + (1|q|ind) +
       (1|r|site_code)) + negbinomial() +
  bf(upper_number_of_stomata ~ site_type + (1|p|leaf) + (1|q|ind) +
       (1|r|site_code)) + negbinomial() +
  bf(lower_length_um ~ site_type + (1|p|leaf) + (1|q|ind) + (1|r|site_code)) +
  bf(upper_length_um | mi() ~ site_type + (1|p|leaf) + (1|q|ind) + (1|r|site_code)) +
  set_rescor(FALSE)

# make_stancode(bform, data = trait)

fit_stomata = brm(
  bform,
  data = trait,
  iter = 16e3,
  thin = 8e0,
  chains = 4L,
  cores = 4L,
  seed = 912691191,
  backend = "cmdstanr",
  control = list(max_treedepth = 12)
)

write_rds(fit_stomata, "objects/fit_stomata.rds")

# Fit leaf thickness ----
# Center-scale leaf_thickness_um
trait1 = filter(trait, !is.na(leaf_thickness_um)) |>
  group_by(site_type, site_code, ind) |>
  # There is only 1 average leaf_thickness_um per ind
  summarize(leaf_thickness_um = first(leaf_thickness_um))

fit_thickness = brm(
  log(leaf_thickness_um) ~ site_type + (1|ind) + (1|site_code),
  data = trait1,
  iter = 2e3,
  thin = 1e0,
  chains = 4L,
  cores = 4L,
  seed = 995134466,
  backend = "cmdstanr",
  control = list(max_treedepth = 10)
)

write_rds(fit_thickness, "objects/fit_thickness.rds")
