{{ config(materialized='table') }}

WITH artist_top_genre AS (
    -- Get the most common genre for each artist
    SELECT
        a.artist_id,
        g.genre_name,
        ROW_NUMBER() OVER (
            PARTITION BY a.artist_id
            ORDER BY COUNT(*) DESC
        ) as genre_rank
    FROM {{ ref('dim_artists') }} a
    JOIN {{ ref('fact_track_performance') }} f ON a.artist_id = f.artist_id
    JOIN {{ ref('bridge_track_genres') }} btg ON f.track_id = btg.track_id
    JOIN {{ ref('dim_genres') }} g ON btg.genre_id = g.genre_id
    GROUP BY a.artist_id, g.genre_name
),

artist_labels AS (
    -- Aggregate all labels per artist into comma-separated string
    SELECT
        bal.artist_id,
        STRING_AGG(DISTINCT l.label_name, ', ') as associated_labels
    FROM {{ ref('bridge_artist_labels') }} bal
    JOIN {{ ref('dim_labels') }} l ON bal.label_id = l.label_id
    GROUP BY bal.artist_id
)

SELECT
    a.artist_id,
    a.artist_name,
    a.artist_active_year_begin,
    a.artist_favorites,
    COUNT(DISTINCT al.album_id) as album_count,
    COUNT(DISTINCT f.track_id) as track_count,
    COALESCE(SUM(f.track_listens), 0) as total_listens,
    COALESCE(SUM(f.track_favorites), 0) as total_track_favorites,
    tg.genre_name as top_genre,
    lab.associated_labels
FROM {{ ref('dim_artists') }} a
LEFT JOIN {{ ref('dim_albums') }} al ON a.artist_id = al.artist_id
LEFT JOIN {{ ref('fact_track_performance') }} f ON a.artist_id = f.artist_id
LEFT JOIN artist_top_genre tg ON a.artist_id = tg.artist_id AND tg.genre_rank = 1
LEFT JOIN artist_labels lab ON a.artist_id = lab.artist_id
GROUP BY
    a.artist_id,
    a.artist_name,
    a.artist_active_year_begin,
    a.artist_favorites,
    tg.genre_name,
    lab.associated_labels
ORDER BY total_listens DESC, a.artist_favorites DESC