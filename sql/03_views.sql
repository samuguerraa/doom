-- sql/03_views.sql

-- ── View 1: Full trajectory per player and game ─────────────
CREATE VIEW v_trajectories AS
SELECT
    te.game_id,
    te.player_id,
    p.nickname,
    te.tic,
    te.pos_x,
    te.pos_y,
    te.pos_z,
    te.sector_id
FROM TelemetryEvent te
JOIN Player p ON te.player_id = p.player_id
ORDER BY te.game_id, te.player_id, te.tic;


-- ── View 2: BANGS UX summary per user ───────────────────────
CREATE VIEW v_ux_summary AS
SELECT
    u.user_id,
    u.name,
    ui.subscale,
    AVG(uri.value) AS avg_score
FROM "User" u
JOIN UXResponse ur ON u.user_id = ur.user_id
JOIN UXResponseItem uri ON ur.response_id = uri.response_id
JOIN UXItem ui ON uri.item_id = ui.item_id
GROUP BY u.user_id, u.name, ui.subscale
ORDER BY u.user_id, ui.subscale;


-- ── Materialized View: Player trajectory stats ──────────────
CREATE MATERIALIZED VIEW mv_player_traj_stats AS
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
)
SELECT
    p.player_id,
    p.nickname,
    s.game_id,
    SUM(s.step_dist)   AS total_distance,
    COUNT(s.tic)       AS total_tics,
    AVG(s.step_dist)   AS avg_step_dist
FROM steps s
JOIN Player p ON s.player_id = p.player_id
WHERE s.step_dist IS NOT NULL
GROUP BY p.player_id, p.nickname, s.game_id
ORDER BY p.player_id, s.game_id;

-- To refresh when new data is loaded:
-- REFRESH MATERIALIZED VIEW mv_player_traj_stats;