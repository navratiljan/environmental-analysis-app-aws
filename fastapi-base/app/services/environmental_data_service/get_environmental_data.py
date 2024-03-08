import json
import os
from typing import Optional

from app.utils.base_helpers import convert_decimals, convert_dynamo_obj_to_python_obj
import boto3
from boto3 import dynamodb
from app.logger import logger

session = boto3.Session(profile_name="DT_AIDA_001", region_name="eu-central-1")
dynamodb_table = os.environ["DYNAMODB_TABLE"]

# TODO restructure DynamoDB so it loads countries/country and adjust queries so its possible to query all coutries
# TODO sort this by date

dynamo_db = session.resource('dynamodb', region_name='eu-central-1')
dynamo_table = dynamo_db.Table(dynamodb_table)
def filter_environmental_data_date(dynamodb_response: dict, date: Optional[str] | None = None):
    if date:
        try:
            temparature_value_for_month_parsed = dynamodb_response[date]
        except KeyError:
            raise Exception("The date provided is not in the dataset")
        parsed_response_item_dict = convert_decimals(temparature_value_for_month_parsed)
        logger.debug(msg={f"Date filter found, returning filtered DynamoDB Item: {parsed_response_item_dict}"})
        return parsed_response_item_dict
    else:
        parsed_response_item_dict = convert_decimals(dynamodb_response)
        logger.debug(msg={f"No date filter found, returning full DynamoDB Item: {parsed_response_item_dict}"})
        return parsed_response_item_dict

def get_environmental_data_for_country(country: str, date: Optional[str] | None = None):
    response = dynamo_table.get_item(
        Key={
            'pk': country
        }
    )
    country_temperature_values = response['Item'][country]
    environmental_data_res = filter_environmental_data_date(country_temperature_values, date)
    return environmental_data_res

def get_environmental_data_global(date: Optional[str] | None = None):
    response = dynamo_table.get_item(
        Key={
            'pk': 'Global'
        }
    )
    global_temperature_values = response['Item']['Global']
    environmental_data_res = filter_environmental_data_date(global_temperature_values, date)
    return global_temperature_values


def get_environmental_data_all_countries(date: Optional[str] | None = None):
    # Perform the scan operation
    dynamodb_client = session.client("dynamodb")
    logger.debug('Start SCAN of DynamoDB table to get all keys except Global')
    response = dynamodb_client.scan(TableName=os.environ["DYNAMODB_TABLE"], Limit=10000)
    logger.debug('Finished SCAN of DynamoDB table to get all keys except Global')
    countries_temperature_values = response['Items'][0]
    environmental_data_res = convert_dynamo_obj_to_python_obj(
        countries_temperature_values
    )
    return environmental_data_res
