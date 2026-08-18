from pathlib import Path

import boto3


BUCKET_NAME = "gamepulse-analytics-raw"


def upload_file_to_s3(local_path: str, s3_key: str) -> None:
    local_file = Path(local_path)

    if not local_file.exists():
        raise FileNotFoundError(f"File not found: {local_file}")

    s3 = boto3.client("s3")

    s3.upload_file(
        str(local_file),
        BUCKET_NAME,
        s3_key
    )

    print(f"Uploaded {local_file} -> s3://{BUCKET_NAME}/{s3_key}")