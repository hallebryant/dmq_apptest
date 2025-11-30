-- ============================================================================
-- FMA DATABASE - COMPLETE VALIDATION SCRIPT WITH PERFORMANCE TIMING
-- ============================================================================
-- Run this after completing all setup steps to verify everything works
-- Usage: docker compose exec -T postgres psql -U common-user-aph -d fma_db < test_all.sql
-- ============================================================================

-- Enable timing for all queries
\timing on

-- Set output format for better readability
\pset border 2
\pset linestyle unicode

\echo ''
\echo '╔══════════════════════════════════════════════════════════════════════════╗'
\echo '║                    FMA DATABASE VALIDATION SUITE                         ║'
\echo '╚══════════════════════════════════════════════════════════════════════════╝'
\echo ''

-- ============================================================================
-- SECTION 1: DATA INTEGRITY TESTS
-- ============================================================================

\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 1: RAW TABLE ROW COUNTS (public schema)                             │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    'Artists' as table_name, COUNT(*) as row_count FROM "Artists"
UNION ALL
SELECT 'Albums', COUNT(*) FROM "Albums"
UNION ALL
SELECT 'Tracks', COUNT(*) FROM "Tracks"
UNION ALL
SELECT 'Genres', COUNT(*) FROM "Genres"
UNION ALL
SELECT 'Audio', COUNT(*) FROM "Audio"
UNION ALL
SELECT 'Social', COUNT(*) FROM "Social"
UNION ALL
SELECT 'TrackGenres', COUNT(*) FROM "TrackGenres"
UNION ALL
SELECT 'TrackLyricists', COUNT(*) FROM "TrackLyricists"
UNION ALL
SELECT 'ArtistLabels', COUNT(*) FROM "ArtistLabels"
UNION ALL
SELECT 'AlbumEngineers', COUNT(*) FROM "AlbumEngineers"
UNION ALL
SELECT 'Labels', COUNT(*) FROM "Labels"
UNION ALL
SELECT 'Engineers', COUNT(*) FROM "Engineers"
UNION ALL
SELECT 'Lyricists', COUNT(*) FROM "Lyricists"
UNION ALL
SELECT 'Licenses', COUNT(*) FROM "Licenses"
ORDER BY row_count DESC;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 2: DBT MODELS EXIST (analytics schema)                              │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT tablename as dbt_model
FROM pg_tables
WHERE schemaname = 'analytics'
  AND tablename IN ('dim_artists', 'dim_genres', 'bridge_track_genres',
                    'fact_track_performance', 'mart_genre_profiles',
                    'mart_top_artists_yearly', 'mart_undiscovered_gems')
ORDER BY tablename;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 3: DBT MODEL ROW COUNTS (analytics schema)                          │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    'dim_artists' as model_name, COUNT(*) as row_count FROM analytics.dim_artists
UNION ALL
SELECT 'dim_genres', COUNT(*) FROM analytics.dim_genres
UNION ALL
SELECT 'bridge_track_genres', COUNT(*) FROM analytics.bridge_track_genres
UNION ALL
SELECT 'fact_track_performance', COUNT(*) FROM analytics.fact_track_performance
UNION ALL
SELECT 'mart_genre_profiles', COUNT(*) FROM analytics.mart_genre_profiles
UNION ALL
SELECT 'mart_top_artists_yearly', COUNT(*) FROM analytics.mart_top_artists_yearly
UNION ALL
SELECT 'mart_undiscovered_gems', COUNT(*) FROM analytics.mart_undiscovered_gems
ORDER BY model_name;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 4: FOREIGN KEY INTEGRITY CHECKS (public schema)                     │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    'Tracks -> Artists' as relationship,
    CASE
        WHEN COUNT(*) = 0 THEN '✓ PASS'
        ELSE '✗ FAIL: ' || COUNT(*) || ' orphans'
    END as status
FROM "Tracks" t
LEFT JOIN "Artists" a ON t.artist_id = a.artist_id
WHERE t.artist_id IS NOT NULL AND a.artist_id IS NULL

UNION ALL

SELECT
    'Tracks -> Albums',
    CASE
        WHEN COUNT(*) = 0 THEN '✓ PASS'
        ELSE '✗ FAIL: ' || COUNT(*) || ' orphans'
    END
FROM "Tracks" t
LEFT JOIN "Albums" a ON t.album_id = a.album_id
WHERE t.album_id IS NOT NULL AND a.album_id IS NULL

UNION ALL

