import json
from pathlib import Path

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[1]
RAW_CREATOR_DIR = BASE_DIR / "data" / "raw" / "youtube" / "creators"
PROCESSED_YOUTUBE_DIR = BASE_DIR / "data" / "processed" / "youtube"

PROCESSED_YOUTUBE_DIR.mkdir(parents=True, exist_ok=True)


def load_json(path: Path):
    with open(path, "r", encoding="utf-8") as file:
        return json.load(file)


def transform_file(path: Path):
    data = load_json(path)
    rows = []

    for item in data.get("items", []):
        snippet = item.get("snippet", {})
        statistics = item.get("statistics", {})

        rows.append({
            "channel_id": item.get("id"),
            "channel_title": snippet.get("title"),
            "channel_description": snippet.get("description"),
            "channel_published_at": snippet.get("publishedAt"),
            "subscriber_count": int(statistics.get("subscriberCount", 0)),
            "channel_view_count": int(statistics.get("viewCount", 0)),
            "channel_video_count": int(statistics.get("videoCount", 0)),
        })

    return rows


def main():
    all_rows = []

    for path in RAW_CREATOR_DIR.glob("youtube_creators_batch_*.json"):
        all_rows.extend(transform_file(path))

    df = pd.DataFrame(all_rows).drop_duplicates(subset=["channel_id"])

    output_path = PROCESSED_YOUTUBE_DIR / "youtube_creators.csv"
    df.to_csv(output_path, index=False)

    print(f"Saved {len(df)} creators to {output_path}")
    print(df.head())


if __name__ == "__main__":
    main()