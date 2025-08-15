#!/bin/bash
# Set path
export PROJECT_PATH="/Users/jcvd/GitHub/mex_fisheries/data/"

# Upload local csv file to GCS Bucket
gsutil cp "$PROJECT_PATH"mex_vessel_registry/clean/complete_vessel_registry.csv gs://mex_vessel_registry/

# Make a table
bq mk --table \
--schema eu_rnpa:STRING,eu_name:STRING,vessel_rnpa:STRING,vessel_name:STRING,owner_rnpa:STRING,owner_name:STRING,hull_identifier:STRING,target_species:STRING,target_finfish:INTEGER,target_sardine:INTEGER,target_shark:INTEGER,target_shrimp:INTEGER,target_tuna:INTEGER,target_other:INTEGER,gear_type:STRING,gear_trawler:INTEGER,gear_purse_seine:INTEGER,gear_longline:INTEGER,gear_other:INTEGER,state:STRING,home_port:STRING,construction_year:INTEGER,hull_material:STRING,preservation_system:STRING,detection_gear:STRING,vessel_type:STRING,vessel_length_m:NUMERIC,vessel_beam_m:NUMERIC,vessel_height_m:NUMERIC,vessel_draft_m:NUMERIC,vessel_gross_tonnage:NUMERIC,captain_num:INTEGER,engineer_num:INTEGER,s_fisher_num:INTEGER,fisher_num:INTEGER,main_engines_n:NUMERIC,main_engine_power_hp:FLOAT,auxiliary_engines_n:NUMERIC,auxiliary_engine_power_hp:FLOAT,fuel_type:STRING,fleet:STRING \
--description "Vessel registry" \
mex-fisheries:mex_vms.vessel_info_v_20250815

bq load \
--source_format=CSV \
--skip_leading_rows=1 \
--replace \
mex-fisheries:mex_vms.vessel_info_v_20250815 \
gs://mex_vessel_registry/complete_vessel_registry.csv

# Save breadcrumb
date >> data/mex_vessel_registry/upload.log
