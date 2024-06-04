import json
import boto3
from botocore.exceptions import ClientError
import time

# Create QuickSight and STS clients
quicksightClient = boto3.client("quicksight", region_name="us-west-2")
sts = boto3.client("sts")


# Function to generate embedded URL for anonymous user
# accountId: YOUR AWS ACCOUNT ID
# quicksightNamespace: VALID NAMESPACE WHERE YOU WANT TO DO NOAUTH EMBEDDING
# authorizedResourceArns: DASHBOARD ARN LIST TO EMBED
# allowedDomains: RUNTIME ALLOWED DOMAINS FOR EMBEDDING
# dashboardId: DASHBOARD ID TO WHICH THE CONSTRUCTED URL POINTS
# sessionTags: SESSION TAGS USED FOR ROW-LEVEL SECURITY
def generateEmbedUrlForAnonymousUser(
    accountId,
    quicksightNamespace,
    authorizedResourceArns,
    allowedDomains,
    dashboardId,
    sessionTags,
):
    try:
        response = quicksightClient.generate_embed_url_for_anonymous_user(
            AwsAccountId=accountId,
            Namespace=quicksightNamespace,
            AuthorizedResourceArns=authorizedResourceArns,
            AllowedDomains=allowedDomains,
            ExperienceConfiguration={"Dashboard": {"InitialDashboardId": dashboardId}},
            SessionTags=sessionTags,
            SessionLifetimeInMinutes=600,
        )

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
            },
            "body": json.dumps(response),
            "isBase64Encoded": bool("false"),
        }
    except ClientError as e:
        print(e)
        return "Error generating embeddedURL: " + str(e)


generateEmbedUrlForAnonymousUser(
    accountId=""
)