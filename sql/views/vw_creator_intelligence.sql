CREATE OR REPLACE VIEW vw_creator_intelligence AS
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
            WHEN c.subscriber_count > 0
                THEN AVG(f.audience_size) / GREATEST(c.subscriber_count, 100)
            ELSE NULL
        END AS view_efficiency
    FROM fact_content f
    JOIN dim_creator c
        ON f.creator_id = c.creator_id
    JOIN dim_platform p
        ON f.platform_id = p.platform_id
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

        ROUND(
            (cm.view_efficiency / NULLIF(mv.max_view_efficiency, 0)) * 100,
            2
        ) AS view_efficiency_score,

        ROUND(
            (cm.avg_engagement_rate / NULLIF(mv.max_engagement, 0)) * 100,
            2
        ) AS engagement_score,

        (
            0.70 * LEAST(
                1.0,
                SQRT(
                    GREATEST(cm.subscriber_count, 0)::numeric
                    / 1000.0
                )
            )
            +
            0.30 * LEAST(
                1.0,
                SQRT(
                    GREATEST(cm.content_count, 0)::numeric
                    / 10.0
                )
            )
        ) AS confidence_score

    FROM creator_metrics cm
    CROSS JOIN max_values mv
),

final_scores AS (
    SELECT
        scored.*,

        (
            view_efficiency_score * 0.70
            + engagement_score * 0.30
        ) AS raw_creator_impact_score,

        (
            view_efficiency_score * 0.70
            + engagement_score * 0.30
        ) AS adjusted_creator_impact_score

    FROM scored
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

    -- Keep these two existing columns in their original positions
    ROUND(adjusted_creator_impact_score, 2) AS creator_impact_score,

CASE
    WHEN content_count >= 3
         AND adjusted_creator_impact_score >= 65
        THEN 'Prioritize Partnership'

    WHEN content_count >= 2
         AND adjusted_creator_impact_score >= 20
        THEN 'Watch Closely'

    ELSE 'Monitor'
END AS recommendation,

    -- New columns must be added at the end
    ROUND(confidence_score, 4) AS confidence_score,
    ROUND(raw_creator_impact_score, 2) AS raw_creator_impact_score

FROM final_scores
WHERE subscriber_count > 0
ORDER BY creator_impact_score DESC NULLS LAST;