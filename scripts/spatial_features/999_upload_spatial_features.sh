#!/bin/bash
# Set path
export PROJECT_PATH="/Users/juancarlosvillasenorderbez/GitHub/data_mex_fisheries/data/"

# Upload all local csv files to GCS Bucket
gsutil cp "$PROJECT_PATH"spatial_features/clean/spatial_features.csv gs://mex_fisheries

# Delete BQ table
bq rm -f -t mex-fisheries:mex_vms.spatial_features_v_20240312

# Create a BQ table
bq mk --table \
--schema lon_center:NUMERIC,lat_center:DECIMAL,sea:INTEGER,eez:INTEGER,mpa:INTEGER,fishing_region:INTEGER,distance_from_port_m:FLOAT,distance_from_shore_m:FLOAT,depth_m:FLOAT \
--description "Spatial features" \
mex-fisheries:mex_vms.spatial_features_v_20240312

# Upload from GCS bcket to Big Query table
bq load \
--source_format=CSV \
--skip_leading_rows=1 \
--replace \
mex-fisheries:mex_vms.spatial_features_v_20240312 \
gs://mex_fisheries/spatial_features.csv

date >> ../data/spatial_features/upload.log
