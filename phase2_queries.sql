-- 1. Genre Fingerprinting
SELECT
    g.genre_title,
    COUNT(t.track_id) AS track_count,
    ROUND(AVG(a.danceability)::numeric, 3) AS avg_danceability,
    ROUND(AVG(a.energy)::numeric, 3) AS avg_energy
FROM "Tracks" t
JOIN "TrackGenres" tg ON t.track_id = tg.track_id
JOIN "Genres" g ON tg.genre_id = g.genre_id
JOIN "Audio" a ON t.track_id = a.track_id
GROUP BY g.genre_title
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