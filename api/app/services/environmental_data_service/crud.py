import json
import os

from decimal import Decimal

import boto3
from boto3.dynamodb.types import TypeDeserializer, TypeSerializer
from logger_functions import logger

dynamodb_table = os.environ["DYNAMODB_TABLE"]


## USE HELPERS FOR THIS
def dynamo_obj_to_python_obj(dynamo_obj: dict) -> dict:
    deserializer = TypeDeserializer()
    return {k: deserializer.deserialize(v) for k, v in dynamo_obj.items()}


def python_obj_to_dynamo_obj(python_obj: dict) -> dict:
    serializer = TypeSerializer()
    return {k: serializer.serialize(v) for k, v in python_obj.items()}


def convert_decimals(obj):
    if isinstance(obj, Decimal):
        return int(obj)
    elif isinstance(obj, dict):
        return {key: convert_decimals(val) for key, val in obj.items()}
    return obj


# convert decimals to int in the dictionary
def get_all_data_for_country(country: str):
    dynamo_db = boto3.resource("dynamodb", region_name="eu-central-1")
    dynamo_table = dynamo_db.Table(dynamodb_table)

    response = dynamo_table.get_item(Key={"pk": country})

    parsed_response_item_dict = convert_decimals(response["Item"])

    logger.info(msg={f"Returning DynamoDB Item: {response['Item']}"})

    return parsed_response_item_dict


def get_filtered_environmental_data(country: str, date: str):
    dynamo_db = boto3.resource("dynamodb", region_name="eu-central-1")
    dynamo_table = dynamo_db.Table(dynamodb_table)

    response = dynamo_table.get_item(Key={"pk": country})

    # Get only specific month
    logger.debug(msg={f"Returning DynamoDB Item: {response['Item']}"})
    try:
        temparature_value_for_month_parsed = response["Item"][country][date]
    except KeyError:
        raise Exception("The date provided is not in the dataset")

    parsed_response_item_dict = convert_decimals(temparature_value_for_month_parsed)

    return parsed_response_item_dict
