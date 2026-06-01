-- sql/01_schema.sql

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Episode
CREATE TABLE Episode (
    episode_id   SERIAL PRIMARY KEY,
    episode_name VARCHAR(100) NOT NULL,
    episode_num  INT NOT NULL
);

-- Map
CREATE TABLE Map (
    map_id     SERIAL PRIMARY KEY,
    episode_id INT NOT NULL REFERENCES Episode(episode_id),
    map_name   VARCHAR(100) NOT NULL,
    map_code   VARCHAR(10) NOT NULL,
    map_num    INT NOT NULL
);

-- Sector
CREATE TABLE Sector (
    sector_id   SERIAL PRIMARY KEY,
    map_id      INT NOT NULL REFERENCES Map(map_id),
    min_x       FLOAT8 NOT NULL,
    max_x       FLOAT8 NOT NULL,
    min_y       FLOAT8 NOT NULL,
    max_y       FLOAT8 NOT NULL,
    sector_name VARCHAR(100)
);

-- UXInstrument
CREATE TABLE UXInstrument (
    instrument_id   SERIAL PRIMARY KEY,
    instrument_name VARCHAR(50) NOT NULL,
    version         VARCHAR(20) NOT NULL
);

-- UXItem
CREATE TABLE UXItem (
    item_id       SERIAL PRIMARY KEY,
    instrument_id INT NOT NULL REFERENCES UXInstrument(instrument_id),
    item_number   INT NOT NULL,
    item_text     TEXT NOT NULL,
    subscale      VARCHAR(50) NOT NULL,
    scale_min     INT NOT NULL,
    scale_max     INT NOT NULL
);

-- User
CREATE TABLE "User" (
    user_id SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL,
    age     INT NOT NULL CHECK (age > 0),
    consent BOOLEAN NOT NULL DEFAULT TRUE,
    region  VARCHAR(100)
);

-- Player
CREATE TABLE Player (
    player_id  SERIAL PRIMARY KEY,
    user_id    INT NOT NULL REFERENCES "User"(user_id),
    nickname   VARCHAR(50) NOT NULL,
    game_level VARCHAR(20)
);

-- Game
CREATE TABLE Game (
    game_id  SERIAL PRIMARY KEY,
    map_id   INT NOT NULL REFERENCES Map(map_id),
    start_ts TIMESTAMPTZ NOT NULL,
    end_ts   TIMESTAMPTZ
);

-- GameParticipant
CREATE TABLE GameParticipant (
    player_id INT NOT NULL REFERENCES Player(player_id),
    game_id   INT NOT NULL REFERENCES Game(game_id),
    team      VARCHAR(20),
    survived  BOOLEAN,
    kills     INT DEFAULT 0 CHECK (kills >= 0),
    assists   INT DEFAULT 0 CHECK (assists >= 0),
    score     INT DEFAULT 0,
    PRIMARY KEY (player_id, game_id)
);

-- UXResponse
CREATE TABLE UXResponse (
    response_id   SERIAL PRIMARY KEY,
    user_id       INT REFERENCES "User"(user_id),
    instrument_id INT NOT NULL REFERENCES UXInstrument(instrument_id),
    game_id       INT NOT NULL REFERENCES Game(game_id),
    response_date TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- UXResponseItem
CREATE TABLE UXResponseItem (
    response_id INT NOT NULL REFERENCES UXResponse(response_id),
    item_id     INT NOT NULL REFERENCES UXItem(item_id),
    value       INT NOT NULL CHECK (value BETWEEN 1 AND 5),
    PRIMARY KEY (response_id, item_id)
);

-- TelemetryEvent
CREATE TABLE TelemetryEvent (
    event_id   SERIAL PRIMARY KEY,
    game_id    INT NOT NULL REFERENCES Game(game_id),
    player_id  INT NOT NULL REFERENCES Player(player_id),
    sector_id  INT REFERENCES Sector(sector_id),
    tic        INT NOT NULL CHECK (tic >= 1),
    pos_x      FLOAT8 NOT NULL,
    pos_y      FLOAT8 NOT NULL,
    pos_z      FLOAT8 NOT NULL,
    mom_x      FLOAT8,
    mom_y      FLOAT8,
    fov        FLOAT8,
    vision_ang FLOAT8,
    health     INT CHECK (health >= 0),
    armor      INT CHECK (armor BETWEEN 0 AND 200),
    ammo       INT CHECK (ammo >= 0),
    UNIQUE (game_id, player_id, tic)
);

-- Staging table
CREATE TABLE stg_telemetry (
    raw_game_id   TEXT,
    raw_player_id TEXT,
    raw_sector_id TEXT,
    raw_tic       TEXT,
    raw_pos_x     TEXT,
    raw_pos_y     TEXT,
    raw_pos_z     TEXT,
    raw_mom_x     TEXT,
    raw_mom_y     TEXT,
    raw_fov       TEXT,
    raw_vision_ang TEXT,
    raw_health    TEXT,
    raw_armor     TEXT,
    raw_ammo      TEXT,
    loaded_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ETL error log
CREATE TABLE etl_error_log (
    error_id  SERIAL PRIMARY KEY,
    raw_line  TEXT,
    error_msg TEXT,
    logged_at TIMESTAMPTZ DEFAULT NOW()
);