with videos as (

    select *
    from {{ ref('stg_youtube_videos') }}

),

video_games as (

    select *
    from {{ ref('stg_video_game_map') }}

),

game_content as (

    select
        vg.game_name,
        v.video_id,
        v.channel_id,
        v.view_count as audience_size,

        coalesce(v.like_count, 0)
        + coalesce(v.comment_count, 0) as interaction_count,

    case
        when v.view_count >= 100 then
            (
                coalesce(v.like_count, 0)
                + coalesce(v.comment_count, 0)
            ) / v.view_count::float
        else null
    end as engagement_rate

    from videos v
    inner join video_games vg
        on v.video_id = vg.video_id

),

game_performance as (

    select
        game_name,

        count(video_id) as content_count,

        sum(audience_size) as total_audience,

        round(
            avg(audience_size),
            2
        ) as avg_audience,

        sum(interaction_count) as total_interactions,

        round(
            avg(engagement_rate),
            4
        ) as avg_engagement_rate

    from game_content

    group by game_name

)

select *
from game_performance
order by total_audience desc