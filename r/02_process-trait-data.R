# Join data sheets for analysis
source("r/header.R")

# Climate rasters
# Extract climate data
dir = "raw-data/climate"
tair_ann = raster::raster(glue("{dir}/Tair_month_raster/tair_ann"))
sl_mst_ann = raster::raster(glue("{dir}/SoilMoisture_month_raster/sl_mst_ann"))

# Read in population information ----
write_csv(site, "raw-data/site.csv")
write_csv(plant, "raw-data/plant.csv")
write_csv(licor_leaf, "raw-data/licor_leaf.csv")
write_csv(stomata_density, "raw-data/stomata_density.csv")
write_csv(stomata_size, "raw-data/stomata_size.csv")
write_csv(leaf_thickness, "raw-data/leaf_thickness.csv")

site = read_csv("raw-data/site.csv", col_types = "ccccccDdddd")

plant = read_csv("raw-data/plant.csv", col_types = "ccdd") |>
  # Individual with no data because it was too low quality
  filter(!(site_code == "pkpp" & individual == "i6"))

licor_leaf = read_csv("raw-data/licor_leaf.csv", col_types = "ccc") |>
  mutate(licor_leaf = TRUE)

stomata_density = read_csv("raw-data/stomata_density.csv", col_types = "ccccdc") |>
  mutate(stomatal_density_mm2 = number_of_stomata / image_area_mm2)

stomata_size = read_csv("raw-data/stomata_size.csv", col_types = "ccccidd") |>
  mutate(length_um = length_pixels / pixels_per_um)

leaf_thickness = read_csv("raw-data/leaf_thickness.csv", col_types = "cccddd")

## Check site ----
assert_character(site$site, any.missing = FALSE)
assert_character(site$label, any.missing = FALSE)
assert_character(site$site_code, pattern = "^[a-z]{4}$", any.missing = FALSE)
assert_character(site$alias)
assert_true(all(site$site_type %in% c("coastal", "montane")))
assert_true(all(site$island %in% c("hawaii", "oahu")))
assert_date(site$date_sampled, lower = "2022-08-07", upper = "2022-11-20")
assert_numeric(site$latitude_degree, lower = 18, upper = 23,
               any.missing = FALSE)
assert_numeric(site$longitude_degree, lower = -160, upper = -154,
               any.missing = FALSE)
assert_numeric(site$elevation_m, lower = 0, upper = Inf, any.missing = FALSE)
assert_numeric(site$leaf_area_chamber_cm2, lower = 0, upper = 6)

## Check plant ----
assert_true(all(plant$site_code %in% site$site_code))
assert_character(plant$individual, pattern = "^i[1-9]{1}$", any.missing = FALSE)
assert_numeric(plant$elevation_m, lower = 0, upper = Inf, any.missing = FALSE)
assert_numeric(plant$elevation_feet, lower = 0, upper = Inf, any.missing = FALSE)

## Check licor_leaf ----
assert_true(all(licor_leaf$site_code %in% site$site_code))
assert_character(licor_leaf$individual, pattern = "^i[1-9]{1}$")
assert_character(licor_leaf$leaf_number, pattern = "^l[1-9]{1}$")

## Check stomata_density ----
assert_true(all(stomata_density$site_code %in% site$site_code))
assert_character(stomata_density$individual, pattern = "^i[1-9]{1}$", 
                 any.missing = FALSE)
assert_character(stomata_density$leaf_number, pattern = "^l[1-9]{1}$", 
                 any.missing = FALSE)
assert_true(all(stomata_density$surface %in% c("lower", "upper")))
assert_integerish(stomata_density$number_of_stomata, lower = 0, upper = 1000)
assert_true(all(stomata_density$quality %in% LETTERS[1:3]))
assert_numeric(stomata_density$stomatal_density_mm2, lower = 0, upper = 1000)

## Check stomata_size ----
assert_true(all(stomata_size$site_code %in% site$site_code))
assert_character(stomata_size$individual, pattern = "^i[1-9]{1}$", 
                 any.missing = FALSE)
assert_character(stomata_size$leaf_number, pattern = "^l[1-9]{1}$",
                 any.missing = FALSE)
assert_true(all(stomata_size$surface %in% c("lower", "upper")))
assert_integerish(stomata_size$random_number, lower = 1, upper = 5)
assert_numeric(stomata_size$angle, lower = -180, upper = 180, 
               any.missing = FALSE)
assert_numeric(stomata_size$length_pixels, lower = 0, upper = 100, 
               any.missing = FALSE)
assert_numeric(stomata_size$length_um, lower = 0, upper = 50)

## Check leaf_thickness ----
assert_true(all(leaf_thickness$site_code %in% site$site_code))
assert_character(leaf_thickness$individual, pattern = "^i[1-9]{1}$", 
                 any.missing = FALSE)
assert_character(leaf_thickness$replicate, pattern = "^r[1-9]{1}$", 
                 any.missing = FALSE)
assert_numeric(leaf_thickness$leaf_thickness_pixels, lower = 0, upper = 500, 
               any.missing = FALSE)
assert_numeric(leaf_thickness$leaf_thickness_um, lower = 0, upper = 500, 
               any.missing = FALSE)

# Add climate data to site ----
site1 = site |>
  mutate(
    tair_ann = raster::extract(
      tair_ann, 
      cbind(longitude_degree, latitude_degree)
    ),
    sl_mst_ann = raster::extract(
      sl_mst_ann, 
      cbind(longitude_degree, latitude_degree)
    )
  )

# Summarize multiple measurements ----
stomata_size1 = stomata_size |>
  group_by(site_code, individual, leaf_number, surface) |>
  summarise(length_um = mean(length_um), .groups = "drop") |>
  pivot_wider(names_from = "surface", values_from = "length_um", 
              names_glue = "{surface}_length_um")

leaf_thickness1 = leaf_thickness |>
  group_by(site_code, individual) |>
  summarise(leaf_thickness_um = mean(leaf_thickness_um), .groups = "drop")

# Join data and write ----
write_rds(site, "processed-data/site.rds")

stomata_density |>
  pivot_wider(
    id_cols = c("site_code", "individual", "leaf_number"),
    names_from = "surface", 
    values_from = c("stomatal_density_mm2", "number_of_stomata"),
    names_glue = "{surface}_{.value}"
  ) |>
  full_join(stomata_size1, by = c("site_code", "individual", "leaf_number")) |>
  full_join(leaf_thickness1, by = c("site_code", "individual")) |>
  full_join(plant, by = c("site_code", "individual")) |>
  left_join(site1, by = "site_code", suffix = c("_plant", "_site")) |>
  left_join(licor_leaf, by = join_by(site_code, individual, leaf_number)) |>
  mutate(licor_leaf = ifelse(is.na(licor_leaf), FALSE, licor_leaf)) |>
  
  # Filter leaves with missing/unreliable data
  filter(
    !(site_code == "hlan" & individual == "i6" & leaf_number == "l1"),
    !(site_code == "pkpp" & individual == "i2"),
    !(site_code == "nnpl")
  ) |>
  write_rds("processed-data/trait.rds")