SELECT
    'TrackGenres -> Genres',
    CASE
        WHEN COUNT(*) = 0 THEN '✓ PASS'
        ELSE '✗ FAIL: ' || COUNT(*) || ' orphans'
    END
FROM "TrackGenres" tg
LEFT JOIN "Genres" g ON tg.genre_id = g.genre_id
WHERE g.genre_id IS NULL

UNION ALL

SELECT
    'TrackGenres -> Tracks',
    CASE
        WHEN COUNT(*) = 0 THEN '✓ PASS'
        ELSE '✗ FAIL: ' || COUNT(*) || ' orphans'
    END
FROM "TrackGenres" tg
LEFT JOIN "Tracks" t ON tg.track_id = t.track_id
WHERE t.track_id IS NULL;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 5: INDEXES VERIFICATION (public schema)                             │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 6: SECURITY ROLES VERIFICATION                                      │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT rolname as role_or_user,
       CASE WHEN rolcanlogin THEN 'User' ELSE 'Role' END as type
FROM pg_roles
WHERE rolname IN ('analyst_role', 'developer_role', 'analyst_phalguni', 'dev_halle')
ORDER BY type, rolname;

-- ============================================================================
-- SECTION 2: SAMPLE DATA VERIFICATION
-- ============================================================================

\echo ''
\echo '╔══════════════════════════════════════════════════════════════════════════╗'
\echo '║                    SAMPLE DATA OUTPUTS (analytics schema)                ║'
\echo '╚══════════════════════════════════════════════════════════════════════════╝'
\echo ''

\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 7: analytics.dim_artists - Top 5 by Favorites                       │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT artist_id, artist_name, artist_handle, artist_favorites
FROM analytics.dim_artists
ORDER BY artist_favorites DESC NULLS LAST
LIMIT 5;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 8: analytics.dim_genres - Sample with Hierarchy                     │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    g.genre_id,
    g.genre_name as genre,
    p.genre_name as parent_genre
FROM analytics.dim_genres g
LEFT JOIN analytics.dim_genres p ON g.parent_id = p.genre_id
LIMIT 10;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 9: analytics.fact_track_performance - Top 5 by Listens              │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    track_id,
    artist_id,
    track_listens,
    ROUND(danceability::numeric, 3) as danceability,
    ROUND(energy::numeric, 3) as energy,
    ROUND(song_hotttnesss::numeric, 3) as hotttnesss
FROM analytics.fact_track_performance
WHERE danceability IS NOT NULL
ORDER BY track_listens DESC NULLS LAST
LIMIT 5;

-- ============================================================================
-- SECTION 3: MART OUTPUTS
-- ============================================================================

\echo ''
\echo '╔══════════════════════════════════════════════════════════════════════════╗'
\echo '║                      MART RESULTS (analytics schema)                     ║'
\echo '╚══════════════════════════════════════════════════════════════════════════╝'
\echo ''

\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 10: analytics.mart_genre_profiles - Top 15 by Track Count           │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    genre_name,
    track_count,
    ROUND(avg_danceability::numeric, 3) as avg_danceability,
    ROUND(avg_energy::numeric, 3) as avg_energy
FROM analytics.mart_genre_profiles
ORDER BY track_count DESC
LIMIT 15;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 11: analytics.mart_top_artists_yearly - Top 3 per Year (2008+)      │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT artist_name, release_year, total_listens, rank_in_year
FROM analytics.mart_top_artists_yearly
WHERE rank_in_year <= 3
  AND release_year >= 2008
ORDER BY release_year DESC, rank_in_year ASC
LIMIT 20;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 12: analytics.mart_undiscovered_gems - Top 15 Hidden Gems           │'
\echo '│ NOTE: May be empty if no tracks meet criteria (hotttnesss > 0.6)         │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    track_id,
    artist_name,
    track_listens,
    ROUND(song_hotttnesss::numeric, 3) as song_hotttnesss
FROM analytics.mart_undiscovered_gems
ORDER BY song_hotttnesss DESC
LIMIT 15;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ TEST 12b: Social hotttnesss distribution (debug if gems empty)           │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    ROUND(MIN(song_hotttnesss)::numeric, 3) as min_hotttnesss,
    ROUND(AVG(song_hotttnesss)::numeric, 3) as avg_hotttnesss,
    ROUND(MAX(song_hotttnesss)::numeric, 3) as max_hotttnesss,
    COUNT(*) as total_tracks
FROM "Social"
WHERE song_hotttnesss IS NOT NULL;

-- ============================================================================
-- SECTION 4: PERFORMANCE BENCHMARKS - RAW QUERIES VS MARTS
-- ============================================================================

