{{ config(materialized='table') }}

SELECT
    g.genre_name,
    COUNT(f.track_id) as track_count,
    AVG(f.danceability) as avg_danceability,
    AVG(f.energy) as avg_energy
FROM {{ ref('fact_track_performance') }} f
JOIN {{ ref('bridge_track_genres') }} b ON f.track_id = b.track_id
JOIN {{ ref('dim_genres') }} g ON b.genre_id = g.genre_id
GROUP BY g.genre_name
HAVING COUNT(f.track_id) > 100