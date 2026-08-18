with videos as (

    select *
    from {{ ref('stg_youtube_videos') }}

),

labeled as (

    select
        video_id,
        channel_id,
        channel_title,
        title,
        published_at,
        view_count,
        like_count,
        comment_count,

        -- Derive the game from the raw source filename
        replace(
            replace(
                split_part(source_file, '/', -1),
                '_youtube_video_details.json',
                ''
            ),
            '_',
            ' '
        ) as game_name

    from videos

),

game_metrics as (

    select
        game_name,

        count(distinct video_id) as videos_analyzed,
        count(distinct channel_id) as creators_analyzed,

        sum(view_count) as total_views,
        avg(view_count) as avg_views,

        sum(like_count) as total_likes,
        sum(comment_count) as total_comments,

        avg(
            case
                when view_count > 0
                then (coalesce(like_count, 0) + coalesce(comment_count, 0))
                     / view_count::float
                else null
            end
        ) as avg_engagement_rate

    from labeled
    group by game_name

)

select *
from game_metrics