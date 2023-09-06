source("r/header.R")

site = read_rds("processed-data/site.rds")

# Changing K has some effect on gsw. With Solanum data I compared results
# for amphi leaves when K = 0.5 or K is estimated iteratively from gas exchange
# data. The difference was trivial, so I am assuming K = 0.5 for amphi leaves

# Use measured Energy Balance for g_sw calculation? If not, recalc_licor() uses
# T_leaf measured with the thermocouple
use_EB = FALSE 

# 2022-08-07: Makapuʻu Beach Park ----
mkpb = photosynthesis::read_licor("raw-data/licor/2022-08-07-0716_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A)) |>
  mutate(aperture = rep(c("two-sided", "one-sided"), c(18, 10))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "mkpb")

# 2022-08-14: Hawaiʻi loa ridge ----
hwlr = read_licor("raw-data/licor/2022-08-14-0802_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("one-sided", "two-sided"), c(5, 5))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "hwlr")

# 2022-08-19: Kaʻohe game management area ----
kgma = read_licor("raw-data/licor/2022-08-19-0745_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("two-sided", "one-sided"), c(10, 6))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "kgma")

# 2022-08-19: Puakō petroglyph park ----
pkpp = read_licor("raw-data/licor/2022-08-19-1038_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("one-sided", "two-sided"), c(14, 13))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "pkpp")

# 2022-08-19: Koaiʻa tree sanctuary ----
ktrs = read_licor("raw-data/licor/2022-08-19-1311_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("two-sided", "one-sided"), c(12, 4))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "ktrs")

# 2022-08-20: Háloa Áina ----
hlan = read_licor("raw-data/licor/2022-08-20-1051_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("two-sided", "one-sided"), c(4, 4))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "hlan")

# 2022-08-20: Kaloko-Honokōhau national historical park ----
knhp = read_licor("raw-data/licor/2022-08-20-1318_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("two-sided", "one-sided"), c(7, 6))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "knhp")

# 2022-08-28: Kaloko beach ----
klkb = read_licor("raw-data/licor/2022-08-28-0644_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("one-sided", "two-sided"), c(11, 9))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "klkb")

# 2022-09-18: Waʻahila ridge ----
whlr = read_licor("raw-data/licor/2022-09-18-0818_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("one-sided", "two-sided"), c(168, 46))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "whlr")

# 2022-10-09: Kaʻena Point ----
knpn = read_licor("raw-data/licor/2022-10-09-0956_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("two-sided", "one-sided"), c(18, 18))) |>
  process_licor(S = c(5.078, 5.078), use_EB = use_EB, site_code = "knpn")

# 2022-11-20: Mauʻumae Ridge ----
mmrd = read_licor("raw-data/licor/2022-11-20-0721_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("two-sided", "one-sided"), c(57, 45))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "mmrd")

# 2022-11-25: Kahuku Point ----
khkp = read_licor("raw-data/licor/2022-11-25-0852_logdata") |>
  as_tibble(.name_repair = "unique") |>
  filter(!is.na(gsw), !is.na(A), gsw > 0) |>
  mutate(aperture = rep(c("two-sided", "one-sided"), c(18, 23))) |>
  process_licor(S = c(6, 6), use_EB = use_EB, site_code = "khkp")

bind_rows(mkpb,
          hwlr,
          kgma,
          pkpp,
          ktrs,
          hlan,
          knhp,
          klkb,
          whlr,
          knpn,
          mmrd,
          khkp) |>
  unite(site_code_aperture, site_code, aperture, remove = FALSE) |>
  write_rds("processed-data/licor.rds")
