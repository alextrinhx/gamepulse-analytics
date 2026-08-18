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
        item.value:id::string as video_id
    from raw_video_files,
    lateral flatten(input => raw_data:items) item

),

mapped as (

    select distinct
        video_id,

        replace(
            replace(
                split_part(source_file, '/', -1),
                '_youtube_video_details.json',
                ''
            ),
            '_',
            ' '
        ) as game_name

    from flattened
    where video_id is not null

)

select *
from mapped