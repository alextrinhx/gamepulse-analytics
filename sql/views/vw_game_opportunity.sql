DROP VIEW IF EXISTS vw_game_opportunity;

CREATE VIEW vw_game_opportunity AS
WITH game_metrics AS (
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
),
max_values AS (
    SELECT
        MAX(total_audience) AS max_audience,
        MAX(avg_engagement_rate) AS max_engagement
    FROM game_metrics
),
scored AS (
    SELECT
        gm.game_name,
        gm.content_count,
        gm.total_audience,
        gm.avg_audience,
        gm.total_interactions,
        gm.avg_engagement_rate,

        ROUND((gm.total_audience / NULLIF(mv.max_audience, 0)) * 100, 2) AS audience_score,
        ROUND((gm.avg_engagement_rate / NULLIF(mv.max_engagement, 0)) * 100, 2) AS engagement_score
    FROM game_metrics gm
    CROSS JOIN max_values mv
)
SELECT
    game_name,
    content_count,
    total_audience,
    ROUND(avg_audience, 2) AS avg_audience,
    total_interactions,
    ROUND(avg_engagement_rate, 4) AS avg_engagement_rate,
    audience_score,
    engagement_score,

    ROUND(
        audience_score * 0.60
        + engagement_score * 0.40,
        2
    ) AS gamepulse_index,

    CASE
        WHEN (audience_score * 0.60 + engagement_score * 0.40) >= 75 THEN 'Increase coverage'
        WHEN (audience_score * 0.60 + engagement_score * 0.40) >= 50 THEN 'Maintain coverage'
        ELSE 'Monitor'
    END AS recommendation,

    CASE
        WHEN audience_score >= 90 AND engagement_score >= 70 THEN
            'High audience reach with strong engagement'
        WHEN audience_score >= 90 THEN
            'Exceptional audience reach'
        WHEN engagement_score >= 90 THEN
            'Highly engaged community'
        WHEN audience_score >= 50 AND engagement_score >= 50 THEN
            'Balanced audience and engagement signals'
        ELSE
            'Lower current opportunity based on available YouTube signals'
    END AS reason
FROM scored
ORDER BY gamepulse_index DESC;