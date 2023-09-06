source("r/header.R")

licor = read_rds("processed-data/licor.rds")
fit_licor =  read_rds("objects/fit_licor.rds")

# Estimate AA and CIs for each site ----
licor2 = licor |>
  summarize(min = min(gsw), max = max(gsw), .by = c("site_code", "aperture")) |>
  pivot_wider(names_from = aperture, values_from = min:max) |>
  rowwise() |>
  mutate(gsw = ifelse(
    `max_two-sided` > `max_one-sided`,
    mean(c(`max_one-sided`, `min_two-sided`)),
    mean(c(`min_one-sided`, `max_two-sided`))
  )) |>
  crossing(aperture = c("one-sided", "two-sided")) |>
  unite(site_code_aperture, site_code, aperture, remove = FALSE) |>
  select(-matches("^(max|min)_(one|two)-sided$")) |>
  mutate(i = row_number())

# fit_licor_draws = prepare_predictions(fit_licor)
# ndraw = fit_licor_draws$ndraws
ndraw = 4000

pred_licor2 = predict(fit_licor, new = licor2, summary = FALSE, ndraws = ndraw)

aa = licor2 %>%
  full_join(
    pred_licor2 |>
      matrix(ncol = 1) |>
      set_colnames("A_model") |>
      as_tibble() |>
      mutate(
        i = rep(seq_len(nrow(.)), each = ndraw),
        draw = rep(seq_len(ndraw), nrow(.))
      ),
    by = join_by(i)
  ) |>
  pivot_wider(
    id_cols = c("site_code", "draw"),
    names_from = "aperture",
    values_from = "A_model"
  ) |>
  mutate(AA = log(`two-sided` / `one-sided`)) |>
  left_join(licor2 |>
              filter(aperture == "two-sided") |>
              select(site_code, gsw),
            by = join_by(site_code))

write_rds(aa, "objects/aa.rds")
