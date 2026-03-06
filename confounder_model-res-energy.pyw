#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import geopandas as gpd
import pymc as pm
import pymc_bart as pmb
import numpy as np
import matplotlib.pyplot as plt

res_par_file = '/work/hawkins_lab/vulcan/data/vulcan/parquet/vulcan_RES_epa_climate.parquet'

res_df = gpd.read_parquet(res_par_file)

# Create columns that assign Decile numbers for each treatment variable
res_df['treat_density'] = res_df['d1a']
res_df['treat_diversity'] = res_df['d2b_e5mixa']

res_df['Decile_Density'] = pd.qcut(res_df['treat_density'], 10, labels=False)
res_df['Decile_Diversity'] = pd.qcut(res_df['treat_diversity'], 10, labels=False) 

# Fill missing values with the average of the values above and below
def fill_with_average(series):
    for i in range(1, len(series) - 1):  # Skip the first and last rows
        if pd.isna(series[i]):
            # Average of above and below values
            series.loc[i] = (series[i - 1] + series[i + 1]) / 2
    return series.values

var_list = ['p_highschool','pct_ao0','avg_hh_size',
 'med_dwelling_age','all_cdd', 'stc2erta', 'w_p_lowwag']

columns = ["Segment", "Treatment", "Decile", "Feature", "Importance"]
importance_df = pd.DataFrame(columns=columns)

def make_confounder_model(X, y, samples=1000, m=50):
    coords = {"coeffs": list(X.columns), "obs": range(len(X))}
    with pm.Model(coords=coords) as model:
        X_data = pm.Data("X", X)
        y_data = pm.Data("y", y)

        mu = pmb.BART("mu", X, y, m=m)

        sigma = pm.HalfCauchy("sigma", beta=10)

        y_pred = pm.Normal("y_pred", mu=mu, sigma=sigma, observed=y_data, dims="obs")

        idata = pm.sample(
                samples, init="adapt_diag", random_seed=105, idata_kwargs={"log_likelihood": True}
            )
    vi_results = pmb.compute_variable_importance(idata, mu, X)
    return vi_results


def get_splits(vi_results, feature_names, segment="res", treat="dens", decile=0):
    pmb.plot_variable_importance(vi_results);
    for fmt in ["png", "pdf", "svg"]:
        plt.savefig(f"./figures/variable_importance_{segment}_{treat}_{decile}.{fmt}", dpi=600, bbox_inches="tight")
    
    r2_diff = np.array([vi_results['r2_mean'][0]] + [
                vi_results['r2_mean'][i] - vi_results['r2_mean'][i - 1] for i in range(1, len(vi_results['r2_mean']))])
    r2_diff = r2_diff[np.argsort(vi_results['indices'])]
    importance_df = pd.DataFrame({"Segment": [segment] * len(feature_names), "Treatment": [treat] * len(feature_names), 
                                  "Decile":[decile]*len(feature_names), "Feature": feature_names, "Importance": r2_diff})
    return importance_df
    
for i in range(10):
    temp_df = res_df.loc[res_df['Decile_Density']==i] 
    X = temp_df.loc[:, var_list]
    y_res = temp_df["value_weig"]

    vi_results = make_confounder_model(X, y_res, samples=2000)
    temp_importance_df = get_splits(vi_results, var_list, "res_energy", "dens", i)
    importance_df = pd.concat([importance_df, temp_importance_df], ignore_index=True)
    
for i in range(10):
    temp_df = res_df.loc[res_df['Decile_Diversity']==i] 
    X = temp_df.loc[:, var_list]
    y_res = temp_df["value_weig"]

    vi_results = make_confounder_model(X, y_res, samples=2000)
    temp_importance_df = get_splits(vi_results, var_list, "res_energy", "div", i)
    importance_df = pd.concat([importance_df, temp_importance_df], ignore_index=True)
    
importance_df.to_csv("/work/hawkins_lab/vulcan/results/importance_residential.csv", index=False)