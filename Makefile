# This is not an optimal makefile, roduct of the fact that we (emLab)
# keep our central data resources in a shared google drive. The location
# of the files (the path itself) changes depending on the machine. Therefore
# I use a series of breadcrumbs (ending in .log) that keep track of file status

# status of data on GBC and GCS
upload.log: scripts/vms/03_upload_vms_files.sh scripts/vms/clean.log
	cd $(<D);sh $(<F)

# Status of clean data
scripts/vms/clean.log: scripts/vms/02_clean_vms_files.R scripts/vms/csv.log
	cd $(<D);Rscript $(<F)

# Status of csv data (between raw and clean)
scripts/vms/csv.log: scripts/vms/01_convert_excel_to_csv.R scripts/vms/raw.log
	cd $(<D);Rscript $(<F)

# draw makefile dag
makefile-dag.png: Makefile
	make -Bnd | make2graph | dot -Tpng -Gdpi=300 -o workflow.png