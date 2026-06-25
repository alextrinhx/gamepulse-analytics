from pathlib import Path
import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[1]
YOUTUBE_PROCESSED_DIR = BASE_DIR / "data" / "processed" / "youtube"
ANALYTICS_DIR = BASE_DIR / "data" / "processed" / "analytics"

ANALYTICS_DIR.mkdir(parents=True, exist_ok=True)


def main():
    input_path = YOUTUBE_PROCESSED_DIR / "youtube_videos.csv"
    output_path = ANALYTICS_DIR / "youtube_game_summary.csv"

    df = pd.read_csv(input_path)

    summary = (
        df.groupby("game")
        .agg(
            video_count=("video_id", "count"),
            total_views=("view_count", "sum"),
            avg_views=("view_count", "mean"),
            total_likes=("like_count", "sum"),
            avg_likes=("like_count", "mean"),
            total_comments=("comment_count", "sum"),
            avg_comments=("comment_count", "mean"),
        )
        .reset_index()
    )

    summary["engagement_rate"] = (
        (summary["total_likes"] + summary["total_comments"])
        / summary["total_views"]
    )

    summary = summary.sort_values("total_views", ascending=False)

    summary.to_csv(output_path, index=False)

    print(f"Saved game summary to {output_path}")
    print(summary.head(10))


if __name__ == "__main__":
    main()