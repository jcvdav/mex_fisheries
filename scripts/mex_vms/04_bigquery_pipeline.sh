#!/bin/bash
bq query --use_legacy_sql=false < pipeline_1_segmenter.sql
bq query --use_legacy_sql=false < pipeline_2_segment_info.sql

date >> ./data/mex_vms/bq_pipeline.log
