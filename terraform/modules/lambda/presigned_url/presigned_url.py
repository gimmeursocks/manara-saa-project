import os
import json
import boto3

s3_client = boto3.client("s3")
BUCKET = os.environ["RAW_BUCKET"]


def lambda_handler(event, context):
    try:
        # Expecting JSON with "filename"
        body = json.loads(event.get("body", "{}"))
        filename = body.get("filename")

        if not filename:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing filename"}),
            }

        # Generate presigned URL (PUT for upload)
        url = s3_client.generate_presigned_url(
            ClientMethod="put_object",
            Params={"Bucket": BUCKET, "Key": filename},
            ExpiresIn=3600,  # 1 hour
        )

        return {"statusCode": 200, "body": json.dumps({"url": url})}

    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
