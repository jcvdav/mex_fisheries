CREATE OR REPLACE TABLE mex_fisheries.mex_vms_processed_v_20231003
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
  `emlab-gcp.mex_fisheries.mex_vms_v_20231003`
  WHERE lat IS NOT NULL
  AND lon IS NOT NULL
  AND lat between -90 AND 90
  AND lon between -180 AND 180
),
  #
  #
  #
  #
  ########
mod AS (
  SELECT
  *,
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
  IF((hour_change) OR (ym_change AND datetime IS NULL) OR (ym_change IS NULL AND hour_change IS NULL), 1, 0) AS  geq24h,
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
  distance_from_port_m,
  distance_from_shore_m,
  depth_m,
  speed,
  course,
  year,
  month,
  IF(hours >= 24, NULL, hours) AS hours
FROM segmented
LEFT JOIN `emlab-gcp.mex_fisheries.spatial_features` USING (lon_center, lat_center);