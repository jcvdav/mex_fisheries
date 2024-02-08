#!/bin/bash
# Set path
export PROJECT_PATH="/Users/juancarlosvillasenorderbez/GitHub/data_mex_fisheries/data/"

# Upload all local csv files to GCS Bucket
gsutil cp "$PROJECT_PATH"mex_vms/clean/*.csv gs://mex_fisheries/MEX_VMS

# Create a partitioned table in Big Query
bq mk --table \
--schema src:STRING,name:STRING,vessel_rnpa:STRING,port:STRING,economic_unit:STRING,datetime:DATETIME,lat:DECIMAL,lon:DECIMAL,speed:FLOAT,course:INTEGER,year:INTEGER,month:INTEGER \
--time_partitioning_field datetime \
--time_partitioning_type YEAR \
--description "Mexican VMS data" \
emlab-gcp:mex_fisheries.mex_vms_v_20240204
# If I need to delete it, this is the command:
#bq rm -f -t emlab-gcp:mex_fisheries.mex_vms_v_20231003

# Upload from GCS bcket to Big Query table
bq load \
--source_format=CSV \
--skip_leading_rows=1 \
--replace \
emlab-gcp:mex_fisheries.mex_vms_v_20240204 \
gs://mex_fisheries/MEX_VMS/MEX_VMS*.csv

# Save breadcrumb
date >> ./data/mex_vms/upload.log

