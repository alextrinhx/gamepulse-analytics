import json
import re
from pathlib import Path
from api.youtube.client import get_youtube_client

BASE_DIR = Path(__file__).resolve().parents[2]
RAW_DIR = BASE_DIR / "data" / "raw" / "youtube"
CONFIG_DIR = BASE_DIR / "config"

RAW_DIR.mkdir(parents=True, exist_ok=True)


def slugify(text: str) -> str:
    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_")


def load_games():
    with open(CONFIG_DIR / "games.json", "r", encoding="utf-8") as file:
        return json.load(file)


def search_videos(query: str, max_results: int = 10):
    youtube = get_youtube_client()

    request = youtube.search().list(
        part="snippet",
        q=query,
        type="video",
        maxResults=max_results,
        order="date"
    )

    return request.execute()


def get_video_details(video_ids: list[str]):
    if not video_ids:
        return {"items": []}

    youtube = get_youtube_client()

    request = youtube.videos().list(
        part="snippet,statistics,contentDetails",
        id=",".join(video_ids)
    )

    return request.execute()


def save_json(data, filename: str):
    output_path = RAW_DIR / filename

    with open(output_path, "w", encoding="utf-8") as file:
        json.dump(data, file, indent=4)

    print(f"Saved data to {output_path}")


def extract_for_game(game: dict):
    game_name = game["game_name"]
    query = game["youtube_query"]
    slug = slugify(game_name)

    print(f"Extracting YouTube data for {game_name}...")

    search_response = search_videos(query, max_results=10)

    video_ids = [
        item["id"]["videoId"]
        for item in search_response.get("items", [])
        if item.get("id", {}).get("videoId")
    ]

    details_response = get_video_details(video_ids)

    save_json(search_response, f"{slug}_youtube_search.json")
    save_json(details_response, f"{slug}_youtube_video_details.json")


if __name__ == "__main__":
    games = load_games()

    for game in games:
        extract_for_game(game)