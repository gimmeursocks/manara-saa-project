import boto3
import os
from PIL import Image  # Python Imaging Library
import io  # Used to treat bytes as a file

# Get environment variables from Terraform
PROCESSED_BUCKET = os.environ["PROCESSED_BUCKET"]
DYNAMODB_TABLE = os.environ["DYNAMODB_TABLE"]

s3_client = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(DYNAMODB_TABLE)


def lambda_handler(event, context):
    # Get the bucket and key (filename) from the S3 trigger event
    record = event["Records"][0]
    source_bucket = record["s3"]["bucket"]["name"]
    source_key = record["s3"]["object"]["key"]

    try:
        # 1. Download the raw image from the source S3 bucket
        response = s3_client.get_object(Bucket=source_bucket, Key=source_key)
        image_data = response["Body"].read()

        # 2. Process the image (e.g., resize to 800px width)
        image = Image.open(io.BytesIO(image_data))
        # Simple resize example
        image.thumbnail((800, 800))

        # Save the processed image to a buffer
        buffer = io.BytesIO()
        image.save(buffer, format="JPEG", quality=85)
        buffer.seek(0)  # Rewind the buffer to the beginning

        # 3. Upload the processed image to the destination S3 bucket
        s3_client.put_object(
            Bucket=PROCESSED_BUCKET,
            Key=source_key,  # Use the same key for simplicity
            Body=buffer,
            ContentType="image/jpeg",
        )

        # 4. Save metadata to DynamoDB
        table.put_item(
            Item={
                "image_id": source_key,
                "bucket": PROCESSED_BUCKET,
                "upload_time": record["eventTime"],
            }
        )

        print(f"Successfully processed {source_key}")
        return {"statusCode": 200}

    except Exception as e:
        print(f"Error processing {source_key}: {e}")
        raise e
