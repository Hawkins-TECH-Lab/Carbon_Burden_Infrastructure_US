library(WeightIt)
library(tidyverse)
library(arrow)
library(DescTools)

res_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_RES_epa_climate.parquet'
residential_df = read_parquet(res_par_file)

# Residential treatment
residential_df['treat_density'] = residential_df['d1a']
residential_df$treat_density_wins <- Winsorize(residential_df$treat_density, val = quantile(residential_df$treat_density, probs = c(0.05, 0.95), na.rm = FALSE))

residential_df <- residential_df %>%
  fill(c(all_cdd,stc2erta,p_highschool,med_dwelling_age), .direction = "down")

(W_cbps <- weightit(treat_density_wins ~ p_highschool + med_dwelling_age + stc2erta + all_cdd, data = residential_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(treat_density_wins ~ p_highschool + med_dwelling_age + stc2erta + all_cdd, data = residential_df, method = "bart",
                    method.args = list(ntree = 25)))
summary(W_bart)

(W_ebal <- weightit(treat_density_wins ~ p_highschool + med_dwelling_age + stc2erta + all_cdd, data = residential_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(treat_density_wins ~ p_highschool + med_dwelling_age + stc2erta + all_cdd, data = residential_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_residential_density.RData")

# Clear workspace and start the next set of models
rm(list = ls())

res_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_RES_epa_climate.parquet'
residential_df = read_parquet(res_par_file)

# Residential treatment
residential_df['treat_density'] = residential_df['d1a']
residential_df <- residential_df %>%
  mutate(treat_density = if_else(treat_density == 0, 1, treat_density))
residential_df$res_density_log <- log(residential_df$treat_density)

residential_df <- residential_df %>%
  fill(c(all_cdd,stc2erta,p_highschool,pct_ao0), .direction = "down")

(W_cbps <- weightit(res_density_log ~ p_highschool + med_dwelling_age + stc2erta + all_cdd, data = residential_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(res_density_log ~ p_highschool + med_dwelling_age + stc2erta + all_cdd, data = residential_df, method = "bart",
                    method.args = list(ntree = 25)))
summary(W_bart)

(W_ebal <- weightit(res_density_log ~ p_highschool + med_dwelling_age + stc2erta + all_cdd, data = residential_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(res_density_log ~ p_highschool + med_dwelling_age + stc2erta + all_cdd, data = residential_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_residential_density_log.RData")

# Clear workspace and start the next set of models
rm(list = ls())

res_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_RES_epa_climate.parquet'
residential_df = read_parquet(res_par_file)

# Residential treatment
residential_df['treat_diversity'] = residential_df['d2b_e5mixa']

(W_cbps <- weightit(treat_diversity ~ stc2erta + all_cdd + p_highschool + med_dwelling_age + w_p_lowwag, data = residential_df, method = "cbps")) 
summary(W_cbps)

(W_bart <- weightit(treat_diversity ~ stc2erta + all_cdd + p_highschool + med_dwelling_age + w_p_lowwag, data = residential_df, method = "bart",
                    method.args = list(ntree = 25)))
summary(W_bart)

(W_ebal <- weightit(treat_diversity ~ stc2erta + all_cdd + p_highschool + med_dwelling_age + w_p_lowwag, data = residential_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)

(W_gbm <- weightit(treat_diversity ~ stc2erta + all_cdd + p_highschool + med_dwelling_age + w_p_lowwag, data = residential_df, method = "gbm"))
summary(W_gbm)

save.image("/work/hawkins_lab/vulcan/results/weight_it_residential_diversity.RData")
