# Makefile for mex fisheries
# This is divided into four sections
# Seciton 1 - Landings data
# Section 2 - Vessel monitoring data
# Section 3 - Vessel registry
# Section 4 - Spatial features
# Section 5 - Lobster concession polygons

# Main targets
mex_fisheries_data: mex_landings mex_vms mex_vessel_registry spatial_features mex_turfs
mex_landings: data/mex_landings/clean/mex_annual_landings_by_vessel.rds data/mex_landings/clean/mex_monthly_landings_by_vessel.rds data/mex_landings/clean/mex_annual_landings_by_eu.rds data/mex_landings/clean/mex_monthly_landings_by_eu.rds
mex_vms: data/mex_vms/bq_pipeline.log
mex_vessel_registry: data/mex_vessel_registry/upload.log
mex_turfs: data/concesiones/processed/all_spp_permit_and_concessions_polygons.gpkg
spatial_features: data/spatial_features/upload.log
dag: workflow.png

# Section 1: Landings data #####################################################

# SUMMARIZING ------------------------------------------------------------------
# Create monthly and annual panels by vessel and economic unit
data/mex_landings/clean/mex_annual_landings_by_vessel.rds data/mex_landings/clean/mex_monthly_landings_by_vessel.rds data/mex_landings/clean/mex_annual_landings_by_eu.rds data/mex_landings/clean/mex_monthly_landings_by_eu.rds: scripts/mex_landings/04_produce_summarized_landings.R data/mex_landings/clean/mex_landings_2000_2022.rds
		cd $(<D);Rscript $(<F)

# COMBINING --------------------------------------------------------------------
# Combine both data sets
data/mex_landings/clean/mex_landings_2000_2022.rds: scripts/mex_landings/03_combine_landings.R data/mex_landings/clean/mex_conapesca_avisos_2000_2019.rds data/mex_landings/clean/mex_conapesca_apertura_2018_2022.rds
		cd $(<D);Rscript $(<F)

# DATA CLEANING ----------------------------------------------------------------
# Landings from CONAPESCA
data/mex_landings/clean/mex_conapesca_apertura_2018_2022.rds: scripts/mex_landings/02_clean_conapesca_apertura_2018_2022.R data/mex_landings/raw/CONAPESCA_apertura/*.xlsx
		cd $(<D);Rscript $(<F)

# Landings from Stuart
data/mex_landings/clean/mex_conapesca_avisos_2000_2019.rds: scripts/mex_landings/01_clean_conapesca_avisos_2000_2019.R data/mex_landings/raw/CONAPESCA_Avisos_2000-2019/*.csv
		cd $(<D);Rscript $(<F)


# Section 2: Vessel monitoring data ############################################

# Execute BigQuery pipeline
data/mex_vms/bq_pipeline.log: scripts/mex_vms/04_bigquery_pipeline.sh data/mex_vms/upload.log scripts/mex_vms/pipeline_1_segmenter.sql scripts/mex_vms/pipeline_2_segment_info.sql data/spatial_features/upload.log
		cd $(<D);bash $(<F)

# Upload to BigQuery
data/mex_vms/upload.log: scripts/mex_vms/03_upload_vms_files.sh data/mex_vms/clean/clean.log
		cd $(<D);bash $(<F)

# Clean all vms files ----------------------------------------------------------
data/mex_vms/clean/clean.log: scripts/mex_vms/02_clean_vms_files.R data/mex_vms/raw/xls_to_csv_logs.log
		cd $(<D);Rscript $(<F)

# Convert excel to csv ---------------------------------------------------------
data/mex_vms/raw/xls_to_csv_logs.log: scripts/mex_vms/01_convert_excel_to_csv.R
		cd $(<D);Rscript $(<F)

# Section 3: Vessel registry ####################################################

data/mex_vessel_registry/upload.log: scripts/mex_vessel_registry/04_upload_registry_files.sh data/mex_vessel_registry/clean/complete_vessel_registry.csv
		cd $(<D);bash $(<F)

data/mex_vessel_registry/clean/complete_vessel_registry.csv: scripts/mex_vessel_registry/03_combine_vessel_registries.R data/mex_vessel_registry/clean/large_scale_vessel_registry.csv data/mex_vessel_registry/clean/small_scale_vessel_registry.csv
		cd $(<D);Rscript $(<F)
	
data/mex_vessel_registry/clean/small_scale_vessel_registry.csv: scripts/mex_vessel_registry/02_small_scale_vessel_registry.R
		cd $(<D);Rscript $(<F)
	
data/mex_vessel_registry/clean/large_scale_vessel_registry.csv: scripts/mex_vessel_registry/01_large_scale_vessel_registry.R
		cd $(<D);Rscript $(<F)

# Section 4: Spatial features ##################################################

data/spatial_features/upload.log: scripts/spatial_features/999_upload_spatial_features.sh data/spatial_features/clean/spatial_features.csv
		cd $(<D);bash $(<F)

data/spatial_features/clean/spatial_features.csv: scripts/spatial_features/99_combine_spatial_features.R data/spatial_features/clean/*.tif
		cd $(<D);Rscript $(<F)

data/spatial_features/clean/seas_raster.tif seas_dictionary.csv: scripts/spatial_features/01_seas_raster.R data/spatial_features/raw/GOaS_v1_20211214_gpkg/goas_v01.gpkg
		cd $(<D);Rscript $(<F)
	
data/spatial_features/clean/distance_to_shore_raster.tif: scripts/spatial_features/03_distance_to_shore_raster.R data/spatial_features/raw/land_distance/gb_land_distance.asc
		cd $(<D);Rscript $(<F)

data/spatial_features/clean/distance_to_port_raster.tif: scripts/spatial_features/04_distance_to_port_raster.R data/spatial_features/raw/port_distance/port_distance.asc
		cd $(<D);Rscript $(<F)
	
data/spatial_features/clean/depth_raster.tif: scripts/spatial_features/05_depth_raster.R data/spatial_features/raw/depth/gb_depth.asc
		cd $(<D);Rscript $(<F)

# Section 5: TURFS #############################################################

data/concesiones/processed/all_spp_permit_and_concessions_polygons.gpkg: scripts/concesiones/combine_all_polygons.R data/concesiones/processed/lobster_permit_and_concessions_polygons.gpkg data/concesiones/processed/urchin_permit_and_concessions_polygons.gpkg data/concesiones/processed/cucumber_permit_and_concessions_polygons.gpkg
		cd $(<D);Rscript $(<F)

data/concesiones/processed/lobster_permit_and_concessions_polygons.gpkg: scripts/concesiones/langosta/03_combine_lobster_polygons.R
		cd $(<D);Rscript $(<F)
		
data/concesiones/processed/urchin_permit_and_concessions_polygons.gpkg: scripts/concesiones/urchin/01_clean_urchins.R
		cd $(<D);Rscript $(<F)
		
data/concesiones/processed/cucumber_permit_and_concessions_polygons.gpkg: scripts/concesiones/pepino/01_clean_sea_cucumber.R
		cd $(<D);Rscript $(<F)
# Other components

workflow.png: Makefile
		LANG=C make -pBnd | python3 make_p_to_json.py | python3 json_to_dot.py | dot -Tpng -Gdpi=300 -o workflow.png