from fastapi import APIRouter
from typing import Union 
import logging


from app.logger import logger
from app.schemas import Item
from app.services.environmental_data_service.load_environmental_data import * 

router = APIRouter()


@router.post("/environmental-data/load")
async def load_environmental_data():
    logger.info("Start loading global land temperatures")
    load_global_land_temperatures()
    # logger.info("Start loading country land temperatures")
    # load_country_land_temperatures()
    return "Success"
