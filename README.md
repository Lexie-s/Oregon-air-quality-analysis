# Oregon PM2.5 Air Quality Analysis (1999–2022)

Analysis of 25 years of EPA air quality monitoring data across Oregon counties using Python, MySQL, and Power BI. Identifies wildfire and wood smoke impacts on PM2.5 exceedances of the federal 24-hour NAAQS standard.

---

## Tools and Technologies

- **Python** (pandas, mysql-connector) — data pipeline and ETL
- **MySQL** — normalized relational database and SQL analysis
- **Power BI** — interactive dashboard and visualization

---

## Data Source

EPA Air Quality System (AQS) — Daily PM2.5 FRM/FEM Mass (Parameter 88101)
https://aqs.epa.gov/aqsweb/airdata/download_files.html

Coverage: Oregon monitoring stations, 1999–2022
Note: 2023–2024 data excluded due to EPA certification lag.

---

## Repository Contents

| File | Description |
|------|-------------|
| `Oregon_Air_Quality_Pipeline.ipynb` | Data download, extraction, and MySQL load pipeline |
| `oregon_air_quality_analysis.sql` | Five analysis queries and county normalization view |
| `dashboard_screenshot.png` | Power BI dashboard screenshot |

---

## Analysis

PM2.5, or particulate matter 2.5 micrometers or smaller in diameter, is a pollutant small enough to bypass the body's respiratory defenses and enter the bloodstream, making it one of the most closely monitored air quality indicators in the United States.

This analysis examines 25 years of EPA air quality monitoring data across Oregon counties from 1999 to 2022. While the early 2000s had more total days exceeding the federal PM2.5 standard of 35 µg/m³, average daily PM2.5 concentrations peaked around 2020. This suggests that while unhealthy air days were more frequent in earlier years, recent years may be producing more intense pollution events, likely driven by larger and more severe wildfires.

At the county level, Klamath County had the highest number of unhealthy days when normalized by monitoring station count, followed by Jackson and Lake counties in southern Oregon.

Seasonally, winter months produced more total days exceeding the federal standard than summer months when measured across the full 24-year period. This is largely driven by wood smoke inversions, cold air trapping residential wood smoke at ground level in valley communities like Eugene and Medford. While summer wildfire seasons produce more extreme single-day spikes, winter wood smoke affects valley counties more consistently year over year.

**Limitations:** Counties with fewer monitoring stations may show less reliable averages due to limited sampling. Additionally, larger rural counties are underrepresented relative to their geographic area, as fewer monitors cover more land.

**Conclusion:** PM2.5 pollution in Oregon has become more intense in recent years even as the total number of exceedance days has fluctuated. This pattern warrants continued monitoring, particularly during wildfire seasons.

---

## Database Schema

```
monitors
  site_id (PK), state_code, county_code, site_num,
  state_name, county_name, city_name, latitude, longitude

daily_readings
  reading_id (PK), site_id (FK), date_local, event_type,
  observation_count, observation_percent,
  arithmetic_mean, max_value, aqi
```

---

## Author

Lexie Smith
B.S. Data Analytics, Washington State University
