# Vessel Tracking Data from Mexico's Vessel Monitoring System

Data soruce:
- "Localización Y Monitoreo Satelital De Embarcaciones Pesqueras" publicado por CONAPESCA. Consultado en [https://datos.gob.mx/busca/dataset/localizacion-y-monitoreo-satelital-de-embarcaciones-pesqueras](https://datos.gob.mx/busca/dataset/localizacion-y-monitoreo-satelital-de-embarcaciones-pesqueras) el 2021-04-21.

Metadata:

```
Nombre: Nombre de la embarcación
RNP: Registro Nacional de Pesca y Acuacultura de la embarcación	
Descripción: Puerto base de la embarcación
Permisionario o concesionario: Nombre o Razón Social del permisionario o concesionario
Fecha: Fecha del reporte de posición
Latitud: Posición geográfica en relación al norte o sur expresada en grados decimales
Longitud: Posición geográfica en relación al este u oeste expresada en grados decimales	
Velocidad: Velocidad de navegación en nudos
Rumbo: Rumbo de la navegación
```

Regulation governing the use of VMS on boats:
- Norma Oficial Mexicana NOM-062-PESC-2007, Para la utilización del sistema de localización y monitoreo satelital de embarcaciones pesqueras,SECRETARIA DE AGRICULTURA, GANADERIA, DESARROLLO RURAL, PESCA Y ALIMENTACION,
          Estados Unidos Mexicanos; DOF, 24 de abril 2008, [citado el 21-04-2021];
          Disponible en versión HTML en internet: http://sidof.segob.gob.mx/notas/5033406

## Known issues
### Raw data issues
- Two files (`01-10-FEB-2018.xlsx` and `11-20-FEB-2018.xlsx`) are provided as excel files, instead of csv files
- Three files (`21-31-AGO-2014.csv`, `11-20-ENE-2018.csv`, `16-31 OCT 2020.csv`) have either corrupted or incorrect datetime values in the `Fecha` field.

### Clean data issues
- For data from `21-31-AGO-2014.csv`, `11-20-ENE-2018.csv`, `16-31 OCT 2020.csv`, there is no datetime available. There is, however, year and month data available, extracted from the file names.