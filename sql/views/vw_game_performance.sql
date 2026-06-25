DROP VIEW IF EXISTS vw_game_performance;

CREATE VIEW vw_game_performance AS
SELECT
    g.game_name,
    COUNT(f.content_id) AS content_count,
    SUM(f.audience_size) AS total_audience,
    ROUND(AVG(f.audience_size), 2) AS avg_audience,
    SUM(f.interaction_count) AS total_interactions,
    ROUND(AVG(f.engagement_rate), 4) AS avg_engagement_rate
FROM fact_content f
JOIN dim_game g ON f.game_id = g.game_id
GROUP BY g.game_name
ORDER BY total_audience DESC;