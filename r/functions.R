# Calculations of gsmax follow Sack and Buckley 2016
biophysical_constant = function(D_wv, v) D_wv / v

morphological_constant = function(c, h, j) {
  (pi * c ^ 2) / (j ^ 0.5 * (4 * h * j + pi * c))
}

# Recalculate LI-6800 data with different S and K values
recalc_licor = function(licor_data, S, K, dynamic = FALSE, use_EB = FALSE) {
  
  assert_number(S, lower = 0, upper = 6)
  assert_numeric(K, lower = 0, any.missing = FALSE, min.len = 1L,
                 max.len = nrow(licor_data))
  assert_flag(dynamic)
  
  vars = c(
    "obs", "Flow", "H2O_s", "H2O_r", "CorrFact", "Qamb_in", "Qamb_out", "Q",
    "f_farred", "Q_red", "Q_modavg", "Q_blue",
    "Tair", "Tleaf", "Tleaf2", "Fan_speed", "Pa", "TleafCnd", "ΔPcham",
    "Ca", "CO2_r", "CO2_s"
  )
  
  if (dynamic) {
    vars = c(vars, "Crd", "Csd",	"dCsd/dt", "αVc")
  }
  
  ret = licor_data |>
    select(all_of(vars)) |>
    mutate(
      
      # System constants
      Oxygen = 21,
      
      # Chamber constants for calculating gbw
      blc_a = 0.578,
      blc_b = 0.5229739,
      blc_c = 0.003740252,
      blc_d = -0.06197961,
      blc_e = -0.005608586,
      blc_minS = 1,
      blc_maxS = 6,
      blc_Po = 96.9,
      
      # Leaf constants
      S = S,
      K = K,
      
      # Leaf temperature constants
      # Determines whether to use Tleaf, Tleaf2, or TleafEB
      deltaTw = 0, fT1 = !use_EB, fT2 = 0, fTeb = use_EB,
      
      # Leaf absorbtance constants
      abs_ambient	= 0.76,
      abs_redLED = 0.84,
      abs_greenLED = 0.7,
      abs_blueLED = 0.87,	
      abs_whiteLED = 0.75,
      abs_redFlr = 0.84,
      abs_blueFlr	= 0.87,
      k_ambient	= 0.1725,
      k_redLED = 0.1512,
      k_greenLED = 0.161,
      k_blueLED = 0.2262, 
      k_whiteLED = 0.1575,
      k_redFlr = 0.1596,
      k_blueFlr = 0.2175,
      
      # Light constants
      # Determines which light source to use for calculating Qin
      fQ_Amb_in = 0, fQ_Amb_out	= 0, fQ_HeadLS = 0, fQ_ConsoleLS = 0, fQ_Flr = 1,
      
      # Light
      Qin = fQ_Amb_in * Qamb_in + fQ_Amb_out * Qamb_out + 
        fQ_Flr * Q * (1 - f_farred),
      
      # Evaporation
      E = Flow * CorrFact * (H2O_s - H2O_r) / 
        (100 * S * (1000 - CorrFact * H2O_s)),
      
      # Computed variables for gbw
      S1 = max(c(min(c(S, blc_maxS)), blc_minS)),
      W1 = Fan_speed * Pa / (blc_Po * 1000),
      
      gbw = blc_a + blc_b * W1 + blc_c * W1 * S1 ^ 2 + blc_d * S1 * W1 + 
        blc_e * W1 ^ 2,
      
      # Energy balance
      convert = (fQ_Amb_in * k_ambient + fQ_Amb_out * k_ambient + fQ_Flr * ((Q_red + Q_modavg) / max(c(Q_red + Q_modavg + Q_blue, 0.1)) * k_redFlr + Q_blue / max(c(Q_red + Q_modavg + Q_blue, 0.1)) * k_blueFlr)) / (fQ_Amb_in + fQ_Amb_out + fQ_Flr),
      Rabs = Qin * convert,
      
      # Leaf temperature
      TleafEB = (Tair + (Rabs + 2 * 0.95 * 0.0000000567 * (((Tair + deltaTw) + 273) ^ 4 - (Tair + 273) ^ 4) - 44100 * E) / (1.84 * 29.3 * gbw + 8 * 0.95 * 0.0000000567 * (Tair + 273) ^ 3)),
      TleafCnd = fT1 * Tleaf + fT2 * Tleaf2 + fTeb * TleafEB,
      
      gtw = E * (1000 - (1000 * 0.61365 * exp(17.502 * TleafCnd / (240.97 + TleafCnd)) / (Pa + ΔPcham) + H2O_s) / 2) / (1000 * 0.61365 * exp(17.502 * TleafCnd / (240.97 + TleafCnd)) / (Pa + ΔPcham) - H2O_s),
      gsw = 2 / ((1 / gtw - 1 / gbw) + sign(gtw) * sqrt((1 / gtw - 1 / gbw) * (1 / gtw - 1 / gbw) + 4 * K / ((K + 1) * (K + 1)) * (2 * 1 / gtw * 1 / gbw - 1 / gbw * 1 / gbw))),
      
      A = Flow * CorrFact * (CO2_r - CO2_s * (1000 - CorrFact * H2O_r) / (1000 - CorrFact * H2O_s)) / (100 * S),
      gtc = 1 / ((K + 1) / (gsw / 1.6) + 1 / (gbw / 1.37)) + K / ((K + 1) / (gsw / 1.6) + K / (gbw / 1.37)),
      Ci = ((gtc - E / 2) * Ca - A) / (gtc + E / 2)
      
    )
  
  if (dynamic) {
    ret = ret |>
      mutate(
        # Dynamic A
        Adyn = (Crd - Csd - Pa * 1000 / (8.314 * (Tair + 273.15)) * αVc / 
                  Flow * `dCsd/dt`) * Flow / (100 * S) * (1000 - H2O_r) / 1000
      )
  }
  
  return(mutate(ret, aperture = licor_data$aperture))
  
}

process_licor = function(licor_data, S, use_EB, site_code) {
  
  assert_numeric(S, lower = 0, upper = 6, len = 2, any.missing = FALSE)
  assert_flag(use_EB)
  assert_string(site_code, pattern = "^[a-z]{4}$")
  
  bind_rows(
    filter(licor_data, aperture == "one-sided") |>
      recalc_licor(S = S[1], use_EB = use_EB, K = 0) |>
      select(gsw, A, Tleaf, TleafEB, aperture),
    filter(licor_data, aperture == "two-sided") |>
      recalc_licor(S = S[2], use_EB = use_EB, K = 0.5) |>
      select(gsw, A, Tleaf, TleafEB, aperture)
  ) |>
    mutate(site_code = site_code)
  
}

# Convenience function to factor categorial variables
factor_site_code = function(.x) {
  .x |>
    mutate(site_code = factor(
      site_code,
      levels = c(
        # coastal
        "knhp",
        "pkpp",
        "khkp",
        "klkb",
        "mkpb",
        "knpn",
        # montane
        "kgma",
        "hlan",
        "whlr",
        "hwlr",
        "mmrd",
        "ktrs",
        "nnpl"
      )
    )
  )
  
}

# Convenience function to plot site
add_site1 = function(.x) {
  .x |>
    factor_site_code() |>
    mutate(
      site1 = as.numeric(site_code) - 6 * (site_type == "montane"),
      site1 = ifelse(site1 == 7, 6, site1)
    ) 
}
