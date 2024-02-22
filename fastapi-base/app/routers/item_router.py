
from fastapi import APIRouter
from typing import Union 
import logging


from app.schemas import Item

router = APIRouter()


@router.get("/")
async def read_root():
    return {"Hello": "World"}

@router.get("/items/{item_id}")
async def read_item(item_id: int, q: Union[str, None] = None):
    logging.info(f"item_id: {item_id}, q: {q}")
    return {"item_id": item_id, "q": q}


@router.put("/items/{item_id}")
async def update_item(item_id: int, item: Item):
    logging.info(f"item_id: {item_id}, item: {item}")
    return {"item_name": item.name, "item_id": item_id}

@router.post("/items/")
async def create_item(item: Item):
    logging.info(f"item: {item}")
    return item
