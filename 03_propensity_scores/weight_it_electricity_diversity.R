# install.packages(c("arrow", "sf"))
library(WeightIt)
library(tidyverse)
library(arrow)

elec_par_file = '/work/hawkinslab/jfhawkin/SH-BART/data/vulcan/parquet/ELC2.CO2.BG.ann.smplst.mn.2019_no_geo.parquet'
elec_df = read_parquet(elec_par_file)

# Residential electricity treatment
elec_df['treat_diversity'] = elec_df['d2b_e5mixa']

elec_df <- elec_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size), .direction = "down")

(W_cbps <- weightit(treat_diversity ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(treat_diversity ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(treat_diversity ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(treat_diversity ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "gbm"))
summary(W_gbm)

save.image("~/weight_it_electricity_diversity.RData")
