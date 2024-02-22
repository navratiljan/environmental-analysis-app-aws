import logging
from typing import Union 

from fastapi import FastAPI

from app.model import Item


app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    logging.info(f"item_id: {item_id}, q: {q}")
    return {"item_id": item_id, "q": q}


@app.put("/items/{item_id}")
def update_item(item_id: int, item: Item):
    logging.info(f"item_id: {item_id}, item: {item}")
    return {"item_name": item.name, "item_id": item_id}

@app.post("/items/")
async def create_item(item: Item):
    logging.info(f"item: {item}")
    return item
