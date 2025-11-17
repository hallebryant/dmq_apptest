import ast
import os

import pandas as pd

# Assumes the raw data is in a sub-folder named 'fma_metadata'.
RAW_DATA_DIR = 'fma_metadata'
# The script will create this folder and save the clean files here.
CLEANED_DATA_DIR = 'fma_metadata_cleaned'

# --- Define ALL columns needed for the full schema ---
# We load only these specific columns to keep the process efficient.
COLUMNS_TO_KEEP = {
    'genres': ['genre_id', 'genre_parent_id', 'genre_title'],
    'artists': ['artist_id', 'artist_active_year_begin', 'artist_associated_labels', 'artist_contact',
                'artist_favorites', 'artist_handle', 'artist_members', 'artist_name', 'artist_website'],
    'albums': ['album_id', 'album_date_released', 'album_engineer', 'album_favorites', 'album_listens',
               'album_producer', 'album_title', 'album_tracks', 'album_type', 'artist_name', 'album_url'],
    'tracks': ['track_id', 'album_id', 'artist_id', 'license_title', 'license_url', 'track_bit_rate', 'track_composer',
               'track_date_recorded', 'track_duration', 'track_favorites', 'track_genres', 'track_language_code',
               'track_listens', 'track_lyricist', 'track_title', 'track_url'],
    'echonest': ['Unnamed: 0', 'acousticness', 'danceability', 'energy', 'instrumentalness', 'liveness', 'speechiness',
                 'tempo', 'valence', 'artist_discovery', 'artist_familiarity', 'artist_hotttnesss', 'song_currency',
                 'song_hotttnesss']
}

# --- Automatically build full paths based on the script's location ---
CWD = os.getcwd()
RAW_DATA_PATH = os.path.join(CWD, RAW_DATA_DIR)
CLEANED_DATA_PATH = os.path.join(CWD, CLEANED_DATA_DIR)


def load_raw_data():
    """Phase 1: Loads the original CSV files and reports their row counts."""
    print("=" * 80)
    print("PHASE 1: LOADING RAW DATA & REPORTING 'BEFORE' COUNTS")
    print(f"Reading from: {RAW_DATA_PATH}")
    print("=" * 80)

    try:
        raw_data = {}
        for name, columns in COLUMNS_TO_KEEP.items():
            file_path = os.path.join(RAW_DATA_PATH, f"raw_{name}.csv")
            # The 'echonest' file is special; its real column names start on the 3rd row.
            header_row = 2 if name == 'echonest' else 0
            raw_data[name] = pd.read_csv(file_path, usecols=columns, header=header_row, low_memory=False)

        print("Raw files loaded successfully.\n")
        print("--- Row Counts Before Cleaning ---")
        for name, df in raw_data.items():
            print(f"{name.capitalize():<10}: {len(df):>7,} rows")

        return raw_data

    except (FileNotFoundError, ValueError) as e:
        print(f"\nERROR: Could not load data. {e}")
        print(f"Please make sure your raw CSVs are in a sub-folder named '{RAW_DATA_DIR}'.")
        return None


