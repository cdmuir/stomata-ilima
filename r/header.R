rm(list = ls())

library(brms)
library(checkmate)
library(cowplot)
library(dplyr)
library(forcats)
library(ggdist)
library(ggplot2)
library(ggpp)
library(ggpubr)
library(glue)
library(gridExtra)
library(magrittr)
library(photosynthesis)
library(purrr)
library(readr)
library(rstatix)
library(stringr)
library(tidybayes)
library(tidyr)

theme_set(theme_cowplot())

source("r/functions.R")

# Scale:
# 1024 pixels / 1089.16 um = 0.9401741 pixels / um
# images are 1089.16 * 816.87 um = 889702.1 um ^ 2 = 0.8897021 mm ^ 2
# 1024 * 768 pixels = 786432 ^ 2
pixels_per_um = 1024 / 1089.16
pixels2_per_mm2 = (1024 * 768) / (1089.16 * 816.87) # == pixels_per_um^2
image_area_mm2 = 0.8897021