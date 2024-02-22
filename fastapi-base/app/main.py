import logging
from typing import Union 
from fastapi import FastAPI

from .routers import environmental_data_router, item_router


app = FastAPI()


app.include_router(environmental_data_router.router)
app.include_router(item_router.router)
