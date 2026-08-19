{{ config(materialized='table') }}

select
    'YouTube' as platform_name,
    count(*) as content_count,
    sum(view_count) as total_audience,
    round(avg(view_count), 2) as avg_audience,
    sum(
        coalesce(like_count, 0) +
        coalesce(comment_count, 0)
    ) as total_interactions,
    round(
        avg(
            case
                when view_count >= 100 then
                    (
                        coalesce(like_count, 0) +
                        coalesce(comment_count, 0)
                    ) / nullif(view_count, 0)::float
            end
        ),
        4
    ) as avg_engagement_rate

from {{ ref('stg_youtube_videos') }}