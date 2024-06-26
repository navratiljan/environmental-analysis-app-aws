import os
import botocore
import boto3
from decimal import Decimal
import pandas as pd
from app.logger import logger

session = boto3.Session(region_name="eu-central-1")
s3_bucket_name = os.environ["S3_DATASETS_BUCKET_NAME"]
s3_resource = session.resource("s3")
dataset_bucket = s3_resource.Bucket(s3_bucket_name)

dynamodb_table = os.environ["DYNAMODB_TABLE"]


def load_global_land_temperatures():
    try:
        dataset_bucket.download_file(
            "datasets/GlobalTemperatures.csv", "/tmp/GlobalTemperatures.csv"
        )
    except Exception as e:
        raise Exception(f"S3 bucket download fil faied with errro {e}")

    raw_df = pd.read_csv("/tmp/GlobalTemperatures.csv").fillna(0)

    # Select the desired columns
    selected_columns = ["dt", "LandAverageTemperature"]

    # Create a new DataFrame with only the selected columns
    df = raw_df[selected_columns]

    # Convert temperature values to decimal
    df["LandAverageTemperature"] = df["LandAverageTemperature"].astype(int)

    # Set date as index and convert to dict
    global_month_dict = df.set_index("dt").to_dict()

    dynamo_db = session.resource("dynamodb", region_name="eu-central-1")
    dynamo_table = dynamo_db.Table(dynamodb_table)
    try:
        dynamo_table.put_item(
            Item={"pk": "Global", "Global": global_month_dict["LandAverageTemperature"]}
        )
        logger.info("Items uploaded to DynamoDB")
    except Exception as e:
        raise Exception(
            f"Upload of country temperature to dynamodb mapping failed with error {e}"
        )


def load_country_land_temperatures():
    try:
        dataset_bucket.download_file(
            "datasets/GlobalLandTemperaturesByCountry.csv",
            "/tmp/GlobalTemperatures.csv",
        )
    except Exception as e:
        raise Exception(
            f"S3 bucket downloadd for load land tepmperatulres faied with errror {e}"
        )

    raw_df = pd.read_csv("/tmp/GlobalTemperatures.csv").fillna(0)

    selected_columns = ["dt", "AverageTemperature", "Country"]
    df = raw_df[selected_columns]

    # Convert temperature values to decimal
    df["AverageTemperature"] = df["AverageTemperature"].astype(int)

    # Group by 'Country' and convert to a nested dictionary
    country_month_dict = (
        df.groupby("Country")
        .apply(lambda group: group.set_index("dt")[["AverageTemperature"]].to_dict())
        .to_dict()
    )

    dynamo_db = session.resource("dynamodb", region_name="eu-central-1")
    dynamo_table = dynamo_db.Table(dynamodb_table)
    list_of_countries = []
    for country in country_month_dict.keys():
        logger.info(f"Inserting records for {country} into DYnamoDB")
        list_of_countries.append(country)
        try:
            dynamo_table.put_item(
                Item={
                    "pk": f"{country}",
                    country: country_month_dict[country]["AverageTemperature"],
                }
            )
        except Exception as e:
            raise Exception(
                f"Upload of country temperature to dynamodb mapping failed with error {e}"
            )

    try:
        logger.info(f"Inserting countries list")
        dynamo_table.put_item(
            Item={"pk": "countries_list", "countries_list": list_of_countries}
        )
    except Exception as e:
        raise Exception(
            f"Upload of country temperature to dynamodb mapping failed with error {e}"
        )
