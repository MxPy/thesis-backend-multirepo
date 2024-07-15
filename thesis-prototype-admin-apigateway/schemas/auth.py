from pydantic import BaseModel

class Token(BaseModel):
    session_id: str