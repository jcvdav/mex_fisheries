#!/bin/bash
# Set path
export PROJECT_PATH="/Users/juancarlosvillasenorderbez/GitHub/data_mex_fisheries/data/"

# Upload all local csv files to GCS Bucket
gsutil cp "$PROJECT_PATH"spatial_features/clean/spatial_features.csv gs://mex_fisheries

# Delete BQ table
bq rm -f -t emlab-gcp:mex_fisheries.spatial_features

# Create a BQ table
bq mk --table \
--schema lon_center:NUMERIC,lat_center:NUMERIC,sea:INTEGER,eez:INTEGER,distance_from_port_m:FLOAT,distance_from_shore_m:FLOAT,depth_m:FLOAT \
--description "Spatial features" \
emlab-gcp:mex_fisheries.spatial_features

# Upload from GCS bcket to Big Query table
bq load \
--source_format=CSV \
--skip_leading_rows=1 \
--replace \
emlab-gcp:mex_fisheries.spatial_features \
gs://mex_fisheries/spatial_features.csv

date >> ./data/spatial_features/upload.log
