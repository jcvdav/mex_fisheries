#!/bin/bash
# Upload vessel registry

gsutil cp "/Volumes/GoogleDrive/Shared drives/emlab/projects/current-projects/mex-fisheries/processed_data/MEX_VESSEL_REGISTRY/complete_vessel_registry.csv" gs://mex_fisheries/


# Make a table
bq rm -f -t emlab-gcp:mex_fisheries.vessel_info
bq mk --table \
--schema eu_rnpa:STRING,economic_unit:STRING,vessel_rnpa:STRING,vessel_name:STRING,owner_rnpa:STRING,owner_name:STRING,hull_identifier:STRING,tuna:INTEGER,sardine:INTEGER,shrimp:INTEGER,others:INTEGER,state:STRING,home_port:STRING,construction_year:INTEGER,hull_material:STRING,preservation_system:STRING,gear_type:STRING,detection_gear:STRING,vessel_type:STRING,vessel_length_m:NUMERIC,vessel_beam_m:NUMERIC,vessel_height_m:NUMERIC,vessel_draft_m:NUMERIC,vessel_gross_tonnage:NUMERIC,captain_num:INTEGER,engineer_num:INTEGER,s_fisher_num:INTEGER,fisher_num:INTEGER,sfc_gr_kwh:NUMERIC,engine_power_hp:FLOAT,imputed_engine_power:STRING,engine_power_bin_hp:NUMERIC,design_speed_kt:FLOAT,brand:STRING,model:STRING,fuel_type:STRING,fleet:STRING \
--description "Vessel registry" \
emlab-gcp:mex_fisheries.vessel_info

bq load \
--source_format=CSV \
--skip_leading_rows=1 \
--replace \
emlab-gcp:mex_fisheries.vessel_info \
gs://mex_fisheries/complete_vessel_registry.csv

date >> scripts/vessel_registry/upload.log
