# FMA Database Project

This project takes the raw Free Music Archive (FMA) dataset, cleans it, and loads it into a fully normalized PostgreSQL database running in Docker. This README provides step-by-step instructions suitable for beginners.

## ✨ Quick Start

**For Windows users:** Use PowerShell or Command Prompt (not Git Bash)  
**For Mac users:** Use Terminal  
**Both:** Ensure Docker Desktop is installed and running before starting

---

## What This Project Does

1. **Cleans** raw CSV data from the Free Music Archive
2. **Validates** data integrity and relationships
3. **Creates** a properly structured PostgreSQL database
4. **Loads** the cleaned data into the database
5. **Provides** tools for testing and validation

---

## Project Structure

```
.
├── fma_metadata/           # INPUT: Place your downloaded raw CSV files here
├── fma_metadata_cleaned/   # OUTPUT: Cleaned CSVs (generated automatically)
├── fma_metadata_sampled/   # UTILITY: Smaller sample dataset for testing
│
├── clean_and_report.py     # Script for data cleaning and validation
├── ingest_data.py          # Script to load data into the database
├── schema.sql              # Database table definitions (DDL)
│
├── docker-compose.yml      # Docker configuration for PostgreSQL
├── README.md               # This file
├── requirements.txt        # Python dependencies
│
├── sampler.py              # Creates sample dataset for testing
├── generate_file_schema.py # Analyzes CSV structure
├── files_schema.json       # CSV structure documentation
│
├── security.sql            # Optional: Database user roles and permissions
├── test_script.sql         # Validation queries
└── test_results.txt        # Test output
```

---

## 🖥️ Terminal/Command Prompt Basics

### For Windows Users:

**Opening Command Prompt/PowerShell:**
1. Press `Windows + R`
2. Type `cmd` (Command Prompt) or `powershell` (PowerShell)
3. Press Enter

**Or:** Right-click in the project folder while holding Shift → "Open PowerShell window here"

**Recommended:** Use PowerShell for better compatibility

### For Mac Users:

**Opening Terminal:**
1. Press `Command + Space` to open Spotlight
2. Type `terminal`
3. Press Enter

**Or:** Go to Applications → Utilities → Terminal

**Tip:** You can drag a folder onto Terminal to navigate to that location

---

## Prerequisites

Before starting, make sure you have these installed on your computer:

