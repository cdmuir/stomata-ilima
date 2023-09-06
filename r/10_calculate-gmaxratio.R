source("r/header.R")

site = read_rds("processed-data/site.rds")
aa = read_rds("objects/aa.rds")
fit_stomata = read_rds("objects/fit_stomata.rds")

# stomatal number and size per site type ----
stomata_sitetype = fit_stomata |>
  as_draws_df() |>
  select(
    .draw,
    matches("^b_(low|upp)ernumberofstomata"),
    matches("^b_(low|upp)erlengthum")
  ) |>
  mutate(
    coastal_lower_stomata_number = b_lowernumberofstomata_Intercept,
    coastal_upper_stomata_number = b_uppernumberofstomata_Intercept,
    montane_lower_stomata_number = b_lowernumberofstomata_Intercept +
        b_lowernumberofstomata_site_typemontane,
    montane_upper_stomata_number = b_uppernumberofstomata_Intercept +
        b_uppernumberofstomata_site_typemontane,
    
    coastal_lower_length_um = b_lowerlengthum_Intercept,
    coastal_upper_length_um = b_upperlengthum_Intercept,
    montane_lower_length_um = b_lowerlengthum_Intercept +
      b_lowerlengthum_site_typemontane,
    montane_upper_length_um = b_upperlengthum_Intercept +
      b_upperlengthum_site_typemontane
  ) |>
  select(
    .draw,
    matches(
      "^(coastal|montane)_(upper|lower)_(stomata_number|length_um)$"
    )
  ) |>
  pivot_longer(
    -.draw,
    names_to = c("site_type", "surface", "trait", "unit"),
    names_sep = "_",
    values_to = "b_sitetype"
  )

# stomatal number and size per site ----
stomata_site = fit_stomata |>
  as_draws_df() |>
  select(
    .draw,
    starts_with("r_site_code")
  ) |>
  pivot_longer(-.draw) |>
  mutate(
    surface = str_extract(name, "(upp|low)er"),
    trait = str_extract(name, "numberofstomata|lengthum"),
    s = glue("^r_site_code__{surface}{trait}\\[([a-z]{{4}}),Intercept\\]$"),
    site_code = str_replace(name, s, "\\1") |>
      str_extract("^[a-z]{4}$")
  ) |>
  select(.draw, site_code, surface, trait, value) |>
  full_join(select(site, site_code, site_type), by = join_by(site_code)) |>
  rename(b_site = value) |>
  mutate(
    trait = str_replace(trait, "numberofstomata", "stomata"),
    trait = str_replace(trait, "lengthum", "length"),
    unit = case_when(
      trait == "stomata" ~ "number",
      trait == "length" ~ "um")
  )

# stomatal number and size per individual ----
stomata_ind = fit_stomata |>
  as_draws_df() |>
  select(
    .draw,
    matches("r_ind__(upp|low)er(lengthum|numberofstomata)\\[[a-z]{4}_i[0-9],Intercept\\]")
  ) |>
  pivot_longer(-.draw) |>
  mutate(
    surface = str_extract(name, "(upp|low)er"),
    trait = str_extract(name, "numberofstomata|lengthum"),
    s = glue("r_ind__{surface}{trait}\\[([a-z]{{4}})_(i[0-9]),Intercept\\]$"),
    site_code = str_replace(name, s, "\\1"),
    ind = str_replace(name, s, "\\2"),
  ) |>
  select(.draw, site_code, ind, surface, trait, value) |>
  full_join(select(site, site_code, site_type), by = join_by(site_code)) |>
  rename(b_ind = value) |>
  mutate(
    trait = str_replace(trait, "numberofstomata", "stomata"),
    trait = str_replace(trait, "lengthum", "length"),
    unit = case_when(
      trait == "stomata" ~ "number",
      trait == "length" ~ "um")
  )

