import boto3

session = boto3.Session(region_name="eu-central-1")
client = session.client('quicksight')


def get_quicksight_dashboard_url():
    response = client.get_dashboard_embed_url(
        AwsAccountId="812222239604",
        DashboardId="70e99648-2579-4784-9f6f-d6056bdff9d8",
        IdentityType="IAM",
        Namespace="default",
        # AdditionalDashboardIds=[
        #     "string",
        # ],
    )

    return response
