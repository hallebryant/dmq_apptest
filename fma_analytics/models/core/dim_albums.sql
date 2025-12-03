{{ config(materialized='table') }}

SELECT
    album_id,
    album_title,
    album_type,
    album_tracks,
    album_date_released,
    album_listens,
    album_favorites,
    artist_id
FROM {{ source('fma', 'Albums') }}