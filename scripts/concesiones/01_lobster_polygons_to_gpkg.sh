# Process the KMZ file

# Step 1
# The original file is AREAS DE POLIGONOS DE LANGOSTA.kmz, which is actually a zip file
# I manually rename it to a ziped file
cp 'data/concesiones/raw/AREAS DE POLIGONOS DE LANGOSTA.kmz' data/concesiones/raw/langosta.kmz.zip
cp 'data/concesiones/raw/AREAS PERMISOS DE LANGOSTA.kmz' data/concesiones/raw/langosta_pts.kmz.zip

# Step 2
# Extract the ziped file
unzip data/concesiones/raw/langosta.kmz.zip -d data/concesiones/raw/pol/
unzip data/concesiones/raw/langosta_pts.kmz.zip -d data/concesiones/raw/pts

# Step 3
# Convert KML to GeoPackage
ogr2ogr \
-f "GPKG" data/concesiones/raw/lobster_concessions.gpkg \
data/concesiones/raw/pol/doc.kml

ogr2ogr \
-f "GPKG" data/concesiones/raw/lobster_concessions_pts.gpkg \
data/concesiones/raw/pts/doc.kml
