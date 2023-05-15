CREATE OR REPLACE TABLE mex_fisheries.segment_info_v_20230419
AS
SELECT
  seg_id,
  COUNT(*) AS n_pos,
  SUM(IF(speed > 0.1, 1, 0)) AS n_pos_moving,
  SUM(hours) AS hours,
  SUM(IF(speed > 0.1, 1, 0) * hours) AS active_hours,
  MIN(datetime) AS first_timestamp,
  MAX(datetime) AS last_timestamp,
  MAX(lon) AS max_lon,
  MIN(lon) AS min_lon,
  MAX(lat) AS max_lat,
  MIN(lat) AS min_lat,
  AVG(speed) AS average_speed,
  MIN(year) AS year_start,
  MAX(year) AS year_end
FROM `emlab-gcp.mex_fisheries.mex_vms_processed_v_20230419`
  GROUP BY seg_id
  ORDER BY seg_id;