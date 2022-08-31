#!/bin/bash
# Set path
export PROJECT_PATH="/Volumes/GoogleDrive/Shared drives/emlab/projects/current-projects/mex-fisheries"

# Upload all local csv files to GCS Bucket
gsutil cp "$PROJECT_PATH"/processed_data/MEX_VMS/*.csv gs://mex_fisheries/MEX_VMS

# Create a partitioned table in Big Query
#bq rm -f -t emlab-gcp:mex_fisheries.mex_vms_v_20220323
bq mk --table \
--schema src:STRING,name:STRING,vessel_rnpa:STRING,port:STRING,economic_unit:STRING,datetime:DATETIME,lat:FLOAT,lon:FLOAT,speed:NUMERIC,course:INTEGER,year:INTEGER,month:INTEGER \
--time_partitioning_field datetime \
--time_partitioning_type YEAR \
--description "Mexican VMS data" \
emlab-gcp:mex_fisheries.mex_vms_v_20220323

# Upload from GCS bcket to Big Query table
bq load \
--source_format=CSV \
--skip_leading_rows=1 \
--replace \
emlab-gcp:mex_fisheries.mex_vms_v_20220323 \
gs://mex_fisheries/MEX_VMS/MEX_VMS*.csv

# Save breadcrumb
date >> scripts/vms/upload.log

