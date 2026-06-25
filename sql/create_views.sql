DROP VIEW IF EXISTS vw_game_summary;
DROP VIEW IF EXISTS vw_creator_summary;
DROP VIEW IF EXISTS vw_platform_summary;

CREATE VIEW vw_game_summary AS
SELECT
    g.game_name,
    COUNT(f.content_id) AS content_count,
    SUM(f.audience_size) AS total_audience,
    AVG(f.audience_size) AS avg_audience,
    SUM(f.interaction_count) AS total_interactions,
    AVG(f.engagement_rate) AS avg_engagement_rate
FROM fact_content f
JOIN dim_game g ON f.game_id = g.game_id
GROUP BY g.game_name
ORDER BY total_audience DESC;

CREATE VIEW vw_creator_summary AS
SELECT
    c.creator_name,
    p.platform_name,
    COUNT(f.content_id) AS content_count,
    SUM(f.audience_size) AS total_audience,
    AVG(f.audience_size) AS avg_audience,
    SUM(f.interaction_count) AS total_interactions,
    AVG(f.engagement_rate) AS avg_engagement_rate
FROM fact_content f
JOIN dim_creator c ON f.creator_id = c.creator_id
JOIN dim_platform p ON c.platform_id = p.platform_id
GROUP BY c.creator_name, p.platform_name
ORDER BY total_audience DESC;

CREATE VIEW vw_platform_summary AS
SELECT
    p.platform_name,
    COUNT(f.content_id) AS content_count,
    SUM(f.audience_size) AS total_audience,
    AVG(f.audience_size) AS avg_audience,
    SUM(f.interaction_count) AS total_interactions,
    AVG(f.engagement_rate) AS avg_engagement_rate
FROM fact_content f
JOIN dim_platform p ON f.platform_id = p.platform_id
GROUP BY p.platform_name
ORDER BY total_audience DESC;