# stomatal number and size per leaf ----
stomata_leaf = fit_stomata |>
  as_draws_df() |>
  select(
    .draw,
    matches("r_leaf__(upp|low)er(lengthum|numberofstomata)\\[[a-z]{4}_i[0-9]_l[0-9],Intercept\\]")
  ) |>
  pivot_longer(-.draw) |>
  mutate(
    surface = str_extract(name, "(upp|low)er"),
    trait = str_extract(name, "numberofstomata|lengthum"),
    s = glue("r_leaf__{surface}{trait}\\[([a-z]{{4}})_(i[0-9])_(l[0-9]),Intercept\\]$"),
    site_code = str_replace(name, s, "\\1"),
    ind = str_replace(name, s, "\\2"),
    leaf = str_replace(name, s, "\\3")
  ) |>
  select(.draw, site_code, ind, leaf, surface, trait, value) |>
  full_join(select(site, site_code, site_type), by = join_by(site_code)) |>
  rename(b_leaf = value) |>
  mutate(
    trait = str_replace(trait, "numberofstomata", "stomata"),
    trait = str_replace(trait, "lengthum", "length"),
    unit = case_when(
      trait == "stomata" ~ "number",
      trait == "length" ~ "um")
  )

# gsmax ratio per site type ----
gmaxratio_sitetype = stomata_sitetype |>
  mutate(
    b_sitetype = ifelse(trait == "stomata", exp(b_sitetype), b_sitetype),
    b_sitetype = b_sitetype / ifelse(trait == "stomata", image_area_mm2, 1),
    trait = str_replace(trait, "stomata", "stomataldensity"),
    unit = str_replace(unit, "number", "mm2"),
  ) |>
  pivot_wider(
    names_from = c("site_type", "surface", "trait", "unit"),
    names_glue = "{site_type}_{surface}_{trait}_{unit}",
    values_from = "b_sitetype"
  ) |>
  mutate(
    c = 0.5,
    h = 0.5,
    j = 0.5,
    m = morphological_constant(c, j, h),
    b = biophysical_constant(2.49e-5, 2.24e-2),
    coastal_lower_as = coastal_lower_length_um ^ 2 * j,
    coastal_upper_as = coastal_upper_length_um ^ 2 * j,
    montane_lower_as = montane_lower_length_um ^ 2 * j,
    montane_upper_as = montane_upper_length_um ^ 2 * j,
    coastal_lower_gmax = b * m * coastal_lower_stomataldensity_mm2 *
      sqrt(coastal_lower_as),
    coastal_upper_gmax = b * m * coastal_upper_stomataldensity_mm2 *
      sqrt(coastal_upper_as),
    montane_lower_gmax = b * m * montane_lower_stomataldensity_mm2 *
      sqrt(montane_lower_as),
    montane_upper_gmax = b * m * montane_upper_stomataldensity_mm2 *
      sqrt(montane_upper_as)
  ) |>
  select(.draw, ends_with("gmax")) |>
  pivot_longer(
    ends_with("gmax"),
    names_sep = "_",
    names_to = c("habitat", "surface", "trait")
  ) |>
  pivot_wider(names_from = c("surface", "trait"),
              values_from = "value") |>
  mutate(gmax_ratio = upper_gmax / (lower_gmax + upper_gmax))

# gsmax ratio per site ----
gmaxratio_site = left_join(stomata_site,
          stomata_sitetype,
          by = join_by(.draw, surface, trait, unit),
          relationship = "many-to-many") |>
  filter(site_type.x == site_type.y) |>
  rename(site_type = site_type.x) |>
  select(-site_type.y) |>
  mutate(value = b_sitetype + b_site, value = ifelse(trait == "stomata", exp(value), value)) |>
  select(-b_sitetype, -b_site) |>
  pivot_wider(
    names_from = c("surface", "trait", "unit"),
    names_glue = "{surface}_{trait}_{unit}"
  ) |>
  mutate(
    lower_stomataldensity_mm2 = lower_stomata_number / image_area_mm2,
    upper_stomataldensity_mm2 = upper_stomata_number / image_area_mm2,
    c = 0.5,
    h = 0.5,
    j = 0.5,
    m = morphological_constant(c, j, h),
    b = biophysical_constant(2.49e-5, 2.24e-2),
    lower_as = lower_length_um ^ 2 * j,
    upper_as = upper_length_um ^ 2 * j,
    lower_gmax = b * m * lower_stomataldensity_mm2 * sqrt(lower_as),
    upper_gmax = b * m * upper_stomataldensity_mm2 * sqrt(upper_as)
  ) |>
  select(.draw, site_code, site_type, ends_with("gmax")) |>
  mutate(gmax_ratio = upper_gmax / (lower_gmax + upper_gmax))

