import boto3

client = boto3.client('quicksight')


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
