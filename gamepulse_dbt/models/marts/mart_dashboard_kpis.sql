{{ config(materialized='table') }}

select
    (
        select count(distinct game_name)
        from {{ ref('stg_video_game_map') }}
    ) as games_tracked,

    (
        select count(*)
        from {{ ref('stg_youtube_creators') }}
    ) as creators_tracked,

    (
        select count(*)
        from {{ ref('stg_youtube_videos') }}
    ) as content_items_analyzed,

    (
        select sum(view_count)
        from {{ ref('stg_youtube_videos') }}
    ) as total_audience,

    (
        select sum(
            coalesce(like_count, 0) + coalesce(comment_count, 0)
        )
        from {{ ref('stg_youtube_videos') }}
    ) as total_interactions,

    (
        select round(avg(
            (
                coalesce(like_count, 0) +
                coalesce(comment_count, 0)
            ) / nullif(view_count, 0)::float
        ), 4)
        from {{ ref('stg_youtube_videos') }}
    ) as avg_engagement_rate,

    (
        select game_name
        from {{ ref('mart_game_opportunity') }}
        order by gamepulse_index desc
        limit 1
    ) as top_game_opportunity,

    (
        select creator_name
        from {{ ref('mart_creator_intelligence') }}
        order by creator_impact_score desc nulls last
        limit 1
    ) as top_creator_opportunity