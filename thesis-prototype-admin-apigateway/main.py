from fastapi import FastAPI, status, Request, Response, Header , Depends
from conf import settings
from typing import Annotated
from core import route
import uvicorn
from fastapi.security import HTTPBearer
from schemas.users import *

app = FastAPI()
security = HTTPBearer()

@app.get("/test")
async def read_root():
	return {"Hello":"World"}

#TODO: Move to routers
@route(
    request_method=app.post,
    path='/user/register',
    status_code=status.HTTP_201_CREATED,
    payload_key='username_password',
    service_url=settings.USERS_SERVICE_URL,
    authentication_required=False
)
async def register(username_password: User,
                request: Request, response: Response):
    pass

@route(
    request_method=app.post,
    path='/user/login',
    status_code=status.HTTP_200_OK,
    payload_key='username_password',
    service_url=settings.USERS_SERVICE_URL,
    authentication_required=False
)
async def register(username_password: UserLogin,
                request: Request, response: Response):
    pass

@route(
    request_method=app.get,
    path='/dev/user/get/all',
    status_code=status.HTTP_200_OK,
    payload_key='',
    service_url=settings.USERS_SERVICE_URL,
    authentication_required=True
)#move ssid to header
async def get_all(request: Request, response: Response, session_id: str = None):
    pass

if __name__ == '__main__':
    #change port to nondocker run
    uvicorn.run("main:app", host="0.0.0.0", port=8000, log_level="info")