{{ config(materialized='table') }}

SELECT
    genre_id,
    genre_name,
    parent_id
FROM {{ source('fma', 'Genres') }}