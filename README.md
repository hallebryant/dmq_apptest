# Phase 2: Advanced Analytics & dbt

This phase adds indexes, advanced SQL queries, and a dbt-powered star schema on top of the Phase 1 database.

---

## Prerequisites

- Phase 1 completed (database running with data loaded)
- Python virtual environment activated
- dbt-postgres installed (`pip install dbt-postgres`)

---

## Project Structure

```
├── phase2_optimization.sql     # Index definitions
├── phase2_queries.sql          # 3 advanced analytical queries
├── test_phase_2.sql            # Validation + performance benchmarks
├── security.sql                # Role-based access control
│
├── fma_analytics/              # dbt project
│   ├── models/
│   │   ├── core/               # Star schema (fact + dims)
│   │   │   ├── dim_artists.sql
│   │   │   ├── dim_genres.sql
│   │   │   ├── bridge_track_genres.sql
│   │   │   └── fact_track_performance.sql
│   │   ├── marts/              # Pre-aggregated analytics
│   │   │   ├── mart_genre_profiles.sql
│   │   │   ├── mart_top_artists_yearly.sql
│   │   │   └── mart_undiscovered_gems.sql
│   │   └── sources.yml
│   └── dbt_project.yml
│
└── reports/
    ├── ERDiagram.png           # OLTP schema diagram
    └── StarSchemaDiagram.png   # dbt star schema diagram (from DBeaver)
```

---

## Setup Steps

### 1. Create Indexes (Performance Optimization)

**Mac/Linux:**
```bash
docker compose exec -T postgres psql -U common-user-aph -d fma_db < phase2_optimization.sql
```

**Windows (PowerShell):**
```powershell
Get-Content phase2_optimization.sql | docker compose exec -T postgres psql -U common-user-aph -d fma_db
```

### 2. Create Security Roles (Optional)

**Mac/Linux:**
```bash
docker compose exec -T postgres psql -U common-user-aph -d fma_db < security.sql
```

**Windows (PowerShell):**
```powershell
Get-Content security.sql | docker compose exec -T postgres psql -U common-user-aph -d fma_db
```

### 3. Configure dbt

> ⚠️ **One-time setup only.** Running `dbt init fma_analytics` creates this automatically. (please do not run this. This is just for information)

**Profile location:**
- Mac/Linux: `~/.dbt/profiles.yml`
- Windows: `C:\Users\<YourUsername>\.dbt\profiles.yml`

**Contents of `profiles.yml`:**

```yaml
fma_analytics:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: common-user-aph       # Match your docker-compose.yml
      password: aph1234           # Match your docker-compose.yml
      port: 5432
      dbname: fma_db
      schema: analytics
      threads: 1
```

### 4. Run dbt Models

```bash
cd fma_analytics

# Verify connection
dbt debug

# Build all models (creates tables in analytics schema)
dbt run
```

Expected output:
```
Completed successfully
Done. PASS=7 WARN=0 ERROR=0
```

### 5. Run Validation Tests

**Mac/Linux:**
```bash
docker compose exec -T postgres psql -U common-user-aph -d fma_db < test_phase_2.sql
```

**Windows (PowerShell):**
```powershell
Get-Content test_phase_2.sql | docker compose exec -T postgres psql -U common-user-aph -d fma_db
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Run dbt models | `cd fma_analytics && dbt run` |
| Rebuild single model | `dbt run --select mart_genre_profiles` |
| Test dbt connection | `dbt debug` |
| Generate docs | `dbt docs generate && dbt docs serve` |

---

## Schema Organization

| Schema | Contents |
|--------|----------|
| `public` | Raw normalized tables (OLTP) |
| `analytics` | dbt models - dims, facts, marts (OLAP) |

---

## Testing Performance in DBeaver

### Connect to Database

1. Open DBeaver → New Connection → PostgreSQL
2. Enter credentials:
   - Host: `localhost`
   - Port: `5432`
   - Database: `fma_db`
   - Username: `common-user-aph`
   - Password: `aph1234`

### Before vs After Index Testing

**Step 1: Drop indexes (to test "before" state)**

```sql
DROP INDEX IF EXISTS idx_trackgenres_genre_id;
DROP INDEX IF EXISTS idx_trackgenres_track_id;
DROP INDEX IF EXISTS idx_audio_track_id;
DROP INDEX IF EXISTS idx_tracks_date_recorded;
DROP INDEX IF EXISTS idx_social_hotttnesss;
```

**Step 2: Run EXPLAIN ANALYZE (before indexes)**

```sql
EXPLAIN ANALYZE
SELECT 
    g.genre_name,
    COUNT(t.track_id) as track_count,
    AVG(a.danceability) as avg_danceability
FROM "Tracks" t
JOIN "TrackGenres" tg ON t.track_id = tg.track_id
JOIN "Genres" g ON tg.genre_id = g.genre_id
JOIN "Audio" a ON t.track_id = a.track_id
GROUP BY g.genre_name;
```

Note the **Execution Time** (e.g., ~50ms). Look for `Seq Scan` in the plan.

**Step 3: Create indexes**

```sql
CREATE INDEX idx_trackgenres_genre_id ON "TrackGenres"(genre_id);
CREATE INDEX idx_trackgenres_track_id ON "TrackGenres"(track_id);
CREATE INDEX idx_audio_track_id ON "Audio"(track_id);
CREATE INDEX idx_tracks_date_recorded ON "Tracks"(track_date_recorded);
CREATE INDEX idx_social_hotttnesss ON "Social"(song_hotttnesss);
ANALYZE;
```

**Step 4: Run EXPLAIN ANALYZE again (after indexes)**

Run the same query from Step 2. Note the new **Execution Time** (e.g., ~10ms). Look for `Index Scan` in the plan.

### Compare Raw Query vs dbt Mart

**Raw query (joins every time):**
```sql
EXPLAIN ANALYZE
SELECT g.genre_name, COUNT(*), AVG(a.energy)
FROM "Tracks" t
JOIN "TrackGenres" tg ON t.track_id = tg.track_id
JOIN "Genres" g ON tg.genre_id = g.genre_id
JOIN "Audio" a ON t.track_id = a.track_id
GROUP BY g.genre_name;
```

**dbt mart (pre-computed):**
```sql
EXPLAIN ANALYZE
SELECT * FROM analytics.mart_genre_profiles;
```

The mart query should be ~50x faster since data is already aggregated.

---

## Notes

- dbt models are **materialized as tables** (not views) for query performance
- Run `dbt run` again after any model changes to rebuild
- The `target/` and `logs/` folders inside `fma_analytics/` are gitignored