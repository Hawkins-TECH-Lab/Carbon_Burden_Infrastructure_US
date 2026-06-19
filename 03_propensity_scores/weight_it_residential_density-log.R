# install.packages(c("arrow", "sf"))
library(WeightIt)
library(tidyverse)
library(arrow)
library(DescTools)

res_par_file = '/work/hawkinslab/jfhawkin/SH-BART/data/vulcan/parquet/vulcan_x_epa_residential_mn_2015_climate_no_geo.parquet'
residential_df = read_parquet(res_par_file)

# Residential treatment
residential_df['treat_density'] = residential_df['d1a']
residential_df <- residential_df %>%
  mutate(treat_density = if_else(treat_density == 0, 1, treat_density))
residential_df$res_density_log <- log(residential_df$treat_density)

residential_df <- residential_df %>%
  fill(c(all_cdd,stc2erta,p_highschool,pct_ao0), .direction = "down")

(W_cbps <- weightit(res_density_log ~ p_highschool + pct_ao0 + stc2erta + all_cdd, data = residential_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(res_density_log ~ p_highschool + pct_ao0 + stc2erta + all_cdd, data = residential_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(res_density_log ~ p_highschool + pct_ao0 + stc2erta + all_cdd, data = residential_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(res_density_log ~ p_highschool + pct_ao0 + stc2erta + all_cdd, data = residential_df, method = "gbm"))
summary(W_gbm)

save.image("~/weight_it_residential_density.RData")
