# Data from: Amphistomy increases leaf photosynthesis more in coastal than montane plants of Hawaiian ʻilima (*Sida fallax*)

https://doi.org/10.5061/dryad.rxwdbrvfw

This dataset contains leaf trait data for each individual 'ilima individual and/or leaf in our sample.

## Description of the data and file structure

The data are structured as a comma separated value (CSV) file with 185 rows and 32 columns:

* `genus`: genus name
* `species`: specific epithet
* `authority`: authority
* `exposition`: sampled from 'natural environment' or 'experimental growth conditions'
* `plant_maturity`: 'juvenile' or 'mature' plant
* `leaf_age`: 'young', 'youthful', 'mature', 'old', or 'senescent' leaf according to [Bowman and Box 1983](https://doi.org/10.1111/j.1442-9993.1983.tb01515.x)
* `site`: freeform site name
* `site_code`: four-letter site code
* `site_type`: 'coastal' or 'montane' site type
* `island`: island where site is located (oahu = O'ahu; hawaii = Hawai'i, aka Big Island)
* `latitude_degree`: site latitude in decimal degrees
* `longitude_degree`: site longitude in decimal degrees
* `elevation_m_site`: site elevation in meters above sea level
* `elevation_m_plant`: plant elevation in meters above sea level
* `date_sampled`: date of sampling in YYYY-MM-DD format
* `plant_id`: id of individual plant within site (i1, i2, ...)
* `leaf_id`: id of individual leaf within plant (l1, l2, ...)
* `lower_number_of_stomata`: count of stomata on lower (abaxial) surface per 0.890 mm$^{2}$ field
* `upper_number_of_stomata`: count of stomata on upper (adaxial) surface per 0.890 mm$^{2}$ field
* `lower_stomatal_density_mm2`: stomatal density per mm$^2$ on lower (abaxial) surface, calculated as `lower_number_of_stomata` / 0.890 mm$^{2}$
* `upper_stomatal_density_mm2`: stomatal density per mm$^2$ on upper (adaxial) surface, calculated as `upper_number_of_stomata` / 0.890 mm$^{2}$
* `lower_gcl_um`: lower (abaxial) guard cell length (gcl) in $\mu$m
* `upper_gcl_um`: upper (adaxial) guard cell length (gcl) in $\mu$m
* `leaf_thickness_um`: leaf lamina thickness from upper cuticle to lower cuticle in $\mu$m
* `Tleaf`: leaf temperature for `A` and `gsw` in degree C
* `A`: photosynthetic CO$_2$ assimilation rate in $\mu \text{mol}~\text{m}^{-2}~\text{s}^{-1}$
* `gsw`: stomatal conductance to water vapor $\text{mol}~\text{m}^{-2}~\text{s}^{-1}$
* `tair_ann`: site mean annual air temperature in degree C
* `sl_mst_ann`: site mean annual cloud frequency
* `cl_sw_ann`: site mean annual solar radiation in W m$^{-2}$
* `veg_ht_ann`: site vegetation height in m
* `rf_ann`: site mean annual rainfall in mm

Missing data are indicated by `NA`.

## Sharing/Access information

Links to other publicly accessible locations of the data:
 - [https://www.try-db.org/](https://www.try-db.org/)

## Code/Software

All code associated with these data and related publications is available on GitHub and archived on Zenodo:
  - [https://github.com/cdmuir/stomata-ilima](https://github.com/cdmuir/stomata-ilima)
  - [https://doi.org/10.5281/zenodo.10369114](https://doi.org/10.5281/zenodo.10369114)
