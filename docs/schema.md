# RELATIONAL SCHEMA

## Episode
- episode_id: SERIAL, PK
- episode_name: VARCHAR(100), NOT NULL
- episode_num: INT, NOT NULL

## Map
- map_id: SERIAL, PK
- episode_id: INT, FK → Episode(episode_id), NOT NULL
- map_name: VARCHAR(100), NOT NULL
- map_code: VARCHAR(10), NOT NULL
- map_num: INT, NOT NULL

## Sector
- sector_id: SERIAL, PK
- map_id: INT, FK → Map(map_id), NOT NULL
- min_x: FLOAT8, NOT NULL
- max_x: FLOAT8, NOT NULL
- min_y: FLOAT8, NOT NULL
- max_y: FLOAT8, NOT NULL
- sector_name: VARCHAR(100)

## UXInstrument
- instrument_id: SERIAL, PK
- instrument_name: VARCHAR(50), NOT NULL
- version: VARCHAR(20), NOT NULL

## UXItem
- item_id: SERIAL, PK
- instrument_id: INT, FK → UXInstrument(instrument_id), NOT NULL
- item_number: INT, NOT NULL
- item_text: TEXT, NOT NULL
- subscale: VARCHAR(50), NOT NULL
- scale_min: INT, NOT NULL
- scale_max: INT, NOT NULL

## User
- user_id: SERIAL, PK
- name: VARCHAR(100), NOT NULL
- age: INT, NOT NULL, CHECK (age > 0)
- consent: BOOLEAN, NOT NULL, DEFAULT TRUE
- region: VARCHAR(100)

## Player
- player_id: SERIAL, PK
- user_id: INT, FK → User(user_id), NOT NULL
- nickname: VARCHAR(50), NOT NULL
- game_level: VARCHAR(20)

## Game
- game_id: SERIAL, PK
- map_id: INT, FK → Map(map_id), NOT NULL
- start_ts: TIMESTAMPTZ, NOT NULL
- end_ts: TIMESTAMPTZ

## GameParticipant
- player_id: INT, FK → Player(player_id), NOT NULL
- game_id: INT, FK → Game(game_id), NOT NULL
- team: VARCHAR(20)
- survived: BOOLEAN
- kills: INT, DEFAULT 0, CHECK (kills >= 0)
- assists: INT, DEFAULT 0, CHECK (assists >= 0)
- score: INT, DEFAULT 0
- PK: (player_id, game_id)

## UXResponse
- response_id: SERIAL, PK
- user_id: INT, FK → User(user_id), NULLABLE
- instrument_id: INT, FK → UXInstrument(instrument_id), NOT NULL
- game_id: INT, FK → Game(game_id), NOT NULL
- response_date: TIMESTAMPTZ, NOT NULL, DEFAULT NOW()

## UXResponseItem
- response_id: INT, FK → UXResponse(response_id), NOT NULL
- item_id: INT, FK → UXItem(item_id), NOT NULL
- value: INT, NOT NULL, CHECK (value BETWEEN 1 AND 5)
- PK: (response_id, item_id)

## TelemetryEvent
- event_id: SERIAL, PK
- game_id: INT, FK → Game(game_id), NOT NULL
- player_id: INT, FK → Player(player_id), NOT NULL
- sector_id: INT, FK → Sector(sector_id)
- tic: INT, NOT NULL, CHECK (tic >= 1)
- pos_x: FLOAT8, NOT NULL
- pos_y: FLOAT8, NOT NULL
- pos_z: FLOAT8, NOT NULL
- mom_x: FLOAT8
- mom_y: FLOAT8
- fov: FLOAT8
- vision_ang: FLOAT8
- health: INT, CHECK (health >= 0)
- armor: INT, CHECK (armor BETWEEN 0 AND 200)
- ammo: INT, CHECK (ammo >= 0)
- UNIQUE: (game_id, player_id, tic)