import os

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    #TODO: move to env
    #change users to localhost for nondocker run
    USERS_SERVICE_URL: str = "http://users:8000"
    GATEWAY_TIMEOUT: int = 59


settings = Settings()