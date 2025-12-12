# Phase 2: Advanced Analytics & dbt

This phase adds indexes, advanced SQL queries, and a dbt-powered star schema on top of the Phase 1 database.
# Phase 1: Data Cleaning & Ingestion

This phase cleans raw FMA (Free Music Archive) CSV data and loads it into a normalized PostgreSQL database running in Docker.

---

## Prerequisites

- Phase 1 completed (database running with data loaded)
- Python virtual environment activated
- dbt-postgres installed (`pip install dbt-postgres`)
- Docker Desktop installed and running
- Python 3.8+
- Raw FMA data (`raw_*.csv` files) in `fma_metadata/` folder

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
├── fma_metadata/           # INPUT: Raw CSV files (you provide)
├── fma_metadata_cleaned/   # OUTPUT: Cleaned CSVs (auto-generated)
│
├── clean_and_report.py     # Data cleaning script
├── ingest_data.py          # Database loader
├── schema.sql              # Table definitions
├── docker-compose.yml      # PostgreSQL container config
├── requirements.txt        # Python dependencies
│
├── security.sql            # Role-based access (optional)
├── test_script.sql         # Validation queries
└── test_results.txt        # Test output
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
### 1. Install Python Dependencies

**Mac/Linux:**
```bash
pip3 install -r requirements.txt
```

**Windows (PowerShell):**
```powershell
python -m pip install -r requirements.txt
```

### 2. Configure Credentials

Edit `docker-compose.yml`:
```yaml
POSTGRES_USER: your_username
POSTGRES_PASSWORD: your_password
POSTGRES_DB: fma_db
```

Create `.env` file (for Python scripts):
```
DB_USER=your_username
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=fma_db
```

### 3. Start Database

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
Verify it's running:
```bash
docker compose ps
```

### 4. Clean Raw Data

**Mac/Linux:**
```bash
python3 clean_and_report.py
```

**Windows:**
```powershell
python clean_and_report.py
```

This creates cleaned CSVs in `fma_metadata_cleaned/`.

### 5. Create Database Schema

**Mac/Linux:**
```bash
docker compose exec -T postgres psql -U your_username -d fma_db < schema.sql
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
Get-Content schema.sql | docker compose exec -T postgres psql -U your_username -d fma_db
```

### 6. Load Data

**Mac/Linux:**
```bash
python3 ingest_data.py
```

**Windows:**
```powershell
python ingest_data.py
```

### 7. Run Validation Tests

**Mac/Linux:**
```bash
docker compose exec -T postgres psql -U your_username -d fma_db < test_script.sql > test_results.txt
```

**Windows (PowerShell):**
```powershell
Get-Content test_script.sql | docker compose exec -T postgres psql -U your_username -d fma_db > test_results.txt
```

---

## Connecting with DBeaver

1. New Connection → PostgreSQL
2. Enter:
   - Host: `localhost`
   - Port: `5432`
   - Database: `fma_db`
   - Username/Password: (from docker-compose.yml)
3. Test Connection → Finish

---

## Quick Reference

| Task | Mac/Linux | Windows (PowerShell) |
|------|-----------|----------------------|
| Start DB | `docker compose up -d` | `docker compose up -d` |
| Stop DB | `docker compose stop` | `docker compose stop` |
| Delete DB | `docker compose down -v` | `docker compose down -v` |
| View logs | `docker compose logs postgres` | `docker compose logs postgres` |
| Open psql | `docker compose exec postgres psql -U username -d fma_db` | Same |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `python` not found (Windows) | Use `python` not `python3`, or check PATH |
| `pip3` not found (Mac) | `python3 -m pip install ...` |
| Connection refused | Check Docker is running: `docker compose ps` |
| Port 5432 in use | Stop other PostgreSQL instances |
| Foreign key errors | Run `clean_and_report.py` before `ingest_data.py` |
| Table exists errors | `docker compose down -v` then start fresh |

---

## Workflow Summary

```
1. Install dependencies
   ↓
2. Configure credentials
   ↓
3. Start Docker (docker compose up -d)
   ↓
4. Clean data (clean_and_report.py)
   ↓
5. Create schema (schema.sql)
   ↓
6. Load data (ingest_data.py)
   ↓
7. Validate (test_script.sql)
```
