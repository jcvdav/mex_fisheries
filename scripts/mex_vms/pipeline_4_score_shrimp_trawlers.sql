CREATE OR REPLACE TABLE `emlab-gcp.mex_fisheries.scored_shrimp` AS
SELECT
  *  EXCEPT(nearest_centroids_distance)
FROM
  ML.PREDICT( MODEL `emlab-gcp.mex_fisheries.shrimp_clusters`,
    (
    SELECT
      *
    FROM
      `emlab-gcp.mex_fisheries.mex_vms_processed_v_20230323`
      INNER JOIN (
    SELECT vessel_rnpa FROM `emlab-gcp.mex_fisheries.vessel_info_v_20221104`
    WHERE shrimp = 1
    AND tuna = 0
    AND sardine = 0
    AND others = 0
    AND REGEXP_CONTAINS(gear_type, "ARRASTRE")
    AND fuel_type = "Diesel"
  ) USING (vessel_rnpa)
  WHERE
    speed IS NOT NULL))