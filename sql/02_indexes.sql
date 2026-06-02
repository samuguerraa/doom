-- sql/02_indexes.sql

-- Index 1: Most critical — used by trajectory and proximity queries
CREATE INDEX idx_tel_game_player_tic
ON TelemetryEvent(game_id, player_id, tic);

-- Index 2: Sector-based queries (hotspots, co-presence)
CREATE INDEX idx_tel_sector
ON TelemetryEvent(sector_id, game_id);

-- Index 3: GameParticipant joins
CREATE INDEX idx_gp_player_game
ON GameParticipant(player_id, game_id);

-- Bonus: GiST spatial index on position (requires postgis or point type)
-- CREATE INDEX idx_tel_position
-- ON TelemetryEvent USING gist (point(pos_x, pos_y));