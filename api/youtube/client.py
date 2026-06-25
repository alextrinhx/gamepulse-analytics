from googleapiclient.discovery import build
from api.youtube.config import YOUTUBE_API_KEY

def get_youtube_client():
    return build("youtube", "v3", developerKey=YOUTUBE_API_KEY)