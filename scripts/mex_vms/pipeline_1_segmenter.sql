# Function to convert from degrees to radians
CREATE TEMP FUNCTION
  RADIANS(x FLOAT64) AS ( ACOS(-1) * x / 180 );
# BEGIN QUERY 
CREATE OR REPLACE TABLE `mex-fisheries.mex_vms.mex_vms_processed_v_20240515` # <---------------- TABLE NAME NEEDS TO BE MANUALLY UPDATED
AS
WITH all_data AS (
  SELECT
  DISTINCT
  *,
  CONCAT(year, "_", month)AS ym,
  IF(datetime IS NULL, "_datetime_missing", "") AS err,
  IF(datetime IS NULL, 1, 0) AS seq,
  CAST(FLOOR(lat / 0.05) * 0.05 AS NUMERIC) + 0.025 AS lat_center,
  CAST(FLOOR(lon / 0.05) * 0.05 AS NUMERIC) + 0.025 AS lon_center
FROM
  `mex-fisheries.mex_vms.mex_vms_v_20240515`
  WHERE lat IS NOT NULL
  AND lon IS NOT NULL
  AND lat between -30 AND 40
  AND lon between -180 AND -60
),
#
#
#
#
########
mod AS (
  SELECT
  *,
  lag(lon, 1) OVER (PARTITION BY vessel_rnpa ORDER BY seq, datetime) AS lon_lag,
  lag(lat, 1) OVER (PARTITION BY vessel_rnpa ORDER BY seq, datetime) AS lat_lag,
  lag(datetime, 1) OVER (PARTITION BY vessel_rnpa ORDER BY seq, datetime) AS datetime_lag,
  lag(ym, 1) OVER (PARTITION BY vessel_rnpa ORDER BY seq, year, month) AS ym_lag
  FROM all_data
),
#
#
#
#
########
htab AS (SELECT
    *,
    sqrt(POW(((lon - lon_lag) * 111319 * COS(RADIANS(lat))), 2) + POW(((lat - lat_lag) * 111319), 2)) AS distance_to_last_m,
    (DATETIME_DIFF(datetime, datetime_lag, MINUTE)) / 60 AS hours,
    DATETIME_DIFF(datetime, datetime_lag, MINUTE) / 60 >= 24 AS hour_change,
    ym != ym_lag AS ym_change,
FROM mod),
#
#
#
#
########
step AS (
  SELECT
  *,
  IF((hour_change) OR (ym_change AND datetime IS NULL) OR (ym_change IS NULL AND hour_change IS NULL), 1, 0) AS geq24h,
  1 AS point
  FROM htab
),
#
#
#
#
########
segmented AS(
  SELECT
    *,
    CONCAT(vessel_rnpa, "_", CAST(
      SUM(geq24h)
    OVER (
        PARTITION BY vessel_rnpa
        ORDER BY seq, datetime, year, month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS STRING), err) AS seg_id,
      SUM(point)
    OVER (
        PARTITION BY vessel_rnpa
        ORDER BY seq, datetime, year, month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS point_in_seg
FROM step)
#
#
#
#
########
SELECT
  vessel_rnpa,
  name,
  port,
  economic_unit,
  src,
  seg_id,
  point_in_seg,
  datetime,
  lat,
  lon,
  sea,
  eez,
  mpa,
  fishing_region,
  distance_from_port_m,
  distance_from_shore_m,
  depth_m,
  speed AS reported_speed,
  course,
  year,
  month,
  distance_to_last_m,
  IF(hours >= 24, NULL, hours) AS hours,
  IF(hours >= 24 OR hours = 0, NULL, (distance_to_last_m / 1852) / hours) AS implied_speed_knots
FROM segmented
LEFT JOIN `mex-fisheries.mex_vms.spatial_features_v_20240312` USING (lon_center, lat_center);