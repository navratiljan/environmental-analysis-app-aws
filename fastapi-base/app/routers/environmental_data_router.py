from fastapi import APIRouter
from typing import Union 
import logging


from app.schemas import Item
from app.services.environmental_data_service import * 

router = APIRouter()


@router.get("/environmental-data/load")
async def load_environmental_data():
    logging.info(f"test: test")
    load_global_land_temperatures()
    load_country_land_temperatures()
    
    return "Terting"
