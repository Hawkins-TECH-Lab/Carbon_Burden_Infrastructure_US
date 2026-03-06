# install.packages(c("arrow", "sf"))
library(WeightIt)
library(tidyverse)
library(arrow)
library("DescTools")

elec_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_SC2_epa_climate.parquet'
elec_df = read_parquet(elec_par_file)

# Density check - remove avg_hh_size
elec_df['treat_density'] = elec_df['d1a']
elec_df$elec_density_wins <- Winsorize(elec_df$treat_density, val = quantile(elec_df$treat_density, probs = c(0.05, 0.95), na.rm = FALSE))

elec_df <- elec_df %>%
  fill(c(med_dwelling_age,stc2erta,all_cdd,p_highschool,avg_hh_size), .direction = "down")

(W_ebal <- weightit(elec_density_wins ~ med_dwelling_age + stc2erta + all_cdd + p_highschool + avg_hh_size, data = elec_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal)
cobalt::bal.tab(W_ebal)

(W_ebal_reduced <- weightit(elec_density_wins ~ med_dwelling_age + stc2erta + all_cdd + p_highschool, data = elec_df, method = "ebal", moments = 2, d.moments = 3)) 
summary(W_ebal_reduced)
cobalt::bal.tab(W_ebal_reduced)

# Diversity check - remove pct_ao0
elec_df['treat_diversity'] = elec_df['d2b_e5mixa']

(W_cbps <- weightit(treat_diversity ~ med_dwelling_age + stc2erta + all_cdd + pct_ao0, data = elec_df, method = "cbps")) 
summary(W_cbps)
cobalt::bal.tab(W_cbps)

(W_cbps_reduced <- weightit(treat_diversity ~ med_dwelling_age + stc2erta + all_cdd, data = elec_df, method = "cbps")) 
summary(W_cbps_reduced)
cobalt::bal.tab(W_cbps_reduced)
