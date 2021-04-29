#!/bin/bash
# Upload all local csv files to GCS Bucket
gsutil cp "$PROJECT_PATH"/processed_data/MEX_VMS/*.csv gs://mex_fisheries/MEX_VMS

# Create a partitioned table in Big Query
bq rm -f -t emlab-gcp:mex_fisheries.mex_vms
bq mk --table \
--schema name:STRING,rnpa:STRING,port:STRING,economic_unit:STRING,datetime:DATETIME,lat:FLOAT,lon:FLOAT,speed:NUMERIC,course:INTEGER,year:INTEGER,month:INTEGER \
--time_partitioning_field datetime \
--time_partitioning_type YEAR \
--description "Mexican VMS data, with some caveats" \
emlab-gcp:mex_fisheries.mex_vms

# Upload from GCS bcket to Big Query table
bq load \
--source_format=CSV \
--skip_leading_rows=1 \
--replace \
emlab-gcp:mex_fisheries.mex_vms \
gs://mex_fisheries/MEX_VMS/MEX_VMS_*.csv

# Save breadcrumb
date >> scripts/vms/upload.log

