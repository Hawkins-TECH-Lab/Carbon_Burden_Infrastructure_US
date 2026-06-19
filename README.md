# Multiscale Carbon Burden of Infrastructure in the United States

**Jason Hawkins** — Department of Civil Engineering, University of Calgary

> 🏆 *BTR7 Best Paper Award in Sustainable Transport*, npj Sustainable Mobility and Transport

Published in *npj Sustainable Mobility and Transport*. Analysis inputs and outputs are archived on [Zenodo](https://zenodo.org/records/10.5281/zenodo.18895785).

---

## Overview

This repository contains all code to reproduce the analyses in:

> Hawkins, J. (2026). Multi-Scale Carbon Burden of Infrastructure in the United States. *npj Sustainable Mobility and Transport*.

The study examines how land use and infrastructure shape fossil-fuel CO₂ (FFCO₂) emissions across local and metropolitan scales in the United States. Using Vulcan v4.0 data at 1-km resolution, it combines doubly robust Bayesian Additive Regression Tree (BART) estimators with multi-treatment spatial regression models to identify local and spillover treatment effects by emissions sector.

A key methodological contribution is treating transportation emissions as **production-based** — capturing the *infrastructure carbon burden* placed on communities rather than household-attributed travel demand — and introducing the concept of **hosted emissions** to surface environmental justice dimensions of urban infrastructure.

---

## Key Findings

- **Transportation:** Roadway network density (facility miles/sq mi) is a strong negative predictor of hosted transportation FFCO₂ (ATE: −2.69 tFFCO₂ per capita). Spatial models show transport processes operate at a ~10 km commuting-shed scale (Moran's I reduced from 0.384 → 0.174 in the preferred SLX+SEM specification).
- **Residential electricity:** Local population density is associated with approximately −6.8% per-capita FFCO₂ per 1 SD increase; metropolitan-scale density effects are weak and statistically insignificant.
- **Residential non-electricity energy:** Local density is associated with approximately −12.0% per-capita FFCO₂ per 1 SD increase, consistent with compact housing reducing heating and cooling loads.
- **Neighboring land-use diversity** exceeds local diversity in its effect on transportation emissions (spillover coefficient 0.209 vs. direct 0.124), suggesting policy should target 10 km commuting-shed clusters rather than isolated block-level interventions.

---

## Repository Structure

All scripts are in the root directory. The analysis proceeds in the numbered sequence below.

### Data Processing (Python — Jupyter Notebooks)

| Notebook | Description |
|---|---|
| `0_scope2_processing.ipynb` | Process Vulcan v4.0 Scope 2 (consumption-based electricity) emissions |
| `1_vulcan_processing.ipynb` | Areal interpolation of Vulcan Scope 1 gridcells to census block groups (CBGs) |
| `1_join_data.ipynb` | Join Vulcan emissions with EPA Smart Location Database CBG variables |
| `2_climate_co2_grid_processing.ipynb` | Process NOAA climate and eGrid emissions factor data |
| `cbsa_processing.ipynb` | Aggregate CBG variables to core-based statistical area (CBSA) metropolitan scale |

### Exploratory & Confounder Analysis (Python — Jupyter Notebooks)

| Notebook | Description |
|---|---|
| `3_correlation_analysis.ipynb` | Correlation heatmaps for confounder variable screening |
| `correlation_analysis.ipynb` | Extended correlation analysis |
| `4_confounder_analysis.ipynb` | Conditional variable importance via BART (residential electricity & energy) |
| `4_confounder_analysis_transport.ipynb` | Conditional variable importance via BART (transportation) |
| `confounder_analysis.ipynb` | Confounder analysis summary |

### Confounder Models (Python — `.pyw` scripts)

| Script | Description |
|---|---|
| `confounder_model-transpo.pyw` | BART confounder model for transportation sector |
| `confounder_model-elec.pyw` | BART confounder model for residential electricity sector |
| `confounder_model-res-energy.pyw` | BART confounder model for residential non-electricity energy sector |

### Propensity Score Estimation & Balance Diagnostics (R)

GPS estimation using `WeightIt`. Each script covers one treatment–outcome combination, with multiple versions reflecting log transformations and model iterations.

**Transportation (5 treatments):**

| Script | Treatment |
|---|---|
| `weight_it_transport_density.R` / `*-V2.R` / `*-V3.R` / `*-log.R` / `*-V2-log.R` / `*-V3-log.R` | Population density |
| `weight_it_transport_diversity.R` | Land use diversity |
| `weight_it_transport_design.R` | Roadway design |
| `weight_it_transport_distance.R` / `*-log.R` | Distance to transit |
| `weight_it_transport_destination.R` / `*-V3.R` / `*-log.R` / `*-V3-log.R` | Destination accessibility |

**Residential electricity (2 treatments):**

| Script | Treatment |
|---|---|
| `weight_it_electricity_density.R` | Population density |
| `weight_it_electricity_diversity.R` | Land use diversity |
| `weight_it_electricity_robustness.R` | Robustness checks |
| `weight_it_elec.R` | Combined electricity GPS |

**Residential non-electricity energy (2 treatments):**

| Script | Treatment |
|---|---|
| `weight_it_residential_density.R` / `*-log.R` | Population density |
| `weight_it_residential_diversity.R` | Land use diversity |
| `weight_it_residential (1).R` | Combined residential GPS |

### Doubly Robust ATE Estimation (Python — Jupyter Notebooks / R)

| File | Description |
|---|---|
| `DR_Analysis_WeightIt.ipynb` | Main DR ATE estimation notebook |
| `DR_Analysis_WeightIt-tran-dens.ipynb` | Transportation × population density |
| `DR_Analysis_WeightIt-tran-div.ipynb` | Transportation × land use diversity |
| `DR_Analysis_WeightIt-tran-des.ipynb` / `*-dest.ipynb` | Transportation × roadway design / destination |
| `DR_Analysis_WeightIt-tran-dist.ipynb` | Transportation × distance to transit |
| `DR_Analysis_WeightIt-elec-dens.ipynb` | Residential electricity × population density |
| `DR_Analysis_WeightIt-elec-div.ipynb` | Residential electricity × land use diversity |
| `DR_Analysis_WeightIt-res-dens.ipynb` | Residential energy × population density |
| `DR_Analysis_WeightIt-res-div.ipynb` | Residential energy × land use diversity |
| `check_dr_results.ipynb` | DR results diagnostics and validation |
| `dr_graphs.ipynb` | Reproduce Figure 2, 3, and 4 (ATE posterior distributions) |

### Joint Spatial Regression (Python — Jupyter Notebooks)

| Notebook | Description |
|---|---|
| `ols_outcome_analysis.ipynb` | Base OLS joint treatment models |
| `ols_outcome_analysis-SEV (1).ipynb` | OLS with spatial eigenvectors |
| `ols_outcome_analysis-SAR.ipynb` / `*-V2.ipynb` / `*-V3.ipynb` | Spatial autoregressive specifications |
| `ols_outcome_analysis-SEM.ipynb` | SEM specifications |
| `ols_outcome_analysis-SEM-Dk.ipynb` | SLX+SEM with 10 km inverse-distance weights (preferred specification) |
| `build_spatial_eigen_vectors.ipynb` | Construct spatial eigenvectors for residual autocorrelation control |
| `Moran_I_PyMC_Models.ipynb` | Bayesian posterior estimation of Moran's I statistics |

### Diagnostics & Supporting Files

| File | Description |
|---|---|
| `check_ps_results-V2.qmd` | Propensity score balance diagnostics report (Quarto) |
| `vulcan_epa_v1.py` | Utility functions for Vulcan–EPA data handling |

---

## Data Availability

All primary data are publicly available:

| Dataset | Description | Access |
|---|---|---|
| Vulcan v4.0 (Scope 1) | 1-km FFCO₂ gridcell estimates, US, 2010–2021 | [Zenodo](https://zenodo.org/records/15446748) |
| Vulcan v4.0 (Scope 2) | CBG-scale electricity consumption emissions, 2019–2021 | [Zenodo](https://zenodo.org/records/12123469) |
| EPA Smart Location Database | CBG-level 5D land use and built form variables | [EPA](https://www.epa.gov/smartgrowth/smart-location-mapping) |
| ACS 5-Year Estimates (2018–2023) | Sociodemographic covariates by CBG | [Census Bureau](https://www.census.gov/programs-surveys/acs) |
| NOAA Climate Normals | County-level temperature, precipitation, HDD/CDD | [NOAA](https://www.ncei.noaa.gov/products/land-based-station/us-climate-normals) |
| eGrid Emissions Factors | State-level electricity grid emissions factors | [EPA eGrid](https://www.epa.gov/egrid) |

Processed analysis inputs and outputs are archived on [Zenodo](https://zenodo.org/records/10.5281/zenodo.18895785).

---

## Requirements

### Python (≥ 3.13)

```
geopandas
numpy
pandas
pysal
libpysal
esda
spreg
scipy
matplotlib
pymc
bartpy  # or equivalent BART implementation
jupyter
```

### R (≥ 4.4)

```r
install.packages(c(
  "WeightIt", "BART", "dbarts", "cobalt",
  "spdep", "spatialreg",
  "ggplot2", "dplyr", "tidyr"
))
```

The Quarto document (`check_ps_results-V2.qmd`) requires [Quarto](https://quarto.org/) ≥ 1.4.

---

## Suggested Execution Order

```
# 1. Data processing
0_scope2_processing.ipynb
1_vulcan_processing.ipynb
1_join_data.ipynb
2_climate_co2_grid_processing.ipynb
cbsa_processing.ipynb

# 2. Exploratory analysis & confounder selection
3_correlation_analysis.ipynb
4_confounder_analysis.ipynb
4_confounder_analysis_transport.ipynb
confounder_model-transpo.pyw
confounder_model-elec.pyw
confounder_model-res-energy.pyw

# 3. Propensity score estimation (R)
weight_it_transport_density-V3-log.R   # (and other weight_it_*.R scripts)
weight_it_electricity_density.R
weight_it_residential_density.R
check_ps_results-V2.qmd               # balance diagnostics

# 4. Doubly robust ATE estimation
DR_Analysis_WeightIt-tran-dens.ipynb  # (and other DR_Analysis_*.ipynb scripts)
check_dr_results.ipynb
dr_graphs.ipynb

# 5. Joint spatial regression
build_spatial_eigen_vectors.ipynb
ols_outcome_analysis.ipynb
ols_outcome_analysis-SEM-Dk.ipynb     # preferred specification
Moran_I_PyMC_Models.ipynb
```

---

## Citation

If you use this code or data, please cite:

```bibtex
@article{hawkins2025carbon,
  title   = {Multi-Scale Carbon Burden of Infrastructure in the United States},
  author  = {Hawkins, Jason},
  journal = {npj Sustainable Mobility and Transport},
  year    = {2025},
  doi     = {}
}
```

---

## Contact

Jason Hawkins — [jfhawkin@ucalgary.ca](mailto:jfhawkin@ucalgary.ca)  
[TECH Research Group](https://hawkins-tech-lab.github.io/) — Department of Civil Engineering, University of Calgary

---

## License

Code is released under the [MIT License](LICENSE). Data are subject to the terms of their respective source agencies (see Data Availability above).
