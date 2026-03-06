# install.packages(c("arrow", "sf"))
library(WeightIt)
library(tidyverse)
library(arrow)

elec_par_file = '/work/hawkinslab/jfhawkin/SH-BART/data/vulcan/parquet/ELC2.CO2.BG.ann.smplst.mn.2019_no_geo.parquet'
elec_df = read_parquet(elec_par_file)

# Residential electricity treatment
elec_df['treat_density'] = elec_df['d1a']
elec_df$elec_density_wins <- Winsorize(elec_df$treat_density, val = quantile(elec_df$treat_density, probs = c(0.05, 0.95), na.rm = FALSE))

elec_df <- elec_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size), .direction = "down")

(W_cbps <- weightit(elec_density_wins ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(elec_density_wins ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(elec_density_wins ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(elec_density_wins ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "gbm"))
summary(W_gbm)

(W_super <- weightit(elec_density_wins ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "super",
                     SL.library = c("SL.glm", "SL.stepAIC",
                                    "SL.glm.interaction"))) 
summary(W_super)

(W_npcbps <- weightit(elec_density_wins ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "npcbps")) 
summary(W_npcbps)

(W_optweight <- weightit(elec_density_wins ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "optweight"))
summary(W_optweight)

save.image("~/weight_it_electricity_density.RData")
