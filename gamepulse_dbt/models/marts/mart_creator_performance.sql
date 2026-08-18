with videos as (

    select *
    from {{ ref('stg_youtube_videos') }}

),

creators as (

    select *
    from {{ ref('stg_youtube_creators') }}

),

creator_content as (

    select
        c.channel_id,
        c.creator_name,
        c.subscriber_count,
        c.channel_view_count,
        c.channel_video_count,

        'YouTube' as platform_name,

        v.video_id,
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

    inner join creators c
        on v.channel_id = c.channel_id

),

creator_performance as (

    select
        channel_id,
        creator_name,
        platform_name,

        subscriber_count,
        channel_view_count,
        channel_video_count,

        count(video_id) as content_count,
        sum(audience_size) as total_audience,
        round(avg(audience_size), 2) as avg_audience,
        sum(interaction_count) as total_interactions,
        round(avg(engagement_rate), 4) as avg_engagement_rate

    from creator_content

    group by
        channel_id,
        creator_name,
        platform_name,
        subscriber_count,
        channel_view_count,
        channel_video_count

)

select *
from creator_performance
order by total_audience desc