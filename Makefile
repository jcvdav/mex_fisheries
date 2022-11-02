# Makefile for mex fisheries
# This is divided into four sections
# Seciton 1 - Landings data
# Section 2 - Vessel monitoring data
# Section 3 - Vessel registry
# Section 4 - Lobster concession polygons

mex_fisheries_data: mex_landings dag
mex_landings: data/mex_landings/clean/mex_annual_landings_by_vessel.rds data/mex_landings/clean/mex_monthly_landings_by_vessel.rds data/mex_landings/clean/mex_annual_landings_by_eu.rds data/mex_landings/clean/mex_monthly_landings_by_eu.rds
dag: makefile-dag.png

# Section 1: Landings data
# draw makefile dag
makefile-dag.png: Makefile
		make -Bnd | make2graph -b | dot -Tpng -Gdpi=300 -o makefile-dag.png

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
