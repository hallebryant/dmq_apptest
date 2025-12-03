{{ config(materialized='table') }}

WITH yearly_data AS (
    SELECT
        a.artist_name,
        EXTRACT(YEAR FROM f.track_date_recorded) as release_year,
        SUM(f.track_listens) as total_listens
    FROM {{ ref('fact_track_performance') }} f
    JOIN {{ ref('dim_artists') }} a ON f.artist_id = a.artist_id
    WHERE f.track_date_recorded IS NOT NULL
    GROUP BY 1, 2
)
SELECT
    *,
    RANK() OVER (PARTITION BY release_year ORDER BY total_listens DESC) as rank_in_year
FROM yearly_data