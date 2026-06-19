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
transport_df$treat_destination_wins <- Winsorize(transport_df$treat_destination, val = quantile(transport_df$treat_destination, probs = c(0.05, 0.95), na.rm = FALSE))

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size), .direction = "down")

(W_cbps <- weightit(treat_destination_wins ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0 + stc2erta, data = transport_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(treat_destination_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(treat_destination_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(treat_destination_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "gbm"))
summary(W_gbm)

(W_super <- weightit(treat_destination_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "super",
                     SL.library = c("SL.glm", "SL.stepAIC",
                                    "SL.glm.interaction"))) 
summary(W_super)

(W_npcbps <- weightit(treat_destination_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "npcbps")) 
summary(W_npcbps)

(W_optweight <- weightit(treat_destination_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta, data = transport_df, method = "optweight"))
summary(W_optweight)

save.image("/work/hawkins_lab/vulcan/results/weight_it_transport_destination-V3.RData")
