# etl/generate_data.py

import random
import math
import csv
from datetime import datetime, timedelta

# ── Configuration ──────────────────────────────────────────
EPISODES = [
    (1, "Knee-Deep in the Dead"),
    (2, "The Shores of Hell"),
    (3, "Inferno")
]

MAPS_PER_EPISODE = [
    [(1, "Hangar", "E1M1"), (2, "Nuclear Plant", "E1M2"), (3, "Toxin Refinery", "E1M3")],
    [(1, "Deimos Anomaly", "E2M1"), (2, "Containment Area", "E2M2"), (3, "Refinery", "E2M3")],
    [(1, "Hell Keep", "E3M1"), (2, "Slough of Despair", "E3M2"), (3, "Pandemonium", "E3M3")]
]

PLAYERS = [
    (1, "DoomSlayer"),
    (2, "RipAndTear"),
    (3, "MarineOne"),
    (4, "HellWalker"),
    (5, "DemonBane"),
    (6, "IronFist"),
    (7, "ShadowBolt"),
    (8, "VoidRunner")
]

SECTORS_PER_MAP = 6
TICS_PER_GAME   = 500
GAMES_PER_MAP   = 2

# ── Helpers ─────────────────────────────────────────────────
def generate_trajectory(n_tics):
    x     = random.uniform(-2048, 2048)
    y     = random.uniform(-2048, 2048)
    angle = random.uniform(0, 2 * math.pi)
    positions = []
    for _ in range(n_tics):
        angle += random.uniform(-0.15, 0.15)
        speed  = random.uniform(0, 25)
        x     += math.cos(angle) * speed
        y     += math.sin(angle) * speed
        positions.append((round(x, 2), round(y, 2), round(angle, 4)))
    return positions

def random_stats(prev_health=100):
    health = max(1, min(200, prev_health + random.randint(-3, 2)))
    armor  = random.randint(0, 200)
    ammo   = random.randint(0, 300)
    fov    = 90.0
    return health, armor, ammo, fov

# ── Main generation ──────────────────────────────────────────
def generate(output_path="etl/sample_telemetry.tsv"):
    rows = []
    game_id = 1

    for ep_idx, (ep_num, ep_name) in enumerate(EPISODES):
        for map_num, map_name, map_code in MAPS_PER_EPISODE[ep_idx]:
            for game_num in range(GAMES_PER_MAP):

                # Select 4-8 random players for this game
                n_players   = random.randint(4, 8)
                game_players = random.sample(PLAYERS, n_players)

                for player_id, nickname in game_players:
                    positions = generate_trajectory(TICS_PER_GAME)
                    health    = 100

                    for tic_num, (px, py, angle) in enumerate(positions, start=1):
                        health, armor, ammo, fov = random_stats(health)
                        sector_id = (int(abs(px) // 250) % SECTORS_PER_MAP) + 1
                        mom_x     = round(math.cos(angle) * random.uniform(0, 25), 2)
                        mom_y     = round(math.sin(angle) * random.uniform(0, 25), 2)

                        rows.append([
                            game_id,
                            player_id,
                            sector_id,
                            tic_num,
                            px, py, 0.0,
                            mom_x, mom_y,
                            fov,
                            round(angle, 4),
                            health, armor, ammo
                        ])

                game_id += 1

    with open(output_path, "w", newline="") as f:
        writer = csv.writer(f, delimiter="\t")
        writer.writerow([
            "game_id", "player_id", "sector_id", "tic",
            "pos_x", "pos_y", "pos_z",
            "mom_x", "mom_y", "fov", "vision_ang",
            "health", "armor", "ammo"
        ])
        writer.writerows(rows)

    print(f"Generated {len(rows)} rows → {output_path}")

if __name__ == "__main__":
    generate()