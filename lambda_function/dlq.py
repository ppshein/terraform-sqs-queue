import json


def lambda_handler(event, context):
    for record in event['Records']:
        payload = (record["body"])
        payload = json.loads(payload)
        print("DLQ saved to CW")
        print(payload)
    return {
        "statusCode": 200
    }
