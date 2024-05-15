CREATE OR REPLACE TABLE `mex-fisheries.mex_vms.segment_info_v_20240515`
AS
SELECT
  seg_id,
  COUNT(*) AS n_pos,
  SUM(IF(reported_speed > 0.1, 1, 0)) AS n_pos_moving,
  SUM(hours) AS hours,
  SUM(IF(reported_speed > 0.1, 1, 0) * hours) AS active_hours,
  MIN(datetime) AS first_timestamp,
  MAX(datetime) AS last_timestamp,
  MAX(lon) AS max_lon,
  MIN(lon) AS min_lon,
  MAX(lat) AS max_lat,
  MIN(lat) AS min_lat,
  AVG(reported_speed) AS average_speed,
  AVG(implied_speed_knots) AS average_implied_speed_knotts,
  MIN(year) AS year_start,
  MAX(year) AS year_end
FROM `mex-fisheries.mex_vms.mex_vms_processed_v_20240515`
  GROUP BY seg_id
  ORDER BY seg_id;