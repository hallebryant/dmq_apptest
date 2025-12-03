-- 1. Genre Fingerprinting
SELECT
    g.genre_name,
    COUNT(t.track_id) AS track_count,
    ROUND(AVG(a.danceability)::numeric, 3) AS avg_danceability,
    ROUND(AVG(a.energy)::numeric, 3) AS avg_energy
FROM "Tracks" t
JOIN "TrackGenres" tg ON t.track_id = tg.track_id
JOIN "Genres" g ON tg.genre_id = g.genre_id
JOIN "Audio" a ON t.track_id = a.track_id
GROUP BY g.genre_name
HAVING COUNT(t.track_id) > 100
ORDER BY avg_energy DESC;

-- 2. Top Artists Yearly (Window Function)
WITH YearlyStats AS (
    SELECT
        art.artist_name,
        EXTRACT(YEAR FROM t.track_date_recorded) AS release_year,
        SUM(t.track_listens) AS total_listens
    FROM "Tracks" t
    JOIN "Artists" art ON t.artist_id = art.artist_id
    WHERE t.track_date_recorded > '2000-01-01'
    GROUP BY 1, 2
),
RankedStats AS (
    SELECT *, RANK() OVER (PARTITION BY release_year ORDER BY total_listens DESC) as yr_rank
    FROM YearlyStats
)
SELECT * FROM RankedStats
WHERE yr_rank <= 3
ORDER BY release_year DESC, yr_rank ASC;

-- 3. Undiscovered Gems (Subquery)
SELECT
    t.track_title,
    art.artist_name,
    t.track_listens,
    s.song_hotttnesss
FROM "Tracks" t
JOIN "Social" s ON t.track_id = s.track_id
JOIN "Artists" art ON t.artist_id = art.artist_id
WHERE s.song_hotttnesss > 0.6
  AND t.track_listens < (SELECT AVG(track_listens) FROM "Tracks")
ORDER BY s.song_hotttnesss DESC
LIMIT 50;

-- 4. Artist Profiling (Subquery)
SELECT 
    a.artist_id,
    a.artist_name,
    a.artist_active_year_begin,
    a.artist_favorites,
    COUNT(DISTINCT al.album_id) as album_count,
    COUNT(DISTINCT t.track_id) as track_count,
    COALESCE(SUM(t.track_listens), 0) as total_listens,
    COALESCE(SUM(t.track_favorites), 0) as total_track_favorites,
    STRING_AGG(DISTINCT l.label_name, ', ') as associated_labels,
    -- Getting most common genre for an artist
    (
        SELECT g.genre_name
        FROM "TrackGenres" tg
        JOIN "Genres" g ON tg.genre_id = g.genre_id
        JOIN "Tracks" t2 ON tg.track_id = t2.track_id
        WHERE t2.artist_id = a.artist_id
        GROUP BY g.genre_name
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) as top_genre
FROM "Artists" a
LEFT JOIN "Albums" al ON a.artist_id = al.artist_id
LEFT JOIN "Tracks" t ON a.artist_id = t.artist_id
LEFT JOIN "Social" s ON t.track_id = s.track_id
LEFT JOIN "ArtistLabels" arl ON a.artist_id = arl.artist_id
LEFT JOIN "Labels" l ON arl.label_id = l.label_id
GROUP BY a.artist_id, a.artist_name, a.artist_active_year_begin, a.artist_favorites
ORDER BY total_listens DESC, artist_favorites DESC;