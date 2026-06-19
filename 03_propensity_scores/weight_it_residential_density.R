# install.packages(c("arrow", "sf"))
library(WeightIt)
library(tidyverse)
library(arrow)
library(DescTools)

res_par_file = '/work/hawkinslab/jfhawkin/SH-BART/data/vulcan/parquet/vulcan_x_epa_residential_mn_2015_climate_no_geo.parquet'
residential_df = read_parquet(res_par_file)

# Residential treatment
residential_df['treat_density'] = residential_df['d1a']
residential_df$treat_density_wins <- Winsorize(residential_df$treat_density, val = quantile(residential_df$treat_density, probs = c(0.05, 0.95), na.rm = FALSE))

residential_df <- residential_df %>%
  fill(c(all_cdd,stc2erta,p_highschool,pct_ao0), .direction = "down")

(W_cbps <- weightit(treat_density_wins ~ p_highschool + pct_ao0 + stc2erta + all_cdd, data = residential_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(treat_density_wins ~ p_highschool + pct_ao0 + stc2erta + all_cdd, data = residential_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(treat_density_wins ~ p_highschool + pct_ao0 + stc2erta + all_cdd, data = residential_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(treat_density_wins ~ p_highschool + pct_ao0 + stc2erta + all_cdd, data = residential_df, method = "gbm"))
summary(W_gbm)

save.image("~/weight_it_residential_density.RData")
