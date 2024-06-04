from decimal import Decimal
from boto3.dynamodb.types import TypeDeserializer, TypeSerializer


def convert_dynamo_obj_to_python_obj(dynamo_obj: dict) -> dict:
    deserializer = TypeDeserializer()
    return {k: deserializer.deserialize(v) for k, v in dynamo_obj.items()}


def convert_decimals(obj):
    if isinstance(obj, Decimal):
        return int(obj)
    elif isinstance(obj, dict):
        return {key: convert_decimals(val) for key, val in obj.items()}
    return obj
