-- sql/04_queries.sql

-- ── Query 1: Average duration of game sessions per map ──────
SELECT
    m.map_code,
    m.map_name,
    AVG(EXTRACT(EPOCH FROM (g.end_ts - g.start_ts))) AS avg_duration_sec
FROM Game g
JOIN Map m ON g.map_id = m.map_id
GROUP BY m.map_code, m.map_name
ORDER BY avg_duration_sec DESC;


-- ── Query 3: Shortest and longest trajectory per player ─────
WITH steps AS (
    SELECT
        player_id,
        game_id,
        SQRT(
            POWER(pos_x - LAG(pos_x) OVER w, 2) +
            POWER(pos_y - LAG(pos_y) OVER w, 2)
        ) AS step_dist
    FROM TelemetryEvent
    WINDOW w AS (PARTITION BY game_id, player_id ORDER BY tic)
),
totals AS (
    SELECT player_id, game_id, SUM(step_dist) AS total_dist
    FROM steps
    WHERE step_dist IS NOT NULL
    GROUP BY player_id, game_id
)
SELECT
    p.nickname,
    MIN(total_dist) AS shortest_trajectory,
    MAX(total_dist) AS longest_trajectory
FROM totals t
JOIN Player p ON t.player_id = p.player_id
GROUP BY p.nickname
ORDER BY longest_trajectory DESC;


-- ── Query 4: UX responses for players with above-average trajectory duration ──
WITH durations AS (
    SELECT
        gp.player_id,
        AVG(EXTRACT(EPOCH FROM (g.end_ts - g.start_ts))) AS avg_duration
    FROM GameParticipant gp
    JOIN Game g ON gp.game_id = g.game_id
    GROUP BY gp.player_id
),
global_avg AS (
    SELECT AVG(avg_duration) AS global_avg_duration FROM durations
),
above_avg_players AS (
    SELECT d.player_id
    FROM durations d, global_avg
    WHERE d.avg_duration > global_avg.global_avg_duration
)
SELECT
    pl.nickname,
    ui.item_text,
    uri.value
FROM above_avg_players aap
JOIN Player pl ON aap.player_id = pl.player_id
JOIN "User" u ON pl.user_id = u.user_id
JOIN UXResponse ur ON u.user_id = ur.user_id
JOIN UXResponseItem uri ON ur.response_id = uri.response_id
JOIN UXItem ui ON uri.item_id = ui.item_id
ORDER BY pl.nickname, ui.item_number;


-- ── Query 5: Most visited sector (hotspot) per episode and map ──
SELECT
    e.episode_name,
    m.map_code,
    t.sector_id,
    COUNT(*) AS visit_count
FROM TelemetryEvent t
JOIN Game g ON t.game_id = g.game_id
JOIN Map m ON g.map_id = m.map_id
JOIN Episode e ON m.episode_id = e.episode_id
GROUP BY e.episode_name, m.map_code, t.sector_id
ORDER BY e.episode_name, m.map_code, visit_count DESC;


-- ── Query 6: Tics where players were together in a sector ───
SELECT
    t1.game_id,
    t1.sector_id,
    COUNT(DISTINCT t1.tic) AS tics_together
FROM TelemetryEvent t1
JOIN TelemetryEvent t2
    ON  t1.game_id   = t2.game_id
    AND t1.tic       = t2.tic
    AND t1.sector_id = t2.sector_id
    AND t1.player_id <> t2.player_id
GROUP BY t1.game_id, t1.sector_id
ORDER BY tics_together DESC;


-- ── Query 8: Total distance and average speed per player ────
WITH steps AS (
    SELECT
        player_id,
        game_id,
        tic,
        SQRT(
            POWER(pos_x - LAG(pos_x) OVER w, 2) +
            POWER(pos_y - LAG(pos_y) OVER w, 2)
        ) AS step_dist
    FROM TelemetryEvent
    WINDOW w AS (PARTITION BY game_id, player_id ORDER BY tic)
),
per_game AS (
    SELECT
        player_id,
        game_id,
        SUM(step_dist)  AS total_dist,
        COUNT(tic)      AS total_tics
    FROM steps
    WHERE step_dist IS NOT NULL
    GROUP BY player_id, game_id
)
SELECT
    pl.nickname,
    SUM(pg.total_dist)                                    AS total_distance,
    SUM(pg.total_dist) / NULLIF(SUM(pg.total_tics), 0)   AS avg_speed
FROM per_game pg
JOIN Player pl ON pg.player_id = pl.player_id
GROUP BY pl.nickname
ORDER BY total_distance DESC;