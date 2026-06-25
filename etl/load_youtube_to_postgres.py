import os
from pathlib import Path
import pandas as pd
import psycopg2
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = Path(__file__).resolve().parents[1]
YOUTUBE_CSV = BASE_DIR / "data" / "processed" / "youtube" / "youtube_videos.csv"


def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
    )


def get_or_create_id(cursor, table, id_col, lookup_col, lookup_value, extra_cols=None):
    cursor.execute(
        f"SELECT {id_col} FROM {table} WHERE {lookup_col} = %s",
        (lookup_value,)
    )
    result = cursor.fetchone()

    if result:
        return result[0]

    extra_cols = extra_cols or {}
    columns = [lookup_col] + list(extra_cols.keys())
    values = [lookup_value] + list(extra_cols.values())

    placeholders = ", ".join(["%s"] * len(values))
    column_names = ", ".join(columns)

    cursor.execute(
        f"""
        INSERT INTO {table} ({column_names})
        VALUES ({placeholders})
        RETURNING {id_col}
        """,
        values
    )

    return cursor.fetchone()[0]


def load_youtube_data():
    df = pd.read_csv(YOUTUBE_CSV)
    df["published_at"] = pd.to_datetime(df["published_at"])
    df["published_date"] = df["published_at"].dt.date

    conn = get_connection()
    cursor = conn.cursor()

    platform_id = get_or_create_id(
        cursor,
        table="dim_platform",
        id_col="platform_id",
        lookup_col="platform_name",
        lookup_value="YouTube"
    )

    for _, row in df.iterrows():
        game_id = get_or_create_id(
            cursor,
            table="dim_game",
            id_col="game_id",
            lookup_col="game_name",
            lookup_value=row["game"]
        )

        cursor.execute(
            """
            SELECT creator_id
            FROM dim_creator
            WHERE platform_id = %s AND external_creator_id = %s
            """,
            (platform_id, row["channel_id"])
        )
        creator = cursor.fetchone()

        if creator:
            creator_id = creator[0]
        else:
            cursor.execute(
                """
                INSERT INTO dim_creator (
                    creator_name,
                    platform_id,
                    external_creator_id
                )
                VALUES (%s, %s, %s)
                RETURNING creator_id
                """,
                (row["channel_title"], platform_id, row["channel_id"])
            )
            creator_id = cursor.fetchone()[0]

        full_date = row["published_date"]

        cursor.execute(
            """
            SELECT date_id
            FROM dim_date
            WHERE full_date = %s
            """,
            (full_date,)
        )
        date = cursor.fetchone()

        if date:
            date_id = date[0]
        else:
            cursor.execute(
                """
                INSERT INTO dim_date (
                    full_date,
                    year,
                    month,
                    month_name,
                    day,
                    day_of_week
                )
                VALUES (%s, %s, %s, %s, %s, %s)
                RETURNING date_id
                """,
                (
                    full_date,
                    full_date.year,
                    full_date.month,
                    full_date.strftime("%B"),
                    full_date.day,
                    full_date.strftime("%A"),
                )
            )
            date_id = cursor.fetchone()[0]

        audience_size = int(row["view_count"])
        interaction_count = int(row["like_count"]) + int(row["comment_count"])
        engagement_rate = interaction_count / audience_size if audience_size > 0 else 0

        content_url = f"https://www.youtube.com/watch?v={row['video_id']}"

        cursor.execute(
            """
            INSERT INTO fact_content (
                platform_id,
                game_id,
                creator_id,
                date_id,
                external_content_id,
                content_title,
                content_url,
                audience_size,
                interaction_count,
                engagement_rate,
                published_at
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (platform_id, external_content_id) DO NOTHING
            """,
            (
                platform_id,
                game_id,
                creator_id,
                date_id,
                row["video_id"],
                row["title"],
                content_url,
                audience_size,
                interaction_count,
                engagement_rate,
                row["published_at"],
            )
        )

    conn.commit()
    cursor.close()
    conn.close()

    print(f"Loaded {len(df)} YouTube records into PostgreSQL.")


if __name__ == "__main__":
    load_youtube_data()