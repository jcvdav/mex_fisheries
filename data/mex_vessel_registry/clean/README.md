# Complete Vessel Registry Data

##About 
This repository contains the complete vessel registry data for Mexico, combining both small-scale and large-scale vessels. The data is cleaned and standardized for ease of use in analysis.

###Column Descriptions
- `eu_rnpa`: Character. Economic Unit RNPA (Registro Nacional de Pesca y Acuacultura) - Unique 10-digit identifier for the economic unit.
- `eu_name`: Character. Name of the Economic Unit.
- `vessel_rnpa`: Character. Vessel RNPA - Unique 8-digit identifier for the vessel.
- `vessel_name`: Character. Name of the vessel.
- `owner_rnpa`: Character. Owner RNPA - Unique 10-digit identifier for the vessel owner.
- `owner_name`: Character. Name of the vessel owner.
- `hull_identifier`: Character. Unique identifier for the vessel's hull.
- `finfish`: Numeric. Indicator if the vessel targets finfish (1 = Yes, 0 = No).
- `sardine`: Numeric. Indicator if the vessel targets sardine (1 = Yes, 0 = No).
- `shark`: Numeric. Indicator if the vessel targets shark (1 = Yes, 0 = No).
- `shrimp`: Numeric. Indicator if the vessel targets shrimp (1 = Yes, 0 = No).
- `tuna`: Numeric. Indicator if the vessel targets tuna (1 = Yes, 0 = No).
- `other_species`: Numeric. Indicator if the vessel targets other species (1 = Yes, 0 = No).
- `state`: Character. State where the vessel is registered.
- `home_port`: Character. Home port of the vessel.
- `construction_year`: Numeric. Year the vessel was constructed.
- `hull_material`: Character. Material of the vessel's hull.
- `preservation_system`: Character. Type of preservation system used on the vessel.
- `trawler`: Numeric. Indicator if the vessel is a trawler (1 = Yes, 0 = No).
- `purse_seine`: Numeric. Indicator if the vessel uses purse seine gear (1 = Yes, 0 = No).
- `longline`: Numeric. Indicator if the vessel uses longline gear (1 = Yes, 0 = No).
- `other_gear`: Numeric. Indicator if the vessel uses other types of gear (1 = Yes, 0 = No).
- `detection_gear`: Character. Type of detection gear used by the vessel.
- `vessel_type`: Character. Type of vessel (fishing, transport, etc.).
- `vessel_length_m`: Numeric. Length of the vessel in meters.
- `vessel_beam_m`: Numeric. Beam (width) of the vessel in meters.
- `vessel_height_m`: Numeric. Height of the vessel in meters.
- `vessel_draft_m`: Numeric. Draft of the vessel in meters.
- `vessel_gross_tonnage`: Gross tonnage of the vessel.
- `captain_num`: Numeric. Number of captains associated with the vessel.
- `engineer_num`: Numeric. Number of engineers associated with the vessel.
- `s_fisher_num`: Numeric. Number of fishers associated with the vessel.
- `fisher_num`: Numeric. Number of fishers associated with the vessel.
- `sfc_gr_kwh`: Numeric. Specific fuel consumption in grams per kilowatt-hour.
- `engine_power_hp`: Numeric. Engine power in horsepower.
- `imputed_engine_power`: Boolean. Indicates if the engine power was imputed (TRUE/FALSE).
- `design_speed_kt`: Numeric. Design speed of the vessel in knots.
- `brand`: Character. Brand of the vessel's engine.
- `model`: Character. Model of the vessel's engine.
- `fuel_type`: Character. Type of fuel used by the vessel (Diesel, Gasoline).
- `fleet`: Character. Fleet type (small scale, large scale).
- `engine_power_kw`: Numeric. Engine power in kilowatts.