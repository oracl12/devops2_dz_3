import json
import boto3

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    if 'httpMethod' in event:
        body = {
            "message": "Hello from Lambda!",
            "event": event
        }
        sns_client.publish(
            TopicArn='TEST_SNS_ARN',
            Message='Lambda function triggered successfully!'
        )
        return {
            "statusCode": 200,
            "body": json.dumps(body)
        }
    return {
        "statusCode": 404,
        "body": "Undefined action"
    }