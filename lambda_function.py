import json
import boto3

sns_client = boto3.client('sns')

def lambda_handler(event, context):
    if 'httpMethod' in event:
        body = {
            "message": "Hello from Lambda!",
            "event": event
        }
        return {
            "statusCode": 200,
            "body": json.dumps(body)
        }
    elif 'Records' in event:
        for record in event['Records']:
            print(record)
    sns_client.publish(
        TopicArn='TEST_SNS_ARN',
        Message='Lambda function triggered successfully!'
    )
    return {
        "statusCode": 200,
        "body": "Lambda function executed successfully!"
    }