def clean_and_save_data(raw_data):
    """Phase 2: Cleans data, enforces integrity, saves files, and reports 'after' counts."""
    print("\n" + "=" * 80)
    print("PHASE 2: CLEANING DATA, ENFORCING INTEGRITY & SAVING TO DISK")
    print("=" * 80)

    clean_data = {}

    # 1. Clean independent files first (genres, artists)
    df_genres = raw_data["genres"].copy()
    df_genres.columns = df_genres.columns.str.lower()
    df_genres.dropna(subset=['genre_id'], inplace=True)
    clean_data['genres'] = df_genres.astype({'genre_id': int})

    df_artists = raw_data["artists"].copy()
    df_artists.columns = df_artists.columns.str.lower()
    df_artists.dropna(subset=['artist_id'], inplace=True)
    clean_data['artists'] = df_artists.astype({'artist_id': int})

    # 2. Clean dependent files (albums, tracks)
    print("\n--- Cleaning Albums ---")
    df_albums = raw_data["albums"].copy()
    df_albums.columns = df_albums.columns.str.lower()
    df_albums.dropna(subset=['album_id', 'artist_name'], inplace=True)
    df_albums['album_id'] = df_albums['album_id'].astype(int)
    initial_count = len(df_albums)
    # INTEGRITY CHECK: Only keep an album if its artist exists in our clean artist list.
    df_albums = df_albums[df_albums['artist_name'].isin(set(df_artists['artist_name']))]
    print(f"Removed {initial_count - len(df_albums):,} albums that pointed to an unknown artist.")
    clean_data['albums'] = df_albums

    print("\n--- Cleaning Tracks ---")
    df_tracks = raw_data["tracks"].copy()
    df_tracks.columns = df_tracks.columns.str.lower()
    # Enforce that essential columns like track_id and track_title must exist.
    df_tracks.dropna(subset=['track_id', 'track_title'], inplace=True)
    df_tracks['track_id'] = df_tracks['track_id'].astype(int)
    initial_count = len(df_tracks)
    # INTEGRITY CHECK: Only keep a track if its album AND artist exist in our other clean files.
    df_tracks = df_tracks[df_tracks['album_id'].isin(set(df_albums['album_id'])) & df_tracks['artist_id'].isin(
        set(df_artists['artist_id']))]
    print(f"Removed {initial_count - len(df_tracks):,} tracks that pointed to an unknown album or artist.")
    clean_data['tracks'] = df_tracks

    # 3. Clean the Echonest file (features)
    df_echonest = raw_data["echonest"].copy()
    df_echonest.columns = df_echonest.columns.str.lower()
    df_echonest.rename(columns={'unnamed: 0': 'track_id'}, inplace=True)
    df_echonest = df_echonest[pd.to_numeric(df_echonest['track_id'], errors='coerce').notna()]
    df_echonest['track_id'] = df_echonest['track_id'].astype(int)
    clean_data['echonest'] = df_echonest

    # 4. Save the clean data to new CSV files
    os.makedirs(CLEANED_DATA_PATH, exist_ok=True)
    print(f"\nSaving cleaned files to: {CLEANED_DATA_PATH}\n")
    print("--- Final Row Counts After Cleaning ---")
    for name, df in clean_data.items():
        print(f"{name.capitalize():<10}: {len(df):>7,} rows")
        df.to_csv(os.path.join(CLEANED_DATA_PATH, f"clean_{name}.csv"), index=False)

    print("\nAll cleaned files have been saved.")
    return True


def analyze_and_report():
    """Phase 3: Loads the clean data and analyzes the feasibility of creating extra tables."""
    print("\n" + "=" * 80)
    print(f"PHASE 3: ANALYZING CLEAN DATA FOR FEASIBILITY REPORT")
    print("=" * 80)

    try:
        # Load the clean files we just created.
        clean_data = {name: pd.read_csv(os.path.join(CLEANED_DATA_PATH, f"clean_{name}.csv")) for name in
                      COLUMNS_TO_KEEP.keys()}
        print("Clean files loaded successfully for analysis.\n")
    except FileNotFoundError:
        print("ERROR: Could not find clean data files. Did Phase 2 run correctly?")
        return

    # This helper function checks a column and prints a formatted analysis.
    def analyze_column(df, column_name, entity_name):
        rows_with_data = df[column_name].dropna()
        coverage = (len(rows_with_data) / len(df)) * 100 if len(df) > 0 else 0
        unique_values = rows_with_data.astype(str).str.split(r'[,&\n]').explode().str.strip().nunique()

        print(f"--- Analysis of: {entity_name} (from column '{column_name}') ---")
        print(f"Coverage: {len(rows_with_data):,} / {len(df):,} rows have data ({coverage:.2f}%).")
        print(f"Unique Values: Found {unique_values:,} unique {entity_name.lower()} names.")

        if coverage > 5:
            print("Verdict: FEASIBLE. The data exists to create this table.")
        else:
            print("Verdict: NOT RECOMMENDED. Coverage is extremely low, the resulting table will be nearly empty.")
        print("-" * 50)

    # Run the analysis for each entity we're considering normalizing.
    analyze_column(clean_data["albums"], 'album_engineer', 'Engineers')
    analyze_column(clean_data["tracks"], 'track_lyricist', 'Lyricists')
    analyze_column(clean_data["artists"], 'artist_associated_labels', 'Labels')
    analyze_column(clean_data["tracks"], 'license_title', 'Licenses')

    # Special check for genres, which is a many-to-many relationship.
    print("--- Analysis of: Track <-> Genre Link (from column 'track_genres') ---")
    valid_genre_ids = set(clean_data['genres']['genre_id'])
    total_valid_links = 0
    for genre_str in clean_data['tracks']['track_genres'].dropna():
        try:
            for genre_item in ast.literal_eval(genre_str):
                if int(genre_item.get('genre_id')) in valid_genre_ids:
                    total_valid_links += 1
        except (ValueError, SyntaxError):
            continue
    print(f"Found {total_valid_links:,} valid genre links across all tracks.")
    print("Verdict: ESSENTIAL. A 'TrackGenres' linking table is required to model this relationship.")
    print("-" * 50)


def main():
    """Runs the entire pipeline from start to finish."""
    raw_data = load_raw_data()
    if raw_data:
        if clean_and_save_data(raw_data):
            analyze_and_report()


if __name__ == "__main__":
    main()
