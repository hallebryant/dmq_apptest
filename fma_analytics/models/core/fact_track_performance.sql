{{ config(materialized='table') }}

SELECT
    t.track_id,
    t.artist_id,
    t.track_date_recorded,
    t.track_listens,
    t.track_favorites,
    a.danceability,
    a.energy,
    s.song_hotttnesss
FROM {{ source('fma', 'Tracks') }} t
LEFT JOIN {{ source('fma', 'Audio') }} a ON t.track_id = a.track_id
LEFT JOIN {{ source('fma', 'Social') }} s ON t.track_id = s.track_id