DROP VIEW IF EXISTS vw_platform_summary;

CREATE VIEW vw_platform_summary AS
SELECT
    p.platform_name,
    COUNT(f.content_id) AS content_count,
    SUM(f.audience_size) AS total_audience,
    ROUND(AVG(f.audience_size), 2) AS avg_audience,
    SUM(f.interaction_count) AS total_interactions,
    ROUND(AVG(f.engagement_rate), 4) AS avg_engagement_rate
FROM fact_content f
JOIN dim_platform p ON f.platform_id = p.platform_id
GROUP BY p.platform_name
ORDER BY total_audience DESC;