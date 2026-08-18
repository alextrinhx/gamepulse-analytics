import json
from pathlib import Path

from api.youtube.client import get_youtube_client
from cloud.s3 import upload_file_to_s3

BASE_DIR = Path(__file__).resolve().parents[2]
RAW_VIDEO_DIR = BASE_DIR / "data" / "raw" / "youtube" / "videos"
RAW_CREATOR_DIR = BASE_DIR / "data" / "raw" / "youtube" / "creators"

RAW_CREATOR_DIR.mkdir(parents=True, exist_ok=True)


def load_json(path: Path):
    with open(path, "r", encoding="utf-8") as file:
        return json.load(file)


def get_unique_channel_ids():
    channel_ids = set()

    for path in RAW_VIDEO_DIR.glob("*_youtube_video_details.json"):
        data = load_json(path)

        for item in data.get("items", []):
            snippet = item.get("snippet", {})
            channel_id = snippet.get("channelId")

            if channel_id:
                channel_ids.add(channel_id)
    
    return sorted(channel_ids)


def chunk_list(items: list[str], chunk_size: int = 50):
    for i in range(0, len(items), chunk_size):
        yield items[i:i + chunk_size]


def get_channel_details(channel_ids: list[str]):
    youtube = get_youtube_client()

    request = youtube.channels().list(
        part="snippet,statistics",
        id=",".join(channel_ids)
    )

    return request.execute()


def save_json(data, filename: str):
    output_path = RAW_CREATOR_DIR / filename

    with open(output_path, "w", encoding="utf-8") as file:
        json.dump(data, file, indent=4)

    print(f"Saved data to {output_path}")

    s3_key = f"youtube/creators/{filename}"
    upload_file_to_s3(str(output_path), s3_key)


def main():
    channel_ids = get_unique_channel_ids()

    print(f"Found {len(channel_ids)} unique YouTube creators.")

    for index, chunk in enumerate(chunk_list(channel_ids), start=1):
        response = get_channel_details(chunk)
        save_json(response, f"youtube_creators_batch_{index}.json")


if __name__ == "__main__":
    main()