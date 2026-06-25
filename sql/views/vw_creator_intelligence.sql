DROP VIEW IF EXISTS vw_creator_intelligence;

CREATE VIEW vw_creator_intelligence AS
WITH creator_metrics AS (
    SELECT
        c.creator_name,
        c.external_creator_id,
        c.subscriber_count,
        c.channel_view_count,
        c.channel_video_count,
        p.platform_name,
        COUNT(f.content_id) AS content_count,
        SUM(f.audience_size) AS total_audience,
        AVG(f.audience_size) AS avg_audience,
        SUM(f.interaction_count) AS total_interactions,
        AVG(f.engagement_rate) AS avg_engagement_rate,
        CASE
            WHEN c.subscriber_count > 0 THEN AVG(f.audience_size) / c.subscriber_count
            ELSE NULL
        END AS view_efficiency
    FROM fact_content f
    JOIN dim_creator c ON f.creator_id = c.creator_id
    JOIN dim_platform p ON f.platform_id = p.platform_id
    GROUP BY
        c.creator_name,
        c.external_creator_id,
        c.subscriber_count,
        c.channel_view_count,
        c.channel_video_count,
        p.platform_name
),
max_values AS (
    SELECT
        MAX(view_efficiency) AS max_view_efficiency,
        MAX(avg_engagement_rate) AS max_engagement
    FROM creator_metrics
),
scored AS (
    SELECT
        cm.*,
        ROUND((cm.view_efficiency / NULLIF(mv.max_view_efficiency, 0)) * 100, 2) AS view_efficiency_score,
        ROUND((cm.avg_engagement_rate / NULLIF(mv.max_engagement, 0)) * 100, 2) AS engagement_score
    FROM creator_metrics cm
    CROSS JOIN max_values mv
)
SELECT
    creator_name,
    platform_name,
    subscriber_count,
    channel_view_count,
    channel_video_count,
    content_count,
    total_audience,
    ROUND(avg_audience, 2) AS avg_audience,
    ROUND(avg_engagement_rate, 4) AS avg_engagement_rate,
    ROUND(view_efficiency, 4) AS view_efficiency,
    view_efficiency_score,
    engagement_score,
    ROUND(
        view_efficiency_score * 0.70
        + engagement_score * 0.30,
        2
    ) AS creator_impact_score,
    CASE
        WHEN (view_efficiency_score * 0.70 + engagement_score * 0.30) >= 85 THEN 'Rising creator'
        WHEN (view_efficiency_score * 0.70 + engagement_score * 0.30) >= 65 THEN 'Watch closely'
        ELSE 'Monitor'
    END AS recommendation
FROM scored
WHERE subscriber_count IS NOT NULL
ORDER BY creator_impact_score DESC;