### 1. **Docker Desktop**
   
   **For Windows:**
   - **Download:** [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
   - **Requirements:** Windows 10/11 64-bit with WSL 2
   - **Installation:** Run the installer and enable WSL 2 when prompted
   - **Important:** Restart your computer after installation
   
   **For Mac:**
   - **Download:** [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)
   - **Intel Chips:** Use the standard Mac installer
   - **Apple Silicon (M1/M2/M3):** Use the Apple Chip installer
   - **Installation:** Drag Docker to Applications folder
   
   **Verification (Both Platforms):**
   
   Open your terminal (Mac) or Command Prompt/PowerShell (Windows) and run:
   ```bash
   docker --version
   ```
   You should see output like: `Docker version 24.x.x`

### 2. **Python 3**
   
   **For Windows:**
   - **Download:** [Python for Windows](https://www.python.org/downloads/)
   - **Installation:** Run the installer
   - **IMPORTANT:** Check "Add Python to PATH" during installation
   - **Verification:** Open Command Prompt and run:
     ```bash
     python --version
     ```
   
   **For Mac:**
   - **Option 1 - Homebrew (Recommended):**
     ```bash
     # Install Homebrew if you don't have it
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
     
     # Install Python
     brew install python3
     ```
   - **Option 2 - Official Installer:** [Python for Mac](https://www.python.org/downloads/)
   - **Verification:** Open Terminal and run:
     ```bash
     python3 --version
     ```
   
   **Minimum Version (Both Platforms):** Python 3.8 or higher

### 3. **DBeaver (Optional but Recommended)**
   - **Download:** [https://dbeaver.io/download/](https://dbeaver.io/download/)
   - **Purpose:** Visual database management tool to browse and query your data
   - **Alternative:** You can use pgAdmin, DataGrip, or any PostgreSQL client

### 4. **FMA Raw Data**
   - **Download:** Get the FMA metadata from the official source
   - **Action Required:** Extract all `raw_*.csv` files into the `fma_metadata/` folder

---

## Complete Setup Guide

### ✅ Before You Begin - Verification Checklist

Make sure everything is installed correctly before starting:

**1. Check Docker:**
```bash
docker --version
docker compose version
```
Expected output: Version numbers for both commands

**2. Check Python:**

*Windows:*
```bash
python --version
```

*Mac:*
```bash
python3 --version
```
Expected output: Python 3.8 or higher

**3. Verify Docker Desktop is Running:**
- **Windows:** Look for Docker icon in system tray (bottom-right)
- **Mac:** Look for Docker icon in menu bar (top-right)
- Icon should be steady (not animated)

**4. Verify Project Structure:**
Ensure you have these folders/files in your project:
- `fma_metadata/` (with your raw CSV files)
- `docker-compose.yml`
- `schema.sql`
- `clean_and_report.py`
- `ingest_data.py`
- `requirements.txt`

---

Follow these steps in order. Each step must complete successfully before moving to the next.

### Step 1: Install Python Dependencies

Open your terminal/command prompt in the project root directory and run:

**For Windows (Command Prompt or PowerShell):**
```bash
# Navigate to project folder first
cd path\to\fma-database-project

# Install dependencies
python -m pip install -r requirements.txt
```

**For Mac (Terminal):**
```bash
# Navigate to project folder first
cd /path/to/fma-database-project

# Install dependencies
pip3 install -r requirements.txt
# or if the above doesn't work:
python3 -m pip install -r requirements.txt
```

**What this does:** Installs all required Python libraries (pandas, psycopg2, etc.)

**Troubleshooting:**

*Windows:*
- If `python` is not recognized, you may need to reinstall Python and check "Add to PATH"
- Try running Command Prompt as Administrator if you get permission errors
- If you see SSL certificate errors, try: `python -m pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt`

*Mac:*
- If you get permission errors, try: `pip3 install --user -r requirements.txt`
- Never use `sudo pip` - it can break your system Python
- If `pip3` is not found, ensure Python 3 is properly installed

---

### Step 2: Start the PostgreSQL Database

Start Docker Desktop, then run:

```bash
docker compose up -d
```

**What this does:** 
- Downloads the PostgreSQL Docker image (first time only)
- Creates and starts a PostgreSQL database container
- Runs it in detached mode (background)

**Expected output:** 
```
[+] Running 1/1
 ✔ Container fma-postgres-1  Started
```

**To verify it's running:**
```bash
docker compose ps
```

You should see a container with status "Up"

**To stop the database later (without deleting data):**
```bash
docker compose stop
```

**To stop and remove the database (deletes all data):**
```bash
docker compose down -v
```

---

### Step 3: Clean and Validate the Raw Data

This is the data preparation phase:

**For Windows:**
```bash
python clean_and_report.py
```

**For Mac:**
```bash
python3 clean_and_report.py
```

**What this does:**
- Reads all CSV files from `fma_metadata/`
- Cleans data (handles missing values, formats dates, etc.)
- Validates data integrity and relationships
- Generates cleaned CSV files in `fma_metadata_cleaned/`
- Creates a detailed report of issues found

**Expected output:** Progress messages and statistics about the cleaning process

**Time:** This may take several minutes depending on dataset size

**Troubleshooting:**

*Windows:*
- If you see "python is not recognized", make sure Python was added to PATH during installation
- File path issues: Ensure your CSV files are in `fma_metadata\` (use backslashes on Windows)
- Antivirus software may slow down file operations - add the project folder to exclusions

*Mac:*
- If you get "Permission denied", check file permissions: `chmod +x clean_and_report.py`
- File path issues: Ensure your CSV files are in `fma_metadata/` (use forward slashes on Mac)

---

### Step 4: Create the Database Schema

This command creates all the empty tables in your database:

**For Windows (PowerShell):**
```bash
Get-Content schema.sql | docker compose exec -T postgres psql -U arun-ghontale -d fma_db
```

**For Windows (Command Prompt):**
```bash
type schema.sql | docker compose exec -T postgres psql -U arun-ghontale -d fma_db
```

**For Mac:**
```bash
docker compose exec -T postgres psql -U arun-ghontale -d fma_db < schema.sql
```

**Important:** Replace `arun-ghontale` with the username specified in your `docker-compose.yml` file (look for `POSTGRES_USER`).

**What this does:**
- Connects to the running PostgreSQL container
- Executes the SQL commands in `schema.sql`
- Creates tables, indexes, and constraints

**Expected output:** 
```
CREATE TABLE
CREATE TABLE
CREATE INDEX
...
```

**Troubleshooting:**

*Windows:*
- Make sure Docker Desktop is running and the container is active
- Use PowerShell or Command Prompt (not Git Bash) for best compatibility
- If you see "The system cannot find the file specified", ensure you're in the project root directory
- For path issues, try: `docker compose exec -T postgres psql -U arun-ghontale -d fma_db -f /path/to/schema.sql`

*Mac:*
- If you get "role does not exist", check that the username matches your `docker-compose.yml`
- If you get "database does not exist", verify your `docker-compose.yml` has the correct `POSTGRES_DB` value
- Permission issues: Try `chmod +r schema.sql`

*Both Platforms:*
- Ensure Docker Desktop is running before executing this command
- Verify the container is up: `docker compose ps`

---

### Step 5: Load Data into the Database

Before running this step, open `ingest_data.py` and verify that these variables at the top match your `docker-compose.yml`:

```python
DB_USER = "arun-ghontale"      # Must match POSTGRES_USER
DB_PASSWORD = "your_password"  # Must match POSTGRES_PASSWORD
```

Then run:

**For Windows:**
```bash
python ingest_data.py
```

**For Mac:**
```bash
python3 ingest_data.py
```

**What this does:**
- Connects to the PostgreSQL database
- Reads cleaned CSV files from `fma_metadata_cleaned/`
- Inserts data into all tables
- Shows progress for each table

**Expected output:** Progress bars or messages showing data being inserted

**Time:** This may take several minutes to hours depending on dataset size

**Troubleshooting:**

*Windows:*
- If you see encoding errors, ensure your CSV files are UTF-8 encoded
- Path separator issues: Python handles both `/` and `\` on Windows, but prefer `/` in code
- Memory errors: Close other applications to free up RAM
- Firewall warnings: Allow Python to access the network if prompted

*Mac:*
- If connection fails, check Docker Desktop is running
- Permission errors: Ensure the `fma_metadata_cleaned/` folder is readable
- If you get SSL errors, ensure your Docker container is properly configured

*Both Platforms:*
- Connection refused: Verify the database is running with `docker compose ps`
- Check that port 5432 is not blocked by firewall
- Ensure credentials in `ingest_data.py` match `docker-compose.yml` exactly

---

## Connecting with DBeaver

After completing all setup steps, you can use DBeaver to visually explore your database:

### 1. Open DBeaver and Create a New Connection

1. Click **Database** → **New Database Connection**
2. Select **PostgreSQL**
3. Click **Next**

### 2. Enter Connection Details

Use these settings (match with your `docker-compose.yml`):

- **Host:** `localhost`
- **Port:** `5432`
- **Database:** `fma_db` (or whatever is in your POSTGRES_DB)
- **Username:** `arun-ghontale` (or your POSTGRES_USER)
- **Password:** Your POSTGRES_PASSWORD
- **Show all databases:** Unchecked (optional)

### 3. Test and Connect

1. Click **Test Connection** 
   - If successful, you'll see "Connected"
   - If failed, check that Docker container is running
2. Click **Finish**

### 4. Explore Your Data

- Expand the connection in the left sidebar
- Navigate to **Databases** → **fma_db** → **Schemas** → **public** → **Tables**
- Right-click any table and select **View Data** to browse records
- Use the SQL Editor (click **SQL Editor** button) to run custom queries

**Example Query to Try:**
```sql
SELECT COUNT(*) FROM tracks;
SELECT * FROM artists LIMIT 10;
```

---

## Validation and Testing

### Run Validation Tests

After completing all steps, validate your database:

**For Windows (PowerShell):**
```bash
Get-Content test_script.sql | docker compose exec -T postgres psql -U arun-ghontale -d fma_db > test_results.txt
```

**For Windows (Command Prompt):**
```bash
type test_script.sql | docker compose exec -T postgres psql -U arun-ghontale -d fma_db > test_results.txt
```

**For Mac:**
```bash
docker compose exec -T postgres psql -U arun-ghontale -d fma_db < test_script.sql > test_results.txt
```

**What this does:**
- Runs a series of test queries
- Saves results to `test_results.txt`

**What to check:**
- Open `test_results.txt` in any text editor
- Verify table row counts are reasonable
- Check that relationships between tables are correct
- Look for any NULL values where there shouldn't be any

---

## Optional: Set Up Database Security

To create read-only and read-write user roles:

**For Windows (PowerShell):**
```bash
Get-Content security.sql | docker compose exec -T postgres psql -U arun-ghontale -d fma_db
```

**For Windows (Command Prompt):**
```bash
type security.sql | docker compose exec -T postgres psql -U arun-ghontale -d fma_db
```

**For Mac:**
```bash
docker compose exec -T postgres psql -U arun-ghontale -d fma_db < security.sql
```

**What this does:**
- Creates different user roles with specific permissions
- Useful for production or multi-user environments

---

## Utility Scripts

### Create a Sample Dataset

For quick testing with a smaller dataset:

**For Windows:**
```bash
python sampler.py
```

**For Mac:**
```bash
python3 sampler.py
```

**What this does:**
- Creates `fma_metadata_sampled/` folder
- Extracts a smaller sample from the raw data
- Useful for development and testing

### Inspect CSV Structure

To analyze the structure of your CSV files:

**For Windows:**
```bash
python generate_file_schema.py
```

**For Mac:**
```bash
python3 generate_file_schema.py
```

**What this does:**
- Examines all CSV files
- Generates `files_schema.json` with column information
- Helpful for understanding the data structure

---

## Common Docker Commands

Here are useful Docker commands for managing your database:

```bash
# Start the database (if stopped)
docker compose start

# Stop the database (keeps data)
docker compose stop

# View running containers
docker compose ps

# View container logs
docker compose logs postgres

# Open a PostgreSQL shell
docker compose exec postgres psql -U arun-ghontale -d fma_db

# Stop and remove everything (DELETES ALL DATA!)
docker compose down -v

# Rebuild and restart (if you changed docker-compose.yml)
docker compose up -d --force-recreate
```

---

## Troubleshooting

### Docker Desktop Issues

**Windows:**
- **Problem:** "Docker Desktop requires Windows 10/11"
  - **Solution:** Upgrade your Windows or use Docker Toolbox (legacy)
  
- **Problem:** WSL 2 installation fails
  - **Solution:** Run in PowerShell as Administrator:
    ```powershell
    wsl --install
    wsl --set-default-version 2
    ```
  
- **Problem:** "Hardware virtualization is not enabled"
  - **Solution:** Enable VT-x/AMD-V in BIOS settings
  
- **Problem:** Docker Desktop won't start
  - **Solution:** 
    1. Restart Docker Desktop
    2. Check Task Manager for conflicting processes
    3. Reset Docker Desktop to factory defaults
    4. Disable antivirus temporarily and restart

**Mac:**
- **Problem:** "Docker Desktop is not installed properly"
  - **Solution:** Drag Docker.app to Applications and launch from there
  
- **Problem:** Docker commands fail with permission errors
  - **Solution:** Add your user to docker group (usually not needed on Mac)
  
- **Problem:** Slow performance on Apple Silicon
  - **Solution:** Ensure you're using the Apple Silicon version of Docker Desktop
  
- **Problem:** "Cannot connect to Docker daemon"
  - **Solution:** 
    1. Ensure Docker Desktop is running (check menu bar)
    2. Restart Docker Desktop
    3. Check System Preferences → Security & Privacy for any blocks

### Database Connection Issues

**Problem:** Cannot connect to database from Python/DBeaver

**Windows Solutions:**
1. Check Windows Firewall isn't blocking port 5432
   - Go to Windows Defender Firewall → Advanced Settings → Inbound Rules
   - Add rule for port 5432 if needed
2. Verify Docker container is running: `docker compose ps`
3. Try connecting to `127.0.0.1` instead of `localhost`
4. Disable VPN if active

**Mac Solutions:**
1. Verify Docker Desktop is running
2. Check container status: `docker compose ps`
3. Ensure no other PostgreSQL is running on port 5432: `lsof -i :5432`
4. Try restarting Docker Desktop

**Both Platforms:**
1. Verify credentials match `docker-compose.yml`
2. Check logs: `docker compose logs postgres`
3. Test connection: `docker compose exec postgres psql -U arun-ghontale -d fma_db -c "SELECT 1;"`

### Python Script Errors

**Windows:**
- **Problem:** `python` command not recognized
  - **Solution:** Add Python to PATH or use full path: `C:\Python39\python.exe`
  
- **Problem:** "Access is denied" during pip install
  - **Solution:** Run Command Prompt as Administrator or use `--user` flag
  
- **Problem:** psycopg2 installation fails
  - **Solution:** Install psycopg2-binary instead: `python -m pip install psycopg2-binary`
  
- **Problem:** CSV encoding errors
  - **Solution:** Save CSV files as UTF-8 in Notepad++ or VS Code

**Mac:**
- **Problem:** `pip` not found
  - **Solution:** Use `pip3` or install via: `python3 -m ensurepip`
  
- **Problem:** "Operation not permitted" errors
  - **Solution:** Never use `sudo` with pip; use `pip3 install --user` instead
  
- **Problem:** psycopg2 installation fails
  - **Solution:** 
    ```bash
    brew install postgresql
    pip3 install psycopg2-binary
    ```
  
- **Problem:** SSL certificate errors
  - **Solution:** Update certificates:
    ```bash
    /Applications/Python\ 3.x/Install\ Certificates.command
    ```

### Data Loading Issues

**Problem:** Foreign key constraint violations

**Solution (Both Platforms):**
1. Ensure you ran `clean_and_report.py` before `ingest_data.py`
2. Check that cleaned data is in `fma_metadata_cleaned/`
3. Verify no data corruption in CSV files

**Problem:** Table already exists errors

**Solution:**

*Windows:*
```bash
docker compose exec postgres psql -U arun-ghontale -d fma_db -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
Get-Content schema.sql | docker compose exec -T postgres psql -U arun-ghontale -d fma_db
```

*Mac:*
```bash
docker compose exec postgres psql -U arun-ghontale -d fma_db -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
docker compose exec -T postgres psql -U arun-ghontale -d fma_db < schema.sql
```

**Problem:** Out of memory errors

**Solution (Both Platforms):**
1. Increase Docker memory allocation in Docker Desktop settings (4GB minimum recommended)
2. Process data in smaller batches by modifying scripts
3. Close other memory-intensive applications

### File Path Issues

**Windows:**
- Use either forward slashes `/` or double backslashes `\\` in Python code
- Avoid spaces in folder names
- Keep the project path short (not too deep in folder structure)

**Mac:**
- Use forward slashes `/` only
- Avoid special characters in folder names
- Check file permissions: `ls -la fma_metadata/`

### Platform-Specific Tips

**Windows:**
- Use PowerShell for better Unicode support
- Disable real-time antivirus scanning for project folder
- Consider using Windows Terminal for better experience
- If using Git Bash, some commands may behave differently - use PowerShell instead

**Mac:**
- Grant Terminal full disk access in System Preferences → Security & Privacy
- Install Xcode Command Line Tools if you get compiler errors: `xcode-select --install`
- Use Homebrew for managing dependencies
- Keep macOS updated for best Docker compatibility

---

## Project Workflow Summary

```
1. Install Python packages
   ↓
2. Start Docker database (docker compose up -d)
   ↓
3. Clean raw data (python/python3 clean_and_report.py)
   ↓
4. Create database tables (platform-specific SQL command)
   ↓
5. Load cleaned data (python/python3 ingest_data.py)
   ↓
6. Connect with DBeaver (optional)
   ↓
7. Run validation tests
   ↓
8. Query and analyze your data!
```

**Platform Notes:**
- **Windows:** Use `python` and PowerShell/Command Prompt
- **Mac:** Use `python3` and Terminal
- **Both:** Docker commands are the same (`docker compose`)

---

## 📝 Editing Configuration Files

Before running the scripts, you'll need to edit `docker-compose.yml` and `ingest_data.py` to set your credentials.

### Recommended Text Editors:

**Windows:**
- Notepad++ (free) - [Download](https://notepad-plus-plus.org/)
- Visual Studio Code (free) - [Download](https://code.visualstudio.com/)
- Notepad (built-in, but less features)

**Mac:**
- Visual Studio Code (free) - [Download](https://code.visualstudio.com/)
- TextEdit (built-in) - Make sure it's in "Plain Text" mode
- Sublime Text (free trial) - [Download](https://www.sublimetext.com/)

### Important Settings:

**When editing `docker-compose.yml`:**
- Don't change the indentation (spaces matter in YAML!)
- Update these values:
  ```yaml
  POSTGRES_USER: your_username
  POSTGRES_PASSWORD: your_password
  POSTGRES_DB: fma_db
  ```

**When editing `ingest_data.py`:**
- Find the top of the file
- Update these variables to match your `docker-compose.yml`:
  ```python
  DB_USER = "your_username"
  DB_PASSWORD = "your_password"
  ```

---

## 📋 Quick Reference - Command Comparison

| Task | Windows (PowerShell) | Mac (Terminal) |
|------|---------------------|----------------|
| Install packages | `python -m pip install -r requirements.txt` | `pip3 install -r requirements.txt` |
| Start database | `docker compose up -d` | `docker compose up -d` |
| Run cleaning script | `python clean_and_report.py` | `python3 clean_and_report.py` |
| Create schema | `Get-Content schema.sql \| docker compose exec -T postgres psql -U username -d fma_db` | `docker compose exec -T postgres psql -U username -d fma_db < schema.sql` |
| Load data | `python ingest_data.py` | `python3 ingest_data.py` |
| Run tests | `Get-Content test_script.sql \| docker compose exec -T postgres psql -U username -d fma_db > test_results.txt` | `docker compose exec -T postgres psql -U username -d fma_db < test_script.sql > test_results.txt` |
| View logs | `docker compose logs postgres` | `docker compose logs postgres` |
| Stop database | `docker compose down` | `docker compose down` |

**Note:** Replace `username` with your actual PostgreSQL username from `docker-compose.yml`

---

## Need Help?

- **Docker Issues:** [Docker Documentation](https://docs.docker.com/)
- **PostgreSQL:** [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- **DBeaver:** [DBeaver Documentation](https://dbeaver.com/docs/)
- **Python:** [Python Documentation](https://docs.python.org/)

---

## ❓ Frequently Asked Questions

### Windows-Specific Questions

**Q: Should I use Command Prompt, PowerShell, or Git Bash?**  
A: Use PowerShell. Git Bash can have compatibility issues with Docker commands.

**Q: Why does my antivirus keep flagging the scripts?**  
A: Python scripts can trigger false positives. Add the project folder to your antivirus exclusions.

**Q: Docker Desktop is using too much memory/CPU!**  
A: Adjust resource limits in Docker Desktop → Settings → Resources. Allocate 2-4 GB RAM minimum.

**Q: File paths with spaces cause errors. What do I do?**  
A: Either:
- Wrap the path in quotes: `cd "C:\My Projects\fma-project"`
- Use paths without spaces: `cd C:\Projects\fma-project`

### Mac-Specific Questions

**Q: Should I install Python from Homebrew or the official installer?**  
A: Homebrew is recommended for easier package management, but both work fine.

**Q: Why do I need Xcode Command Line Tools?**  
A: Some Python packages (like psycopg2) need to compile C extensions. Install with: `xcode-select --install`

**Q: Docker commands are slow on my Mac. Why?**  
A: 
- Use the correct Docker Desktop for your chip (Intel vs Apple Silicon)
- Check Docker Desktop → Settings → Resources and allocate more CPU/memory

**Q: I get "Operation not permitted" when running scripts**  
A: Grant Terminal full disk access: System Preferences → Security & Privacy → Privacy → Full Disk Access → Add Terminal

### General Questions

**Q: How much disk space do I need?**  
A: Minimum 5GB free space. More if your dataset is very large.

**Q: Can I run this on Linux?**  
A: Yes! Follow the Mac instructions - they work on most Linux distributions.

**Q: The setup is taking too long. Is this normal?**  
A: 
- First-time Docker image download: 5-10 minutes
- Data cleaning: 5-30 minutes (depending on dataset size)
- Data loading: 10-60 minutes (depending on dataset size)

**Q: Can I pause and resume the setup?**  
A: Yes, but complete each numbered step fully before stopping. The database container can be stopped with `docker compose stop` and restarted with `docker compose start`.

---

## License

[Add your license information here]

## Contributors

[Add contributor information here]