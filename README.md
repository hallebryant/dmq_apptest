# Phase 1: Data Cleaning & Ingestion

This phase cleans raw FMA (Free Music Archive) CSV data and loads it into a normalized PostgreSQL database running in Docker.

---

## Prerequisites

- Docker Desktop installed and running
- Python 3.8+
- Raw FMA data (`raw_*.csv` files) in `fma_metadata/` folder

---

## Project Structure

```
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

```bash
docker compose up -d
```

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