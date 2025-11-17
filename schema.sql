-- Drop existing tables in reverse order to avoid dependency errors
DROP TABLE IF EXISTS "Social", "Audio", "TrackLyricists", "TrackGenres", "AlbumEngineers", "ArtistLabels", "AlbumProducers", "TrackComposers", "Tracks", "Licenses", "Albums", "Artists", "Labels", "Lyricists", "Engineers", "Genres", "Producers", "Composers";

-- ============== LOOKUP TABLES (INDEPENDENT ENTITIES) ==============
CREATE TABLE "Genres" (
    "genre_id" INTEGER PRIMARY KEY,
    "parent_id" INTEGER REFERENCES "Genres"("genre_id"),
    "title" VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE "Engineers" (
    "engineer_id" SERIAL PRIMARY KEY,
    "engineer_name" VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE "Lyricists" (
    "lyricist_id" SERIAL PRIMARY KEY,
    "lyricist_name" VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE "Labels" (
    "label_id" SERIAL PRIMARY KEY,
    "label_name" VARCHAR(255) NOT NULL UNIQUE
);


CREATE TABLE "Composers" (
    "composer_id" SERIAL PRIMARY KEY,
    "composer_name" VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE "Licenses" (
    "license_id" SERIAL PRIMARY KEY,
    "license_title" VARCHAR(255) NOT NULL UNIQUE,
    "license_url" VARCHAR(512)
);

CREATE TABLE "Producers" (
    "producer_id" SERIAL PRIMARY KEY,
    "producer_name" VARCHAR(255) NOT NULL UNIQUE
);


-- ============== CORE ENTITY TABLES ==============

CREATE TABLE "Artists" (
    "artist_id" INTEGER PRIMARY KEY,
    "artist_name" VARCHAR(255) NOT NULL,
    "artist_handle" VARCHAR(255),
    "artist_website" VARCHAR(512),
    "artist_active_year_begin" INTEGER,
    "artist_favorites" INTEGER
);

CREATE TABLE "Albums" (
    "album_id" INTEGER PRIMARY KEY,
    "album_title" VARCHAR(255) NOT NULL,
    "album_type" VARCHAR(50),
    "album_tracks" INTEGER,
    "album_date_released" DATE,
    "album_listens" INTEGER,
    "album_favorites" INTEGER,
    "artist_id" INTEGER NOT NULL REFERENCES "Artists"("artist_id")
);

CREATE TABLE "Tracks" (
    "track_id" INTEGER PRIMARY KEY,
    "track_title" VARCHAR(255) NOT NULL,
    "track_language_code" VARCHAR(10),
    "track_listens" INTEGER,
    "track_favorites" INTEGER,
    "track_url" VARCHAR(512),
    "track_duration" VARCHAR(10),
    "track_bit_rate" INTEGER,
    "track_date_recorded" DATE,
    "track_explicit" VARCHAR(20),
    "album_id" INTEGER REFERENCES "Albums"("album_id"),
    "artist_id" INTEGER REFERENCES "Artists"("artist_id"),
    "license_id" INTEGER REFERENCES "Licenses"("license_id")
);


-- ============== LINKING TABLES (MANY-TO-MANY RELATIONSHIPS) ==============

CREATE TABLE "AlbumEngineers" (
    "album_id" INTEGER NOT NULL REFERENCES "Albums"("album_id"),
    "engineer_id" INTEGER NOT NULL REFERENCES "Engineers"("engineer_id"),
    PRIMARY KEY ("album_id", "engineer_id")
);

CREATE TABLE "AlbumProducers" (
    "album_id" INTEGER NOT NULL REFERENCES "Albums"("album_id"),
    "producer_id" INTEGER NOT NULL REFERENCES "Producers"("producer_id"),
    PRIMARY KEY ("album_id", "producer_id")
);

CREATE TABLE "ArtistLabels" (
    "artist_id" INTEGER NOT NULL REFERENCES "Artists"("artist_id"),
    "label_id" INTEGER NOT NULL REFERENCES "Labels"("label_id"),
    PRIMARY KEY ("artist_id", "label_id")
);

CREATE TABLE "TrackGenres" (
    "track_id" INTEGER NOT NULL REFERENCES "Tracks"("track_id"),
    "genre_id" INTEGER NOT NULL REFERENCES "Genres"("genre_id"),
    PRIMARY KEY ("track_id", "genre_id")
);

CREATE TABLE "TrackLyricists" (
    "track_id" INTEGER NOT NULL REFERENCES "Tracks"("track_id"),
    "lyricist_id" INTEGER NOT NULL REFERENCES "Lyricists"("lyricist_id"),
    PRIMARY KEY ("track_id", "lyricist_id")
);

CREATE TABLE "TrackComposers" (
    "track_id" INTEGER NOT NULL REFERENCES "Tracks"("track_id"),
    "composer_id" INTEGER NOT NULL REFERENCES "Composers"("composer_id"),
    PRIMARY KEY ("track_id", "composer_id")
);


-- ============== FEATURE TABLES (ONE-TO-ONE RELATIONSHIPS) ==============

CREATE TABLE "Audio" (
    "track_id" INTEGER PRIMARY KEY REFERENCES "Tracks"("track_id") ON DELETE CASCADE,
    "acousticness" REAL,
    "danceability" REAL,
    "energy" REAL,
    "instrumentalness" REAL,
    "liveness" REAL,
    "speechiness" REAL,
    "tempo" REAL,
    "valence" REAL
);

CREATE TABLE "Social" (
    "track_id" INTEGER PRIMARY KEY REFERENCES "Tracks"("track_id") ON DELETE CASCADE,
    "artist_discovery" REAL,
    "artist_familiarity" REAL,
    "artist_hotttnesss" REAL,
    "song_currency" REAL,
    "song_hotttnesss" REAL
);