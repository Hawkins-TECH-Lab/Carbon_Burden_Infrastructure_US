# install.packages(c("arrow", "sf"))
library(WeightIt)
library(tidyverse)
library(arrow)
library(DescTools)

tran_par_file = '/work/hawkinslab/jfhawkin/SH-BART/data/vulcan/parquet/vulcan_x_epa_onroad_mn_2015_climate_no_geo.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_density'] = transport_df['d1a']
transport_df <- transport_df %>%
  mutate(treat_density = if_else(treat_density == 0, 1, treat_density))
transport_df$trans_density_log <- log(transport_df$treat_density)

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size), .direction = "down")


(W_super <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "super",
                    SL.library = c("SL.glm", "SL.stepAIC",
                                   "SL.glm.interaction"))) 
summary(W_super)

(W_npcbps <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "npcbps")) 
summary(W_npcbps)

(W_optweight <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "optweight"))
summary(W_optweight)

save.image("/work/hawkinslab/jfhawkin/SH-BART/results/weight_it_transport_density-V3.RData")
