with raw_video_files as (

    select
        source_file,
        raw_data
    from {{ source('gamepulse_raw', 'youtube_videos_raw') }}
    where source_file like '%_youtube_video_details.json'

),

flattened as (

    select
        source_file,
        item.value as video_json
    from raw_video_files,
    lateral flatten(input => raw_data:items) item

),

typed as (

    select
        video_json:id::string as video_id,
        video_json:snippet:channelId::string as channel_id,
        video_json:snippet:channelTitle::string as channel_title,
        video_json:snippet:title::string as title,
        video_json:snippet:publishedAt::timestamp_tz as published_at,

        try_to_number(video_json:statistics:viewCount::string) as view_count,
        try_to_number(video_json:statistics:likeCount::string) as like_count,
        try_to_number(video_json:statistics:commentCount::string) as comment_count,

        video_json:contentDetails:duration::string as duration,
        source_file

    from flattened

),

deduplicated as (

    select *
    from typed
    qualify row_number() over (
        partition by video_id
        order by view_count desc nulls last
    ) = 1

)

select *
from deduplicated