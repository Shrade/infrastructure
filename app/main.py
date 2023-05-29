from pydantic import BaseModel
from faveds.api.fastapi import get_app
import os

app = get_app(title='Shrades API',
              description='Test',
              version='1.0',
)

class Message(BaseModel):
    message: str = 'Hello from bke.api.myfavedata.com'

@app.get('/', response_model=Message)
def root():
    return {'message': 'Hello from bke.api.myfavedata.com'}


