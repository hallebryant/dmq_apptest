{{ config(materialized='table') }}

SELECT
    artist_id,
    artist_name,
    artist_handle,
    artist_website,
    artist_active_year_begin,
    artist_favorites
FROM {{ source('fma', 'Artists') }}