# Chocolate-Doom Telemetry & UX Database

A relational database system designed to store, manage, and analyze gameplay telemetry from a modified version of [Chocolate-Doom](https://github.com/aocalderon/trajectory_doom). Built with PostgreSQL and Python as part of the Database Systems course at Pontificia Universidad Javeriana (Period 2610).

---

## Overview

A research group collects per-tic gameplay data from a hacked Chocolate-Doom build that emits player position (x, y, z), facing angle, momentum vector, FOV, and combat stats (health, armor, ammo) at 35 tics per second. This project designs and prototypes a relational database that:

- Ingests raw TSV telemetry logs through a validated ETL pipeline
- Supports analytical queries for trajectory, proximity, and cooperation analysis
- Integrates UX survey data (BANGS scale) with telemetry for cross-domain analysis
- Enforces data quality, referential integrity, and research ethics (Colombian Law 1581/2012)

---

## Tech Stack

- **PostgreSQL 18** — primary DBMS
- **Python 3** — synthetic data generation
- **SQL** — DDL, ETL, analytical queries, indexes, views

---

## Repository Structure

```
doom_db/
├── sql/
│   ├── 01_schema.sql        # Complete DDL — all CREATE TABLE statements
│   ├── 02_indexes.sql       # Index definitions and evaluation
│   ├── 03_views.sql         # Regular and materialized views
│   ├── 04_queries.sql       # Six analytical queries
│   └── 05_etl.sql           # ETL pipeline — staging to core tables
├── etl/
│   └── generate_data.py     # Synthetic data generator (51,000+ rows)
├── docs/
│   ├── er_diagram.png       # Entity-Relationship diagram
│   ├── schema.md            # Relational schema documentation
│   ├── Data_dictionary.pdf  # Complete data dictionary
│   └── requirements.md      # Domain assumptions, requirements, and ethics
├── report/
│   └── doom_db_report.docx  # Full academic report
├── setup.sh                 # Single-script database recreation
└── README.md
```

---

## Setup & Reproduction

### Prerequisites

- PostgreSQL 18+
- Python 3.8+

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/samuguerraa/doom.git
cd doom
```

**2. Create the database**
```bash
psql -U postgres -c "CREATE DATABASE doom_db;"
```

**3. Run setup script**
```bash
bash setup.sh
```

This will:
- Create all tables with constraints
- Generate synthetic telemetry data
- Load data through the ETL pipeline
- Create indexes and views

---

## Database Schema

The schema consists of 12 normalized tables (3NF) organized in two branches:

**Telemetry branch:** `Episode → Map → Sector → TelemetryEvent ← Game ← GameParticipant ← Player ← User`

**UX branch:** `User → UXResponse → UXResponseItem ← UXItem ← UXInstrument`

![ER Diagram](docs/er_diagram.png)

---

## Analytical Queries

| # | Query | Technique |
|---|-------|-----------|
| Q1 | Average session duration per map | AVG + GROUP BY |
| Q3 | Shortest and longest trajectory per player | Window functions (LAG) |
| Q4 | UX responses for above-average trajectory players | Subquery + JOIN |
| Q5 | Most visited sector per episode and map | COUNT + ORDER BY |
| Q6 | Tics where players were together in a sector | Self-join |
| Q8 | Total distance and average speed per player | Window functions + aggregation |

---

## Index Evaluation

| Index | Speedup |
|-------|---------|
| `idx_tel_game_player_tic` | ~309x (50.6ms → 0.16ms) |
| `idx_tel_sector` | ~70x (17.4ms → 0.25ms) |
| `idx_gp_player_game` | Minimal (small table) |

---

## Author

**Samuel Guerra Sánchez**  
samuel_guerra@javeriana.edu.co  
Pontificia Universidad Javeriana — Bases de Datos, Period 2610
