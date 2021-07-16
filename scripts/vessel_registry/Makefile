upload.log: scripts/vessel_registry/04_upload_registry_files.sh scripts/vessel_registry/registry.log
	cd $(<D);sh $(<F)

scripts/vessel_registry/registry.log: scripts/vessel_registry/03_combine_vessel_registries.sh scripts/vessel_registry/ls.log scripts/vessel_registry/ss.log
	cd $(<D);Rscript $(<F)
	
scripts/vessel_registry/ls.log: scripts/vessel_registry/01_large_scale_vessel_registry.R
	cd $(<D);Rscript $(<F)
	
scripts/vessel_registry/ss.log: scripts/vessel_registry/02_small_scale_vessel_registry.R
	cd $(<D);Rscript $(<F)
	
# draw makefile dag
makefile-dag.png: Makefile
	make -Bnd | make2graph | dot -Tpng -Gdpi=300 -o workflow.png