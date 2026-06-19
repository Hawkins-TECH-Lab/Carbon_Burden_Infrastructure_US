import os
import pandas as pd
import geopandas as gpd
import numpy as np
import dask_geopandas as dgpd
import pyogrio


import time
import logging
import matplotlib.pyplot as plt

pd.set_option('display.max_columns', None)

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s', handlers=[
    logging.StreamHandler(),
    logging.FileHandler("/work/hawkinslab/skarki9/SH-BART/code/residental/logs/vulcan_x_epa_v1.log", mode='w')
])

# Start time
start_time = time.time()
logging.info(f"Script execution started at {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(start_time))}.")

shapefile = '/work/hawkinslab/skarki9/SH-BART/data/vulcan/Vulcan_V3_Annual_Emissions_1741/shp/Vulcan_v3_US_annual_1km_residential_mn.shp'

logging.info(f"Reading shapefile {shapefile}...")

vulcan = gpd.read_file(shapefile)
vulcan['vulcan_id'] = vulcan.index
logging.info(f"Shapefile read successfully., {vulcan.shape}")

vulcan['vulcan_area'] = vulcan.area
vulcan = vulcan.sort_values(by='geometry')



epa_path = "/work/hawkinslab/skarki9/SH-BART/data/gis/epa-sld/smartlocationdb_4326.shp"
logging.info(f"Reading EPA shapefile {epa_path}...")

epa = gpd.read_file(epa_path, engine="pyogrio",)
logging.info(f"Read EPA shapefile, {epa.shape}")

# epa = epa[[
#     'STATEFP',
#     'COUNTYFP',
#     'geometry'
# ]].copy()

epa['STATEFP'] = epa['STATEFP'].astype(int)
epa['COUNTYFP'] = epa['COUNTYFP'].astype(int)

epa['FIPS'] = epa['STATEFP'] * 1000 + epa['COUNTYFP']

epa.drop(columns=['STATEFP', 'COUNTYFP'], inplace=True)

epa['epa_id'] = epa.index

epa.to_crs(vulcan.crs, inplace=True)
epa = epa.sort_values(by='geometry')


vulcan_ddf = dgpd.from_geopandas(vulcan[['vulcan_id', 'geometry']], npartitions=32)
epa_ddf = dgpd.from_geopandas(epa[['epa_id', 'geometry']], npartitions=32)

vxe = dgpd.sjoin(vulcan_ddf, epa_ddf, how='inner', predicate='intersects')
vxe = vxe.compute()

logging.info(f"found which Vulcan and EPA can intersect, {vxe.shape}")

# geometry is from left i.e. vulcan but still we will drop it for sake of clarity
vxe.drop(columns=['index_right', 'geometry'], inplace=True)

logging.info(f"Shape before merging {vxe.shape}")

vxe = vxe.merge(epa[['epa_id', 'geometry']], on='epa_id', how='inner')
logging.info(f"Merged vulcan with the intersecting EPA, {vxe.shape}")
vxe = vxe.merge(vulcan, on='vulcan_id', how='inner', suffixes=('_epa', '_vulcan'))
logging.info(f"Merged vulcan with the intersecting EPA, {vxe.shape}")
vxe.rename(columns={'geometry': 'geometry_vulcan'}, inplace=True)


logging.info(f"Shape after merging {vxe.shape}")

def calculate_geom_intersection(row):
    try:
        intersection = row['geometry_vulcan'].intersection(row['geometry_epa'])
    except Exception as e:
        logging.error(f"Error calculating intersection: {e}")
        logging.error(f"Row: {row}")
        return np.nan

    if intersection.is_empty:
        return np.nan

    return intersection

def find_intersects(row):
    try:
        return row['geometry_vulcan'].intersects(row['geometry_epa'])
    except Exception as e:
        return np.nan
    
vxe_dgdf = dgpd.from_geopandas(vxe, npartitions=256)

vxe_dgdf['geometry_intersection'] = vxe_dgdf.apply(lambda row: calculate_geom_intersection(row), axis=1, meta=('x', 'object'))
logging.info(f"Calculated geometry intersection")

vxe_computed = vxe_dgdf.compute()




logging.info(f"changing crs of geom_vulcan and geom_epa and geom_inter to vulcan custom that will give area in m^2")

# load original vulcan shapefile
shapefile = '/Users/sagunkarki/Desktop/SH-BART/data/vulcan/Vulcan_V3_Annual_Emissions_1741/shp/Vulcan_v3_US_annual_1km_residential_mn.shp'
logging.info(f"Reading shapefile {shapefile}...")
vulcan = gpd.read_file(shapefile)



vxe_computed = gpd.GeoDataFrame(vxe_computed, geometry='geometry_intersection', crs=vulcan.crs)
vxe_computed['intersection_area'] = vxe_computed.area

logging.info(f"Calculated intersection area and what percentage of vulcan area it is")
vxe_computed['intersection_area_ratio_vulcan'] = vxe_computed['intersection_area'] / vxe_computed['vulcan_area']

logging.info(f"Distributing DN based on intersection area ratio")
vxe_computed['DN_weighted'] = vxe_computed['DN'] * vxe_computed['intersection_area_ratio_vulcan']

logging.info(f"Saving vxe computed for maual inspection")
vxe_computed.to_parquet('out/vxe_computed.parquet')





logging.info("Saving interscection file for visualization")

vxe_intersection_subset = vxe_computed[['vulcan_id', 'epa_id', 'intersection_area', 'intersection_area_ratio_vulcan', 'DN', 'DN_weighted', 'geometry_intersection']].copy()
vxe_intersection_subset.rename(columns={'geometry_intersection': 'geometry', 'intersection_area_ratio_vulcan': 'ratio_i_v'}, inplace=True) 
vxe_intersection_subset = gpd.GeoDataFrame(vxe_intersection_subset)
vxe_intersection_subset.to_crs = vulcan.crs

vxe_intersection_subset.to_file('out/vxe_intersection_subset.shp')




logging.info("dropping geometry column of vulcan and epa as we already have their area")
vxe_computed.drop(columns=['geometry_vulcan', 'geometry_epa'], inplace=True)

logging.info(f"Aggregrating on epa zones")
df_final = vxe_computed.groupby('epa_id')['DN_weighted'].sum().reset_index().rename(columns={'DN_weighted': 'DN_weighted_sum'})

logging.info(f"Final dataframe, {df_final.shape}")




df_final = df_final.merge(epa, on='epa_id', how='inner')
logging.info(f"Merged with EPA shapefile, {df_final.shape}")

df_final = gpd.GeoDataFrame(df_final, geometry='geometry', crs=vulcan.crs)




logging.info(f"Exporting Final df to shapefile")
df_final.to_file('/work/hawkinslab/skarki9/SH-BART/code/residental/out/df_final/vulcan_x_epa.shp')
