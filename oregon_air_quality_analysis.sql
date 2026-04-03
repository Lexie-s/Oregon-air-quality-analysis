-- ============================================================
-- Oregon PM2.5 Air Quality Analysis
-- ============================================================
-- Author:      Lexie Smith
-- Data Source: EPA Air Quality System (AQS) — Daily PM2.5 FRM/FEM Mass
-- Parameter:   88101 (PM2.5 FRM/FEM Mass, 24-hour measurements)
-- Coverage:    Oregon monitoring stations, 1999–2022
-- Database:    oregon_air_quality (MySQL)
--
-- Description:
--   This script contains five analysis queries and one supporting
--   view used to explore PM2.5 air quality trends across Oregon
--   counties from 1999 to 2022. Analysis focuses on exceedances
--   of the federal 24-hour PM2.5 NAAQS standard (35 µg/m³),
--   seasonal patterns, and geographic distribution of unhealthy
--   air days by county.
--
-- Tables:
--   monitors       — One row per monitoring station (location, county)
--   daily_readings — One row per day per monitor (PM2.5, AQI, event type)
--
-- Note: 2023–2024 data is excluded from analysis due to EPA
--   certification lag. Recent years are underrepresented in the
--   AQS database until data is fully validated and submitted.
-- ============================================================
USE oregon_air_quality;

-- ============================================================
-- QUERY 1: Data Completeness Check — Readings Per Year
-- ============================================================
-- Verifies row counts by year before analysis.
-- Low counts in recent years (2023-2024) reflect EPA data lag,
-- not a decline in monitoring activity.
-- ============================================================

SELECT YEAR(date_local) AS year, COUNT(*) AS readings
FROM daily_readings
GROUP BY year
ORDER BY year;

-- ============================================================
-- QUERY 2: Worst County/Year Combinations by Average PM2.5
-- ============================================================
-- Identifies the 20 highest average PM2.5 county/year combinations.
-- reading_days is included to contextualize averages — counties
-- with fewer readings may show inflated averages due to sampling
-- bias (monitors active only during high-pollution events).
-- ============================================================

SELECT 
    m.county_name,
    YEAR(d.date_local) AS year,
    ROUND(AVG(d.arithmetic_mean), 2) AS avg_pm25,
    MAX(d.arithmetic_mean) AS max_pm25,
    COUNT(*) AS reading_days
FROM daily_readings d
JOIN monitors m ON d.site_id = m.site_id
WHERE YEAR(d.date_local) BETWEEN 1999 AND 2022
GROUP BY m.county_name, year
ORDER BY avg_pm25 DESC
LIMIT 20;

-- ============================================================
-- QUERY 3: Statewide Unhealthy Days Per Year
-- ============================================================
-- Counts days where PM2.5 exceeded the federal 24-hour NAAQS
-- standard of 35 µg/m³ across all Oregon monitoring stations.
-- Each row represents one monitor-day exceeding the threshold.
-- ============================================================

SELECT 
    YEAR(date_local) AS year,
    COUNT(*) AS unhealthy_days
FROM daily_readings
WHERE arithmetic_mean > 35
AND YEAR(date_local) BETWEEN 1999 AND 2022
GROUP BY year
ORDER BY year;

-- ============================================================
-- QUERY 4: Unhealthy Days by County and Year
-- ============================================================
-- Breaks down PM2.5 exceedance days by county and year to
-- identify geographic patterns and track county-level trends
-- over time. Ordered by unhealthy_days descending to surface
-- the most impacted county/year combinations first.
-- ============================================================

SELECT 
    m.county_name,
    YEAR(d.date_local) AS year,
    COUNT(*) AS unhealthy_days
FROM daily_readings d
JOIN monitors m ON d.site_id = m.site_id
WHERE d.arithmetic_mean > 35
AND YEAR(d.date_local) BETWEEN 1999 AND 2022
GROUP BY m.county_name, year
ORDER BY unhealthy_days DESC;

-- ============================================================
-- QUERY 5: Seasonal Patterns — Unhealthy Days by County and Month
-- ============================================================
-- Examines which months drive PM2.5 exceedances by county.
-- Two distinct seasonal patterns emerge:
--   Summer/Fall (Aug–Oct): Wildfire smoke — elevated statewide
--   Winter (Nov–Jan):      Wood smoke inversions — concentrated
--                          in valley counties (Lane, Jackson, Klamath)
-- ============================================================

SELECT 
    m.county_name,
    MONTH(d.date_local) AS month,
    COUNT(*) AS unhealthy_days
FROM daily_readings d
JOIN monitors m ON d.site_id = m.site_id
WHERE d.arithmetic_mean > 35
AND YEAR(d.date_local) BETWEEN 1999 AND 2022
GROUP BY month, m.county_name
ORDER BY unhealthy_days DESC;

-- ============================================================
-- VIEW: county_unhealthy_avg
-- ============================================================
-- Aggregates PM2.5 exceedance data by county, normalizing
-- unhealthy days by the number of monitoring stations in each
-- county. Raw unhealthy day counts favor counties with more
-- monitors — this view provides a fairer county-level comparison.
--
-- avg_unhealthy_days_per_monitor answers:
--   "At a typical monitoring station in this county, how many
--    days per year exceeded the federal PM2.5 standard?"
--
-- Latitude and longitude are averaged across all stations in
-- the county for map visualization purposes.
-- ============================================================

CREATE  OR REPLACE VIEW county_unhealthy_avg AS
SELECT 
    m.county_name,
    AVG(m.latitude) AS latitude,
    AVG(m.longitude) AS longitude,
    COUNT(*) AS unhealthy_days,
    COUNT(DISTINCT m.site_id) AS monitor_count,
    COUNT(*) / COUNT(DISTINCT m.site_id) AS avg_unhealthy_days_per_monitor
FROM daily_readings d
JOIN monitors m ON d.site_id = m.site_id
WHERE d.arithmetic_mean > 35
AND YEAR(d.date_local) BETWEEN 1999 AND 2022
GROUP BY m.county_name;
