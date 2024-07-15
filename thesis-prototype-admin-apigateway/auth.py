import requests
from fastapi import status
from schemas.auth import Token
from conf import settings

def decode_access_token(token: str):
    payload = Token(session_id = token)
    response = requests.get(f"{settings.USERS_SERVICE_URL}/user/",json = payload.model_dump())
    return (response.status_code == status.HTTP_200_OK)