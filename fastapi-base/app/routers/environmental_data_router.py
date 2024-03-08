from fastapi import APIRouter
from typing import Union, Optional
import logging


from app.logger import logger
from app.schemas import Item
from app.services.environmental_data_service.load_environmental_data import * 
from app.services.environmental_data_service.get_environmental_data import * 

router = APIRouter()


@router.post("/environmental-data/load")
async def load_environmental_data():
    logger.info("Start loading global land temperatures")
    load_global_land_temperatures()
    logger.info("Start loading country land temperatures")
    load_country_land_temperatures()
    return "Success"

@router.get("/environmental-data/global")
async def get_environmental_data_global_specific(date_filter: Optional[str] = None):
    logger.info(f"Start getting land temperatures with date filter {date_filter}")
    res = get_environmental_data_global(date_filter)
    return res

@router.get("/environmental-data/countries/list")
async def list_all_countries_environmental_data():
    logger.info("Start getting list of countries")
    return 'x'

@router.get("/environmental-data/countries/")
async def get_all_countries_environmental_data(date_filter: Optional[str] = None):
    logger.info("Start all countries land temperatures")
    res = get_environmental_data_all_countries(date_filter)
    return res
    

@router.get("/environmental-data/countries/{country}")
async def get_environmental_data_country_specific(country: str, date_filter: Optional[str] = None):
    logger.info(f"Start getting land temperatures for {country} with date filter {date_filter}")
    res = get_environmental_data_for_country(country, date_filter)
    return res
