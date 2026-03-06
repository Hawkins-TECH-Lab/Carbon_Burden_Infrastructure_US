# install.packages(c("arrow", "sf"))
.libPaths("/home/jfhawkin/software/miniforge3/envs/r_env/lib/R/library")
library(WeightIt)
library(tidyverse)
library(arrow)
library(DescTools)

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_destination'] = transport_df['d5ar'] /10^5
transport_df <- transport_df %>%
  mutate(treat_destination = if_else(treat_destination == 0, 1, treat_destination))
transport_df$trans_destination_log <- log(transport_df$treat_destination)

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size), .direction = "down")

(W_cbps <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0 + stc2erta, data = transport_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "gbm"))
summary(W_gbm)

(W_super <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "super",
                     SL.library = c("SL.glm", "SL.stepAIC",
                                    "SL.glm.interaction"))) 
summary(W_super)

(W_npcbps <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "npcbps")) 
summary(W_npcbps)

(W_optweight <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "optweight"))
summary(W_optweight)

save.image("/work/hawkins_lab/vulcan/results/weight_it_transport_destination-V3_log.RData")