# Mexican Fisheries Data

This repository contains the code to clean and maintain the Mexican fisheries data set. This data set contains tables on Vessel Monitoring System (VMS) tracking data, vessel registry, landings, and more.

There is a [Makefile](Makefile) outlining dependencies and order of operations, and the DAG is shown here:

![](workflow.png)

## VMS data (2007 - 2022 [partial])

### Sources

- [Datos abiertos](https://datos.gob.mx/busca/dataset/localizacion-y-monitoreo-satelital-de-embarcaciones-pesqueras)

### Availability

- emLab's shared team drive (`projects/current-projects/mex-fisheries/processed_data/MEX_VMS`) with monthly `*.csv` files
- Google Cloud storage at: `gs://mex_fisheries/MEX_VMS/*` with monthly `*.csv` files
- Google BigQuery at: `emlab-gcp.mex-fisheries.mex_vms` as a partitioned table (on year)

_NOTE: For details on the data cleaning, next steps, and know issues, see the dedicated [README](/scripts/vms)._

## Vessel registry

## Landings data

### Sources

- [CONAPESCA Avisos 2000-2019]()
- [CONAPESCA_apertura](https://conapesca.gob.mx/wb/cona/avisos_arribo_cosecha_produccion)
- [datos_abiertos](https://datos.gob.mx/busca/dataset/produccion-pesquera)

### Availability

- Download an [`*Rds`]() file
- Download a [`*csv`]() file

## Subsidy data

### Sources

### Availability

## Spatial features

### Sources

- [Sea: Global Oceans and Seas](https://www.marineregions.org/sources.php)
- [EEZ: Marine and land zones: the union of world country boundaries and EEZ's](https://www.marineregions.org/sources.php)
- [Distance from shore](https://gmed.auckland.ac.nz/download.html)
- [Distance from port](https://gmed.auckland.ac.nz/download.html)
- [Depth](https://gmed.auckland.ac.nz/download.html)