\echo ''
\echo '╔══════════════════════════════════════════════════════════════════════════╗'
\echo '║                      PERFORMANCE BENCHMARKS                              ║'
\echo '║         Compare: Direct Query (Raw Tables) vs Pre-computed Marts         ║'
\echo '╚══════════════════════════════════════════════════════════════════════════╝'
\echo ''

\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ PERF TEST 1A: Genre Fingerprinting - DIRECT QUERY (Raw Tables)           │'
\echo '│ Uses: Tracks → TrackGenres → Genres → Audio (4-way join + aggregation)   │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

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
ORDER BY avg_energy DESC
LIMIT 15;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ PERF TEST 1B: Genre Fingerprinting - PRE-COMPUTED MART                   │'
\echo '│ Uses: analytics.mart_genre_profiles (single table scan)                  │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    genre_name,
    track_count,
    ROUND(avg_danceability::numeric, 3) AS avg_danceability,
    ROUND(avg_energy::numeric, 3) AS avg_energy
FROM analytics.mart_genre_profiles
ORDER BY avg_energy DESC
LIMIT 15;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ PERF TEST 2A: Top Artists Yearly - DIRECT QUERY (Window Function)        │'
\echo '│ Uses: Tracks → Artists + GROUP BY + RANK() window function               │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

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
ORDER BY release_year DESC, yr_rank ASC
LIMIT 20;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ PERF TEST 2B: Top Artists Yearly - PRE-COMPUTED MART                     │'
\echo '│ Uses: analytics.mart_top_artists_yearly (single table scan + filter)     │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT artist_name, release_year, total_listens, rank_in_year
FROM analytics.mart_top_artists_yearly
WHERE rank_in_year <= 3 AND release_year >= 2000
ORDER BY release_year DESC, rank_in_year ASC
LIMIT 20;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ PERF TEST 3A: Undiscovered Gems - DIRECT QUERY (Subquery)                │'
\echo '│ Uses: Tracks → Social → Artists + subquery for AVG                       │'
\echo '│ NOTE: Using hotttnesss > 0.3 to get results (original was > 0.6)         │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    t.track_title,
    art.artist_name,
    t.track_listens,
    ROUND(s.song_hotttnesss::numeric, 3) as song_hotttnesss
FROM "Tracks" t
JOIN "Social" s ON t.track_id = s.track_id
JOIN "Artists" art ON t.artist_id = art.artist_id
WHERE s.song_hotttnesss > 0.3
  AND t.track_listens < (SELECT AVG(track_listens) FROM "Tracks")
ORDER BY s.song_hotttnesss DESC
LIMIT 15;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ PERF TEST 3B: Undiscovered Gems - PRE-COMPUTED MART                      │'
\echo '│ Uses: analytics.mart_undiscovered_gems (single table scan)               │'
\echo '│ NOTE: May be empty due to hotttnesss > 0.6 threshold in mart             │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT track_id, artist_name, track_listens,
       ROUND(song_hotttnesss::numeric, 3) as song_hotttnesss
FROM analytics.mart_undiscovered_gems
ORDER BY song_hotttnesss DESC
LIMIT 15;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ PERF TEST 4: Complex 5-Way Join - Track Details with All Features        │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    t.track_title,
    art.artist_name,
    alb.album_title,
    t.track_listens,
    ROUND(a.danceability::numeric, 3) as danceability,
    ROUND(a.energy::numeric, 3) as energy,
    ROUND(s.song_hotttnesss::numeric, 3) as hotttnesss
FROM "Tracks" t
JOIN "Artists" art ON t.artist_id = art.artist_id
JOIN "Albums" alb ON t.album_id = alb.album_id
LEFT JOIN "Audio" a ON t.track_id = a.track_id
LEFT JOIN "Social" s ON t.track_id = s.track_id
WHERE a.danceability > 0.7
  AND s.song_hotttnesss > 0.2
ORDER BY t.track_listens DESC
LIMIT 10;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ PERF TEST 5: Heavy Aggregation - Artist Statistics                       │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

SELECT
    art.artist_name,
    COUNT(DISTINCT t.track_id) as track_count,
    COUNT(DISTINCT alb.album_id) as album_count,
    SUM(t.track_listens) as total_listens,
    ROUND(AVG(a.energy)::numeric, 3) as avg_energy