# gsmax ratio per ind ----
gmaxratio_ind = stomata_ind |>
  left_join(
    stomata_site, 
    by = join_by(.draw, site_code, surface, trait, site_type, unit)
  ) |>
  left_join(
    stomata_sitetype,
    by = join_by(.draw, surface, trait, unit),
    relationship = "many-to-many"
  ) |>
  filter(site_type.x == site_type.y) |>
  rename(site_type = site_type.x) |>
  select(-site_type.y) |>
  mutate(
    value = b_sitetype + b_site + b_ind, 
    value = ifelse(trait == "stomata", exp(value), value)
  ) |>
  select(-b_sitetype, -b_site, -b_ind) |>
  pivot_wider(
    names_from = c("surface", "trait", "unit"),
    names_glue = "{surface}_{trait}_{unit}"
  ) |>
  mutate(
    lower_stomataldensity_mm2 = lower_stomata_number / image_area_mm2,
    upper_stomataldensity_mm2 = upper_stomata_number / image_area_mm2,
    c = 0.5,
    h = 0.5,
    j = 0.5,
    m = morphological_constant(c, j, h),
    b = biophysical_constant(2.49e-5, 2.24e-2),
    lower_as = lower_length_um ^ 2 * j,
    upper_as = upper_length_um ^ 2 * j,
    lower_gmax = b * m * lower_stomataldensity_mm2 * sqrt(lower_as),
    upper_gmax = b * m * upper_stomataldensity_mm2 * sqrt(upper_as)
  ) |>
  select(.draw, site_code, site_type, ind, ends_with("gmax")) |>
  mutate(gmax_ratio = upper_gmax / (lower_gmax + upper_gmax))

# gsmax ratio per leaf ----
gmaxratio_leaf = stomata_leaf |>
  left_join(
    stomata_site, 
    by = join_by(.draw, site_code, surface, trait, site_type, unit)
  ) |>
  left_join(
    stomata_sitetype,
    by = join_by(.draw, surface, trait, unit),
    relationship = "many-to-many"
  ) |>
  filter(site_type.x == site_type.y) |>
  rename(site_type = site_type.x) |>
  select(-site_type.y) |>
  left_join(
    stomata_ind,
    by = join_by(.draw, site_type, site_code, ind, surface, trait, unit)
  ) |>
  mutate(
    value = b_sitetype + b_site + b_ind + b_leaf, 
    value = ifelse(trait == "stomata", exp(value), value)
  ) |>
  select(-b_sitetype, -b_site, -b_ind, -b_leaf) |>
  pivot_wider(
    names_from = c("surface", "trait", "unit"),
    names_glue = "{surface}_{trait}_{unit}"
  ) |>
  mutate(
    lower_stomataldensity_mm2 = lower_stomata_number / image_area_mm2,
    upper_stomataldensity_mm2 = upper_stomata_number / image_area_mm2,
    c = 0.5,
    h = 0.5,
    j = 0.5,
    m = morphological_constant(c, j, h),
    b = biophysical_constant(2.49e-5, 2.24e-2),
    lower_as = lower_length_um ^ 2 * j,
    upper_as = upper_length_um ^ 2 * j,
    lower_gmax = b * m * lower_stomataldensity_mm2 * sqrt(lower_as),
    upper_gmax = b * m * upper_stomataldensity_mm2 * sqrt(upper_as)
  ) |>
  select(.draw, site_code, site_type, ind, leaf, ends_with("gmax")) |>
  mutate(gmax_ratio = upper_gmax / (lower_gmax + upper_gmax))

# write ----
write_rds(gmaxratio_sitetype, "objects/gmaxratio_sitetype.rds")
write_rds(gmaxratio_site, "objects/gmaxratio_site.rds")
write_rds(gmaxratio_ind, "objects/gmaxratio_ind.rds")
write_rds(gmaxratio_leaf, "objects/gmaxratio_leaf.rds")

