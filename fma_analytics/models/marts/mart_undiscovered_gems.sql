{{ config(materialized='table') }}

WITH global_avg AS (
    SELECT AVG(track_listens) as avg_listens FROM {{ ref('fact_track_performance') }}
)
SELECT
    f.track_id,
    a.artist_name,
    f.track_listens,
    f.song_hotttnesss
FROM {{ ref('fact_track_performance') }} f
JOIN {{ ref('dim_artists') }} a ON f.artist_id = a.artist_id
CROSS JOIN global_avg ga
WHERE f.song_hotttnesss > 0.3
  AND f.track_listens < ga.avg_listens