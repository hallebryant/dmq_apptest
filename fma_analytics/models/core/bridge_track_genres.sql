{{ config(materialized='table') }}

SELECT
    track_id,
    genre_id
FROM {{ source('fma', 'TrackGenres') }}