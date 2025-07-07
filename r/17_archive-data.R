source("r/header.R")

trait = read_rds("processed-data/trait.rds")
site_Ags = read_rds("objects/site_Ags.rds")
site = read_rds("processed-data/site.rds")

# Individual level data
ind_data = trait |>
  mutate(
    genus = "Sida",
    species = "fallax",
    authority = "Walp.",
    exposition = "natural environment",
    plant_maturity = "mature",
    leaf_age = "mature"
  ) |>
  select(
    genus,
    species,
    authority,
    exposition,
    plant_maturity,
    leaf_age,
    site,
    site_code,
    site_type,
    island,
    latitude_degree,
    longitude_degree,
    elevation_m_site,
    elevation_m_plant,
    date_sampled,
    plant_id = individual,
    leaf_id = leaf_number,
    lower_number_of_stomata,
    upper_number_of_stomata,
    lower_stomatal_density_mm2,
    upper_stomatal_density_mm2,
    lower_gcl_um = lower_length_um,
    upper_gcl_um = upper_length_um,
    leaf_thickness_um,
    licor_leaf
  ) |>
  left_join(
    site_Ags |>
      select(site_code, Tleaf, name, value) |>
      pivot_wider() |>
      mutate(licor_leaf = TRUE),
    by = join_by(site_code, licor_leaf)
  ) |>
  select(-licor_leaf) |>
  left_join(
    site |>
      select(
        site,
        site_code,
        site_type,
        island,
        latitude_degree,
        longitude_degree,
        date_sampled,
        # tair_ann,
        # sl_mst_ann,
        # cl_sw_ann,
        # veg_ht_ann,
        # rf_ann
      ),
    by = join_by(
      site,
      site_code,
      site_type,
      island,
      latitude_degree,
      longitude_degree,
      date_sampled
    )
  ) |>
  mutate(
    latitude_degree = round(latitude_degree, 1),
    longitude_degree = round(longitude_degree, 1),
    elevation_m_site = round(elevation_m_site, 0),
    elevation_m_plant = round(elevation_m_plant, 0)
  )


# Summary table
ind_data |>
  filter(site_code == "khkp") |>
  select(site, A, gsw)
sum_data = ind_data |>
  select(site, site_type, island, plant_id, leaf_id, lower_stomatal_density_mm2,
         upper_stomatal_density_mm2, lower_gcl_um, upper_gcl_um,
         leaf_thickness_um, A, gsw) |>
  summarise(across(lower_stomatal_density_mm2:gsw, \(x) mean(x, na.rm = TRUE)),
            .by = c("site", "site_type", "island", "plant_id")) |>
  summarise(across(lower_stomatal_density_mm2:gsw, \(x) mean(x, na.rm = TRUE)),
            .by = c("site", "site_type", "island")) |>
  arrange(site_type, island, site) |>
  mutate(Island = case_when(
    island == "hawaii" ~ "Hawaiʻi",
    island == "oahu" ~ "Oʻahu"
  )) |>
  select(
    Site = site,
    Island,
    Habitat = site_type,
    `$\\mathrm{SD}_\\text{abaxial}$` = lower_stomatal_density_mm2,
    `$\\mathrm{SD}_\\text{adaxial}$` = upper_stomatal_density_mm2,
    `$\\mathrm{GCL}_\\text{abaxial}$` = lower_gcl_um,
    `$\\mathrm{GCL}_\\text{adaxial}$` = upper_gcl_um,
    `Leaf thickness` = leaf_thickness_um,
    `$A$` = A,
    `$g_\\text{sw}$` = gsw
  )

write_csv(ind_data, "dryad/stomata-ilima.csv")
write_rds(sum_data, "objects/sum_data.csv")
