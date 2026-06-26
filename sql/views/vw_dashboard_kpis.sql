DROP VIEW IF EXISTS vw_dashboard_kpis;

CREATE VIEW vw_dashboard_kpis AS
SELECT
    (SELECT COUNT(*) FROM dim_game) AS games_tracked,
    (SELECT COUNT(*) FROM dim_creator) AS creators_tracked,
    (SELECT COUNT(*) FROM fact_content) AS content_items_analyzed,
    (SELECT SUM(audience_size) FROM fact_content) AS total_audience,
    (SELECT SUM(interaction_count) FROM fact_content) AS total_interactions,
    (SELECT ROUND(AVG(engagement_rate), 4) FROM fact_content) AS avg_engagement_rate,
    (
        SELECT game_name
        FROM vw_game_opportunity
        ORDER BY gamepulse_index DESC
        LIMIT 1
    ) AS top_game_opportunity,
    (
        SELECT creator_name
        FROM vw_creator_intelligence
        ORDER BY creator_impact_score DESC
        LIMIT 1
    ) AS top_creator_opportunity;