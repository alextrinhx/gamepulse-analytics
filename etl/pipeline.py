import subprocess
import sys
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parents[1]


def run_step(step_name: str, command: list[str]):
    print(f"\n=== {step_name} ===")

    result = subprocess.run(
        command,
        cwd=BASE_DIR,
        text=True,
        capture_output=True
    )

    print(result.stdout)

    if result.returncode != 0:
        print(result.stderr)
        raise RuntimeError(f"{step_name} failed")

    print(f"{step_name} completed successfully.")


def main():
    print("\n==============================")
    print("GamePulse Analytics Pipeline")
    print("==============================")

    run_step(
        "Extract YouTube Videos",
        [sys.executable, "-m", "api.youtube.extract_videos"]
    )

    run_step(
        "Extract YouTube Creators",
        [sys.executable, "-m", "api.youtube.extract_creators"]
    )

    run_step(
        "Transform YouTube Videos",
        [sys.executable, "etl/transform_youtube.py"]
    )

    run_step(
        "Transform YouTube Creators",
        [sys.executable, "etl/transform_youtube_creators.py"]
    )

    run_step(
        "Load YouTube Data to PostgreSQL",
        [sys.executable, "etl/load_youtube_to_postgres.py"]
    )

    print("\nPipeline completed successfully.")


if __name__ == "__main__":
    main()