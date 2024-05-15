#!/bin/bash
# Set path
export PROJECT_PATH="/Users/juancarlosvillasenorderbez/GitHub/data_mex_fisheries/data/"

# Upload local csv file to GCS Bucket
gsutil cp "$PROJECT_PATH"mex_vessel_registry/clean/complete_vessel_registry.csv gs://mex_fisheries/

# Make a table
bq mk --table \
--schema eu_rnpa:STRING,eu_name:STRING,vessel_rnpa:STRING,vessel_name:STRING,owner_rnpa:STRING,owner_name:STRING,hull_identifier:STRING,finfish:INTEGER,sardine:INTEGER,shark:INTEGER,shrimp:INTEGER,tuna:INTEGER,others:INTEGER,state:STRING,home_port:STRING,construction_year:INTEGER,hull_material:STRING,preservation_system:STRING,gear_type:STRING,detection_gear:STRING,vessel_type:STRING,vessel_length_m:NUMERIC,vessel_beam_m:NUMERIC,vessel_height_m:NUMERIC,vessel_draft_m:NUMERIC,vessel_gross_tonnage:NUMERIC,captain_num:INTEGER,engineer_num:INTEGER,s_fisher_num:INTEGER,fisher_num:INTEGER,sfc_gr_kwh:NUMERIC,engine_power_hp:FLOAT,engine_power_kw:FLOAT,imputed_engine_power:STRING,engine_power_bin_hp:NUMERIC,design_speed_kt:FLOAT,brand:STRING,model:STRING,fuel_type:STRING,fleet:STRING \
--description "Vessel registry" \
mex-fisheries:mex_vms.vessel_info_v_20230803

bq load \
--source_format=CSV \
--skip_leading_rows=1 \
--replace \
mex-fisheries:mex_vms.vessel_info_v_20230803 \
gs://mex_fisheries/complete_vessel_registry.csv

# Save breadcrumb
date >> ../../data/mex_vessel_registry/upload.log
