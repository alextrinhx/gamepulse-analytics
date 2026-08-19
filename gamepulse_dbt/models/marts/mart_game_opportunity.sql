with game_metrics as (

    select *
    from {{ ref('mart_game_performance') }}

),

max_values as (

    select
        max(total_audience) as max_audience,
        max(avg_engagement_rate) as max_engagement
    from game_metrics

),

scored as (

    select
        gm.game_name,
        gm.content_count,
        gm.total_audience,
        gm.avg_audience,
        gm.total_interactions,
        gm.avg_engagement_rate,

        round(
            (gm.total_audience / nullif(mv.max_audience, 0)) * 100,
            2
        ) as audience_score,

        round(
            (gm.avg_engagement_rate / nullif(mv.max_engagement, 0)) * 100,
            2
        ) as engagement_score

    from game_metrics gm
    cross join max_values mv

)

select
    CASE game_name
        WHEN 'minecraft' THEN 'Minecraft'
        WHEN 'counter strike 2' THEN 'Counter Strike 2'
        WHEN 'fortnite' THEN 'Fortnite'
        WHEN 'marvel rivals' THEN 'Marvel Rivals'
        WHEN 'valorant' THEN 'Valorant'
        WHEN 'rocket league' THEN 'Rocket League'
        WHEN 'league of legends' THEN 'League of Legends'
        WHEN 'apex legends' THEN 'Apex Legends'
        ELSE INITCAP(game_name)
    END AS game_name,
    content_count,
    total_audience,
    round(avg_audience, 2) as avg_audience,
    total_interactions,
    round(avg_engagement_rate, 4) as avg_engagement_rate,
    audience_score,
    engagement_score,

    round(
        audience_score * 0.60
        + engagement_score * 0.40,
        2
    ) as gamepulse_index,

    case
        when (audience_score * 0.60 + engagement_score * 0.40) >= 70
            then 'Increase Coverage'
        when (audience_score * 0.60 + engagement_score * 0.40) >= 35
            then 'Watch Closely'
        else 'Monitor'
    end as recommendation,

    case
        when audience_score >= 90 and engagement_score >= 70
            then 'High audience reach with strong engagement'
        when audience_score >= 90
            then 'Exceptional audience reach'
        when engagement_score >= 90
            then 'Highly engaged community'
        when audience_score >= 50 and engagement_score >= 50
            then 'Balanced audience and engagement signals'
        else
            'Lower current opportunity based on available YouTube signals'
    end as reason

from scored
order by gamepulse_index desc