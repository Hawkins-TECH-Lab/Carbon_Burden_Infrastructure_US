# install.packages(c("arrow", "sf"))
library(WeightIt)
library(tidyverse)
library(arrow)

res_par_file = '/work/hawkinslab/jfhawkin/SH-BART/data/vulcan/parquet/vulcan_x_epa_residential_mn_2015_climate_no_geo.parquet'
residential_df = read_parquet(res_par_file)

# Residential electricity treatment
residential_df['treat_density'] = residential_df['d1a']
residential_df['treat_diversity'] = residential_df['d2b_e5mixa']

(W_cbps <- weightit(treat_diversity ~ stc2erta + all_cdd + p_highschool + w_p_lowwag, data = residential_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(treat_diversity ~ stc2erta + all_cdd + p_highschool + w_p_lowwag, data = residential_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(treat_diversity ~ stc2erta + all_cdd + p_highschool + w_p_lowwag, data = residential_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(treat_diversity ~ stc2erta + all_cdd + p_highschool + w_p_lowwag, data = residential_df, method = "gbm"))
summary(W_gbm)

save.image("~/weight_it_residential_diversity.RData")
