{{ config(materialized='table') }}

SELECT
    label_id,
    label_name
FROM {{ source('fma', 'Labels') }}