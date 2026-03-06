library(WeightIt)
library(tidyverse)
library(arrow)
library(DescTools)

elec_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_SC2_epa_climate.parquet'
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

save.image("/work/hawkins_lab/vulcan/results/weight_it_electricity_density.RData")

# Clear workspace and start the next set of models
rm(list = ls())

elec_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_SC2_epa_climate.parquet'
elec_df = read_parquet(elec_par_file)

# Residential electricity treatment - log
elec_df['treat_density'] = elec_df['d1a']
elec_df <- elec_df %>%
  mutate(treat_density = if_else(treat_density == 0, 1, treat_density))
elec_df$elec_density_log <- log(elec_df$treat_density)

elec_df <- elec_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size), .direction = "down")

(W_cbps <- weightit(elec_density_log ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(elec_density_log ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(elec_density_log ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(elec_density_log ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "gbm"))
summary(W_gbm)

(W_super <- weightit(elec_density_log ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "super",
                     SL.library = c("SL.glm", "SL.stepAIC",
                                    "SL.glm.interaction"))) 
summary(W_super)

(W_npcbps <- weightit(elec_density_log ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "npcbps")) 
summary(W_npcbps)

(W_optweight <- weightit(elec_density_log ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "optweight"))
summary(W_optweight)

save.image("/work/hawkins_lab/vulcan/results/weight_it_electricity_density_log.RData")

# Clear workspace and start the next set of models
rm(list = ls())

elec_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_SC2_epa_climate.parquet'
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

save.image("/work/hawkins_lab/vulcan/results/weight_it_electricity_diversity.RData")