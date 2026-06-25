import json
import re
from pathlib import Path

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[1]
RAW_YOUTUBE_DIR = BASE_DIR / "data" / "raw" / "youtube"
PROCESSED_YOUTUBE_DIR = BASE_DIR / "data" / "processed" / "youtube"

PROCESSED_YOUTUBE_DIR.mkdir(parents=True, exist_ok=True)


def title_case_from_slug(slug: str) -> str:
    return slug.replace("_", " ").title()


def load_json(path: Path):
    with open(path, "r", encoding="utf-8") as file:
        return json.load(file)


def transform_file(path: Path):
    game_slug = re.sub(r"_youtube_video_details$", "", path.stem)
    game_name = title_case_from_slug(game_slug)

    data = load_json(path)
    rows = []

    for item in data.get("items", []):
        snippet = item.get("snippet", {})
        statistics = item.get("statistics", {})
        content_details = item.get("contentDetails", {})

        rows.append({
            "game": game_name,
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

    return rows


def main():
    all_rows = []

    for path in RAW_YOUTUBE_DIR.glob("*_youtube_video_details.json"):
        all_rows.extend(transform_file(path))

    df = pd.DataFrame(all_rows)

    output_path = PROCESSED_YOUTUBE_DIR / "youtube_videos.csv"
    df.to_csv(output_path, index=False)

    print(f"Saved {len(df)} rows to {output_path}")
    print(df.head())


if __name__ == "__main__":
    main()