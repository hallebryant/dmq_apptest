-- Indexes to speed up joins and filtering
CREATE INDEX IF NOT EXISTS idx_trackgenres_genre_id ON "TrackGenres"(genre_id);
CREATE INDEX IF NOT EXISTS idx_trackgenres_track_id ON "TrackGenres"(track_id);
CREATE INDEX IF NOT EXISTS idx_audio_track_id ON "Audio"(track_id);
CREATE INDEX IF NOT EXISTS idx_tracks_date_recorded ON "Tracks"(track_date_recorded);
CREATE INDEX IF NOT EXISTS idx_social_hotttnesss ON "Social"(song_hotttnesss);

-- Update stats so the planner sees the new indexes
ANALYZE;