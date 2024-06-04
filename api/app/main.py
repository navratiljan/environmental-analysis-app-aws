import logging
from typing import Union
from fastapi import FastAPI

from app.routers import environmental_data_router, item_router


app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

origins = [
    "http://127.0.0.1:5500/",
    "http://localhost:5500/"
]

app.add_middleware(
    CORSMiddleware,
    #allow_origins=origins,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(environmental_data_router.router)
app.include_router(item_router.router)