FROM "Artists" art
JOIN "Tracks" t ON art.artist_id = t.artist_id
JOIN "Albums" alb ON t.album_id = alb.album_id
LEFT JOIN "Audio" a ON t.track_id = a.track_id
GROUP BY art.artist_id, art.artist_name
HAVING COUNT(DISTINCT t.track_id) > 10
ORDER BY total_listens DESC
LIMIT 10;

-- ============================================================================
-- SECTION 5: EXPLAIN ANALYZE - QUERY EXECUTION PLANS
-- ============================================================================

\echo ''
\echo '╔══════════════════════════════════════════════════════════════════════════╗'
\echo '║                      QUERY EXECUTION PLANS                               ║'
\echo '║              Verify indexes are being used by the planner                ║'
\echo '╚══════════════════════════════════════════════════════════════════════════╝'
\echo ''

\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ EXPLAIN 1: TrackGenres Join (Should use idx_trackgenres_genre_id)        │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

EXPLAIN ANALYZE
SELECT g.genre_name, COUNT(*)
FROM "TrackGenres" tg
JOIN "Genres" g ON tg.genre_id = g.genre_id
GROUP BY g.genre_name;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ EXPLAIN 2: Audio Join (Should use idx_audio_track_id)                    │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

EXPLAIN ANALYZE
SELECT t.track_id, a.danceability
FROM "Tracks" t
JOIN "Audio" a ON t.track_id = a.track_id
WHERE a.danceability > 0.8
LIMIT 100;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ EXPLAIN 3: Social Hotttnesss Filter (Should use idx_social_hotttnesss)   │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

EXPLAIN ANALYZE
SELECT track_id, song_hotttnesss
FROM "Social"
WHERE song_hotttnesss > 0.3
ORDER BY song_hotttnesss DESC
LIMIT 50;

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│ EXPLAIN 4: Date Range Query (Should use idx_tracks_date_recorded)        │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'

EXPLAIN ANALYZE
SELECT track_id, track_title, track_date_recorded
FROM "Tracks"
WHERE track_date_recorded BETWEEN '2010-01-01' AND '2015-12-31'
LIMIT 100;

-- ============================================================================
-- SECTION 6: FINAL SUMMARY
-- ============================================================================

\echo ''
\echo '╔══════════════════════════════════════════════════════════════════════════╗'
\echo '║                         FINAL SUMMARY                                    ║'
\echo '╚══════════════════════════════════════════════════════════════════════════╝'
\echo ''

SELECT
    'Raw Tables (public)' as metric,
    COUNT(*)::text as value
FROM pg_tables WHERE schemaname = 'public' AND tablename ~ '^[A-Z]'
UNION ALL
SELECT
    'dbt Models (analytics)',
    COUNT(*)::text
FROM pg_tables WHERE schemaname = 'analytics'
UNION ALL
SELECT
    'Custom Indexes',
    COUNT(*)::text
FROM pg_indexes WHERE schemaname = 'public' AND indexname LIKE 'idx_%'
UNION ALL
SELECT
    'Total Tracks',
    to_char(COUNT(*), 'FM999,999')
FROM "Tracks"
UNION ALL
SELECT
    'Total Artists',
    to_char(COUNT(*), 'FM999,999')
FROM "Artists"
UNION ALL
SELECT
    'Tracks with Audio Features',
    to_char(COUNT(*), 'FM999,999')
FROM "Audio"
UNION ALL
SELECT
    'Tracks with Social Metrics',
    to_char(COUNT(*), 'FM999,999')
FROM "Social"
UNION ALL
SELECT
    'Genre Assignments',
    to_char(COUNT(*), 'FM999,999')
FROM "TrackGenres";

\echo ''
\echo '┌──────────────────────────────────────────────────────────────────────────┐'
\echo '│                        SCHEMA ORGANIZATION                               │'
\echo '└──────────────────────────────────────────────────────────────────────────┘'
\echo ''
\echo '  public schema    → Raw normalized tables (Artists, Tracks, Albums, etc.)'
\echo '  analytics schema → dbt transformed models (dim_*, fact_*, mart_*)'
\echo ''

\echo '╔══════════════════════════════════════════════════════════════════════════╗'
\echo '║              ✓ ALL TESTS COMPLETED - CHECK TIMING ABOVE                  ║'
\echo '╚══════════════════════════════════════════════════════════════════════════╝'
\echo ''
\echo 'Performance Notes:'
\echo '  - Compare PERF TEST A vs B pairs to see mart speedup'
\echo '  - Check EXPLAIN outputs for "Index Scan" vs "Seq Scan"'
\echo '  - Times shown after each query in milliseconds'
\echo ''

\timing on