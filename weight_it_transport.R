.libPaths("/home/jfhawkin/software/miniforge3/envs/r_env/lib/R/library")
library(WeightIt)
library(tidyverse)
library(arrow)
library(DescTools)

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_diversity'] = transport_df['d2b_e5mixa']

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_cbps <- weightit(treat_diversity ~ med_dwelling_age + w_p_lowwag + pct_ao0 + annual_ghg + vmt_per_wo, data = transport_df, method = "cbps"))
summary(W_cbps)

(W_bart <- weightit(treat_diversity ~ med_dwelling_age + w_p_lowwag + pct_ao0 + annual_ghg + vmt_per_wo, data = transport_df, method = "bart"))
summary(W_bart)

(W_ebal <- weightit(treat_diversity ~ med_dwelling_age + w_p_lowwag + pct_ao0 + annual_ghg + vmt_per_wo, data = transport_df, method = "ebal", moments = 2, d.moments = 3))
summary(W_ebal)

(W_gbm <- weightit(treat_diversity ~ med_dwelling_age + w_p_lowwag + pct_ao0 + annual_ghg + vmt_per_wo, data = transport_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_transport_diversity.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_distance'] = transport_df['d4a']

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_cbps <- weightit(treat_distance ~ med_dwelling_age + w_p_lowwag + vmt_per_wo + annual_ghg, data = transport_df, method = "cbps"))
summary(W_cbps)

(W_bart <- weightit(treat_distance ~ med_dwelling_age + w_p_lowwag + vmt_per_wo + annual_ghg, data = transport_df, method = "bart"))
summary(W_bart)

(W_ebal <- weightit(treat_distance ~ med_dwelling_age + w_p_lowwag + vmt_per_wo + annual_ghg, data = transport_df, method = "ebal", moments = 2, d.moments = 3))
summary(W_ebal)

(W_gbm <- weightit(treat_distance ~ med_dwelling_age + w_p_lowwag + vmt_per_wo + annual_ghg, data = transport_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_transport_distance.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_distance'] = transport_df['d4a']
transport_df <- transport_df %>%
  mutate(treat_distance = if_else(treat_distance == 0, 1, treat_distance))
transport_df <- transport_df %>%
  mutate(treat_distance = if_else(treat_distance == -99999, 1, treat_distance))
transport_df$trans_distance_log <- log(transport_df$treat_distance)

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_cbps <- weightit(trans_distance_log ~ med_dwelling_age + w_p_lowwag + vmt_per_wo + annual_ghg, data = transport_df, method = "cbps"))
summary(W_cbps)

(W_bart <- weightit(trans_distance_log ~ med_dwelling_age + w_p_lowwag + vmt_per_wo + annual_ghg, data = transport_df, method = "bart"))
summary(W_bart)

(W_ebal <- weightit(trans_distance_log ~ med_dwelling_age + w_p_lowwag + vmt_per_wo + annual_ghg, data = transport_df, method = "ebal", moments = 2, d.moments = 3))
summary(W_ebal)

(W_gbm <- weightit(trans_distance_log ~ med_dwelling_age + w_p_lowwag + vmt_per_wo + annual_ghg, data = transport_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_transport_distance_log.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_destination'] = transport_df['d5ar'] /10^5

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_cbps <- weightit(treat_destination ~ med_dwelling_age + w_p_lowwag + pct_ao0 + vmt_per_wo + annual_ghg + avg_hh_size, data = transport_df, method = "cbps"))
summary(W_cbps)

(W_bart <- weightit(treat_destination ~ med_dwelling_age + w_p_lowwag + pct_ao0 + vmt_per_wo + annual_ghg + avg_hh_size, data = transport_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(treat_destination ~ med_dwelling_age + w_p_lowwag + pct_ao0 + vmt_per_wo + annual_ghg + avg_hh_size, data = transport_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(treat_destination ~ med_dwelling_age + w_p_lowwag + pct_ao0 + vmt_per_wo + annual_ghg + avg_hh_size, data = transport_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_transport_destination.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_destination'] = transport_df['d5ar'] /10^5
transport_df <- transport_df %>%
  mutate(treat_destination = if_else(treat_destination == 0, 1, treat_destination))
transport_df$trans_destination_log <- log(transport_df$treat_destination)

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_cbps <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + pct_ao0 + vmt_per_wo + annual_ghg + avg_hh_size, data = transport_df, method = "cbps"))
summary(W_cbps)

(W_bart <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + pct_ao0 + vmt_per_wo + annual_ghg + avg_hh_size, data = transport_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + pct_ao0 + vmt_per_wo + annual_ghg + avg_hh_size, data = transport_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(trans_destination_log ~ med_dwelling_age + w_p_lowwag + pct_ao0 + vmt_per_wo + annual_ghg + avg_hh_size, data = transport_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_transport_destination_log.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_design'] = transport_df['d2b_e5mixa']

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_cbps <- weightit(treat_design ~ med_dwelling_age + annual_ghg + vmt_per_wo + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(treat_design ~ med_dwelling_age + annual_ghg + vmt_per_wo + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(treat_design ~ med_dwelling_age + annual_ghg + vmt_per_wo + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(treat_design ~ med_dwelling_age + annual_ghg + vmt_per_wo + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_transport_design.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_density'] = transport_df['d1a']
transport_df$treat_density_wins <- Winsorize(transport_df$treat_density, val = quantile(transport_df$treat_density, probs = c(0.05, 0.95), na.rm = FALSE))

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_cbps <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_transport_density.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_density'] = transport_df['d1a']
transport_df$treat_density_wins <- Winsorize(transport_df$treat_density, val = quantile(transport_df$treat_density, probs = c(0.05, 0.95), na.rm = FALSE))

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_super <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "super",
                     SL.library = c("SL.glm", "SL.stepAIC",
                                    "SL.glm.interaction"))) 
summary(W_super)

(W_npcbps <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "npcbps")) 
summary(W_npcbps)

(W_optweight <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "optweight"))
summary(W_optweight)

# Get all object names starting with the prefix
obj_names <- ls(pattern = "^W")

# Save them to an .RData file
save(list = obj_names, file = "/work/hawkins_lab/vulcan/results/weight_it_transport_density-V3.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_density'] = transport_df['d1a']
transport_df <- transport_df %>%
  mutate(treat_density = if_else(treat_density == 0, 1, treat_density))
transport_df$trans_density_log <- log(transport_df$treat_density)

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_super <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "super",
                     SL.library = c("SL.glm", "SL.stepAIC",
                                    "SL.glm.interaction"))) 
summary(W_super)

(W_npcbps <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "npcbps")) 
summary(W_npcbps)

(W_optweight <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "optweight"))
summary(W_optweight)

# Get all object names starting with the prefix
obj_names <- ls(pattern = "^W")

# Save them to an .RData file
save(list = obj_names, file = "/work/hawkins_lab/vulcan/results/weight_it_transport_density-V3_log.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_density'] = transport_df['d1a']
transport_df$treat_density_wins <- Winsorize(transport_df$treat_density, val = quantile(transport_df$treat_density, probs = c(0.05, 0.95), na.rm = FALSE))

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_cbps <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(treat_density_wins ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "gbm"))
summary(W_gbm)

# Get all object names starting with the prefix
obj_names <- ls(pattern = "^W")

# Save them to an .RData file
save(list = obj_names, file = "/work/hawkins_lab/vulcan/results/weight_it_transport_density-V2.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_density'] = transport_df['d1a']
transport_df <- transport_df %>%
  mutate(treat_density = if_else(treat_density == 0, 1, treat_density))
transport_df$trans_density_log <- log(transport_df$treat_density)
transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_cbps <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "gbm"))
summary(W_gbm)

# Get all object names starting with the prefix
obj_names <- ls(pattern = "^W")

# Save them to an .RData file
save(list = obj_names, file = "/work/hawkins_lab/vulcan/results/weight_it_transport_density-V2_log.RData")

# Clear workspace and start the next set of models
rm(list = ls())

tran_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_ONR_epa_climate.parquet'
transport_df = read_parquet(tran_par_file)

# Transportation treatment
transport_df['treat_density'] = transport_df['d1a']
transport_df <- transport_df %>%
  mutate(treat_density = if_else(treat_density == 0, 1, treat_density))
transport_df$trans_density_log <- log(transport_df$treat_density)

transport_df <- transport_df %>%
  fill(c(med_dwelling_age,w_p_lowwag,gasprice,p_highschool,pct_ao0,stc2erta,avg_hh_size,vmt_per_wo,annual_ghg), .direction = "down")

(W_cbps <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "bart")) 
summary(W_bart)

(W_ebal <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(trans_density_log ~ med_dwelling_age + w_p_lowwag + gasprice + p_highschool + pct_ao0 + stc2erta + avg_hh_size, data = transport_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_transport_density_log.RData")
