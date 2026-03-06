# install.packages(c("arrow", "sf"))
library(WeightIt)
library(tidyverse)
library(arrow)

tran_par_file = '/work/hawkinslab/jfhawkin/SH-BART/data/vulcan/parquet/vulcan_x_epa_onroad_mn_2015_climate_no_geo.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_distance'] = transport_df['d4a']
transport_df <- transport_df %>%
  mutate(treat_distance = if_else(treat_distance == 0, 1, treat_distance))
transport_df <- transport_df %>%
  mutate(treat_distance = if_else(treat_distance == -99999, 1, treat_distance))
transport_df$trans_distance_log <- log(transport_df$treat_distance)

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size), .direction = "down")

(W_cbps <- weightit(trans_distance_log ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0, data = transport_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(trans_distance_log ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0, data = transport_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(trans_distance_log ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0, data = transport_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(trans_distance_log ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0, data = transport_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkinslab/jfhawkin/SH-BART/results/weight_it_transport_distance.RData")