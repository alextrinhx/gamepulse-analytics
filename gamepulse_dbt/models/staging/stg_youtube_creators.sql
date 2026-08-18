with raw_creator_files as (

    select
        source_file,
        raw_data
    from {{ source('gamepulse_raw', 'youtube_creators_raw') }}

),

flattened as (

    select
        source_file,
        item.value as creator_json
    from raw_creator_files,
    lateral flatten(input => raw_data:items) item

)

select
    creator_json:id::string as channel_id,
    creator_json:snippet:title::string as creator_name,

    try_to_number(
        creator_json:statistics:subscriberCount::string
    ) as subscriber_count,

    try_to_number(
        creator_json:statistics:viewCount::string
    ) as channel_view_count,

    try_to_number(
        creator_json:statistics:videoCount::string
    ) as channel_video_count,

    source_file

from flattened