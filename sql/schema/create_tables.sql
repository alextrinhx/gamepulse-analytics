DROP TABLE IF EXISTS fact_content;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_creator;
DROP TABLE IF EXISTS dim_platform;
DROP TABLE IF EXISTS dim_game;

CREATE TABLE dim_game (
    game_id SERIAL PRIMARY KEY,
    game_name TEXT UNIQUE NOT NULL
);

CREATE TABLE dim_platform (
    platform_id SERIAL PRIMARY KEY,
    platform_name TEXT UNIQUE NOT NULL
);

CREATE TABLE dim_creator (
    creator_id SERIAL PRIMARY KEY,
    creator_name TEXT NOT NULL,
    platform_id INT REFERENCES dim_platform(platform_id),
    external_creator_id TEXT,
    UNIQUE(platform_id, external_creator_id)
);

CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year INT,
    month INT,
    month_name TEXT,
    day INT,
    day_of_week TEXT
);

CREATE TABLE fact_content (
    content_id SERIAL PRIMARY KEY,
    platform_id INT REFERENCES dim_platform(platform_id),
    game_id INT REFERENCES dim_game(game_id),
    creator_id INT REFERENCES dim_creator(creator_id),
    date_id INT REFERENCES dim_date(date_id),
    external_content_id TEXT,
    content_title TEXT,
    content_url TEXT,
    audience_size BIGINT,
    interaction_count BIGINT,
    engagement_rate NUMERIC,
    published_at TIMESTAMP,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(platform_id, external_content_id)
);