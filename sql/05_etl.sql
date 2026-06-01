-- sql/05_etl.sql

-- ── Step 1: Load raw data into staging ──────────────────────
-- Run from psql:
-- \COPY stg_telemetry FROM 'etl/sample_telemetry.tsv' DELIMITER E'\t' CSV HEADER;

-- ── Step 2: Insert valid records into TelemetryEvent ────────
INSERT INTO TelemetryEvent (
    game_id, player_id, sector_id, tic,
    pos_x, pos_y, pos_z,
    mom_x, mom_y, fov, vision_ang,
    health, armor, ammo
)
SELECT
    raw_game_id::INT,
    raw_player_id::INT,
    raw_sector_id::INT,
    raw_tic::INT,
    raw_pos_x::FLOAT8,
    raw_pos_y::FLOAT8,
    raw_pos_z::FLOAT8,
    raw_mom_x::FLOAT8,
    raw_mom_y::FLOAT8,
    raw_fov::FLOAT8,
    raw_vision_ang::FLOAT8,
    raw_health::INT,
    raw_armor::INT,
    raw_ammo::INT
FROM stg_telemetry
WHERE raw_game_id   ~ '^\d+$'
  AND raw_player_id ~ '^\d+$'
  AND raw_sector_id ~ '^\d+$'
  AND raw_tic       ~ '^\d+$'
  AND raw_pos_x     ~ '^-?\d+(\.\d+)?$'
  AND raw_pos_y     ~ '^-?\d+(\.\d+)?$'
  AND raw_health    ~ '^\d+$'
  AND raw_armor     ~ '^\d+$'
  AND raw_ammo      ~ '^\d+$'
ON CONFLICT (game_id, player_id, tic) DO NOTHING;

-- ── Step 3: Log malformed records ───────────────────────────
INSERT INTO etl_error_log (raw_line, error_msg)
SELECT
    concat_ws(E'\t',
        raw_game_id, raw_player_id, raw_sector_id, raw_tic,
        raw_pos_x, raw_pos_y, raw_pos_z,
        raw_mom_x, raw_mom_y, raw_fov, raw_vision_ang,
        raw_health, raw_armor, raw_ammo
    ),
    'Malformed record: invalid numeric fields'
FROM stg_telemetry
WHERE raw_game_id   !~ '^\d+$'
   OR raw_player_id !~ '^\d+$'
   OR raw_tic       !~ '^\d+$'
   OR raw_pos_x     !~ '^-?\d+(\.\d+)?$'
   OR raw_pos_y     !~ '^-?\d+(\.\d+)?$'
   OR raw_health    !~ '^\d+$'
   OR raw_armor     !~ '^\d+$'
   OR raw_ammo      !~ '^\d+$';