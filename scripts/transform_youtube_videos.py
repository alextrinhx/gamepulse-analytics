import json
from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[1]
RAW_DIR = BASE_DIR / "data" / "raw"
PROCESSED_DIR = BASE_DIR / "data" / "processed"
PROCESSED_DIR.mkdir(parents=True, exist_ok=True)


def load_json(filename: str):
    with open(RAW_DIR / filename, "r", encoding="utf-8") as file:
        return json.load(file)


def transform_video_details(data):
    rows = []

    for item in data.get("items", []):
        snippet = item.get("snippet", {})
        statistics = item.get("statistics", {})
        content_details = item.get("contentDetails", {})

        rows.append({
            "video_id": item.get("id"),
            "title": snippet.get("title"),
            "channel_id": snippet.get("channelId"),
            "channel_title": snippet.get("channelTitle"),
            "published_at": snippet.get("publishedAt"),
            "description": snippet.get("description"),
            "duration": content_details.get("duration"),
            "view_count": int(statistics.get("viewCount", 0)),
            "like_count": int(statistics.get("likeCount", 0)),
            "comment_count": int(statistics.get("commentCount", 0)),
        })

    return pd.DataFrame(rows)


if __name__ == "__main__":
    data = load_json("valorant_youtube_video_details.json")
    df = transform_video_details(data)

    output_path = PROCESSED_DIR / "valorant_youtube_videos.csv"
    df.to_csv(output_path, index=False)

    print(f"Saved transformed data to {output_path}")
    print(df.head())