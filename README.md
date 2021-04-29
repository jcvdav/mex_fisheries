# Mexican Fisheries Data

This repository contains the code to clean and maintain the Mexican fisheries data set. This data set contains tables on Vessel Monitoring System (VMS) tracking data, vessel registry, landings, and more.

There is a [Makefile](Makefile) outlining dependencies and order of operations, and the DAG is shown here:

![](workflow.png)

## VMS data (2011 - 2021)

These data are available on three platforms:

- emLab's shared team drive (`projects/current-projects/mex-fisheries/processed_data/MEX_VMS`) with monthly `*.csv` files
- Google Cloud storage at: `gs://mex_fisheries/MEX_VMS/*` with monthly `*.csv` files
- Google BigQuery at: `emlab-gcp.mex-fisheries.mex_vms` as a partitioned table (on year)

_NOTE: For details on the data cleaning, next steps, and know issues, see the dedicated [README](/scripts/vms)._

## Vessel registry

## Landings data

## Subsidy data