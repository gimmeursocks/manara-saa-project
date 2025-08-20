import boto3
import os
import json
import uuid

# Get the S3 bucket name from the environment variables set in Terraform
RAW_BUCKET = os.environ["RAW_BUCKET"]
s3_client = boto3.client("s3")


def lambda_handler(event, context):
    try:
        # Get the desired filename from the request body
        body = json.loads(event["body"])
        file_name = body.get("fileName")

        # To avoid file name collisions, generate a unique key for S3
        unique_key = f"{uuid.uuid4()}-{file_name}"

        # Generate the presigned URL for PUT (upload) operation
        s3_client = boto3.client("s3", region_name="eu-central-1")
        presigned_url = s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": RAW_BUCKET,
                "Key": unique_key,
                "ContentType": body.get("fileType"),
            },
            ExpiresIn=300,
        )

        return {
            "statusCode": 200,
            "headers": {
                # Required for CORS to allow the browser to make the request
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "POST, PUT",
            },
            "body": json.dumps({"uploadURL": presigned_url, "key": unique_key}),
        }
    except Exception as e:
        print(e)
        return {"statusCode": 500, "body": json.dumps("Error generating URL.")}
