import json
import os
import boto3

stream = os.environ.get('stream', 'ap-southeast-1')
region = os.environ.get('region', 'ppshein-test')
kinesis = boto3.client('kinesis', region_name=region)


def lambda_handler(event, context):
    for record in event['Records']:
        payload = (record["body"])
        payload = json.loads(payload)

        print("forward to CW")
        print(payload)

        result = kinesis.put_record(
            StreamName=stream,
            Data=json.dumps(payload),
            PartitionKey="mykey")

    return {
        "statusCode": 200,
        "body": result,
    }
