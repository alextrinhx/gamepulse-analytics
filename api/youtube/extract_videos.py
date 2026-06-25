import json
from pathlib import Path
from api.youtube.client import get_youtube_client

BASE_DIR = Path(__file__).resolve().parents[2]
RAW_DIR = BASE_DIR / "data" / "raw"
RAW_DIR.mkdir(parents=True, exist_ok=True)


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


if __name__ == "__main__":
    search_response = search_videos("Valorant", max_results=10)

    video_ids = [
        item["id"]["videoId"]
        for item in search_response.get("items", [])
    ]

    details_response = get_video_details(video_ids)

    save_json(search_response, "valorant_youtube_search.json")
    save_json(details_response, "valorant_youtube_video_details.json")