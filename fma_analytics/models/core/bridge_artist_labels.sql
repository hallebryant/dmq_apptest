{{ config(materialized='table') }}

SELECT
    artist_id,
    label_id
FROM {{ source('fma', 'ArtistLabels') }}