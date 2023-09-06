source("r/header.R")

site = read_rds("processed-data/site.rds") |>
  mutate(label = c(
"Makapu\u02bbu beach",                           
"Hawai\u02bbi loa ridge",          
"Ka\u02bbohe game\nmanagement area",
"Puak\u014d petroglyph park",             
"Koai\u02bba tree sanctuary",                   
"Hāloa \u02bb\u0100ina",                   
"Kaloko-Honok\u014dhau\nnational historical park",
"Kaloko beach",
"Wa\u02bbahila ridge",            
"Kahuku Point",                          
"Nu\u02bbuanu Pali Lookout",
"Ka\u02bbena Point",                    
"Mau\u02bbumae Ridge"
)) |>
  filter(site_code != "nnpl")

# fit_licor = read_rds("objects/fit_licor.rds")

aa = read_rds("objects/aa.rds") |>
  filter(draw == 1L) |>
  select(site_code, gsw) |>
  left_join(site, by = join_by(site_code)) |>
  add_site1() %>%
  mutate(
    A = predict(
      fit_licor,
      newdata = . |>
        mutate(aperture = "two-sided") |>
        unite("site_code_aperture", site_code, aperture)
    ) |>
      magrittr::extract(, "Estimate"),
    treatment = "amphi"
  )

licor = read_rds("processed-data/licor.rds") |>
  left_join(select(site, site, label, site_code, site_type), by = join_by(site_code)) |>
  add_site1() |>
  mutate(
    treatment = fct_recode(aperture, pseudohypo = "one-sided", 
                           amphi = "two-sided")
  )

new_licor = licor |>
  summarize(
    min_gsw = min(gsw),
    max_gsw = max(gsw),
    .by = c("site_code", "aperture", "site_type", "site_code_aperture")
  ) |>
  mutate(range_gsw = max_gsw - min_gsw) |>
  crossing(.i = seq(0, 1, 0.1)) |>
  mutate(gsw = min_gsw + .i * range_gsw) 

pred_licor = bind_cols(
  new_licor,
  predict(fit_licor, newdata = new_licor) |>
    as_tibble() |>
    select(
      A = Estimate,
      A_lower = `Q2.5`,
      A_upper = `Q97.5`
    )
) |>
  add_site1() |>
  mutate(
    treatment = fct_recode(aperture, pseudohypo = "one-sided", 
                           amphi = "two-sided")
) |>
  filter(site_code != "nnpl")

ggplot(licor,
       aes(
         gsw,
         A,
         fill = site_type,
         shape = treatment,
         linetype = treatment
       )) +
  facet_wrap(site_type ~ site1, ncol = 3, drop = TRUE, scales = "free") +
  geom_segment(
    data = aa,
    mapping = aes(xend = gsw, yend = 0)
  ) +
  geom_lineribbon(data = pred_licor, aes(ymin = A_lower, ymax = A_upper),
                  alpha = 0.5) +
  geom_point(fill = "black", color = "grey", size = 2) +
  geom_label(
    data = licor |>
      summarize(
        gsw = mean(range(gsw)),
        A = 1.1 * max(A),
        site1 = first(site1),
        site_type = first(site_type), 
        .by = "label"
      ) |>
      mutate(treatment = NA),
    aes(label = label),
    color = "black",
    size = 10 / .pt,
    label.size = 0,
    alpha = 0.5,
    parse = FALSE
  ) +
  scale_fill_manual(values = c("tomato", "steelblue"), name = "habitat") +
  scale_shape_manual(values = c(21, 22)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  xlab(expression(paste(italic(g)[sw], " [mol ", m ^ -2 ~ s ^ -1, "]"))) +
  ylab(expression(paste(
    italic(A), " [", mu, "mol ", m ^ -2 ~ s ^ -1, "]"
  ))) +
  # xlim(0, 0.5) +
  # ylim(0, 40) +
  theme_classic() +
  theme(
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 11),
    legend.position = "top",
    legend.direction = "vertical",
    panel.border = element_rect(fill = NA),
    panel.grid.major = element_line(color = "grey75", linewidth = 0.25),
    strip.text.x = element_blank()
  ) 

ggsave("figures/licor.pdf", width = 6.5, height = 9, device = cairo_pdf)

