import os
import boto3
from PIL import Image, ImageDraw, ImageFont
import io
import uuid
import datetime

s3_client = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
PROCESSED_BUCKET = os.environ["PROCESSED_BUCKET"]
DYNAMODB_TABLE = os.environ["DYNAMODB_TABLE"]


def lambda_handler(event, context):
    try:
        for record in event["Records"]:
            # Get bucket and object info
            src_bucket = record["s3"]["bucket"]["name"]
            src_key = record["s3"]["object"]["key"]

            # Download the image
            response = s3_client.get_object(Bucket=src_bucket, Key=src_key)
            img_data = response["Body"].read()
            img = Image.open(io.BytesIO(img_data))

            # Resize image (make bigger by 1.5x)
            new_size = (int(img.width * 1.5), int(img.height * 1.5))
            img = img.resize(new_size)

            # Add watermark
            draw = ImageDraw.Draw(img)
            font_size = max(20, int(img.width / 15))
            try:
                font = ImageFont.truetype(
                    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size
                )
            except:
                font = ImageFont.load_default()
            text = "SaaProject"
            textwidth, textheight = draw.textsize(text, font)
            # Bottom right corner
            x = img.width - textwidth - 10
            y = img.height - textheight - 10
            draw.text((x, y), text, font=font, fill=(255, 255, 255, 128))

            # Save processed image to memory
            buffer = io.BytesIO()
            img_format = src_key.split(".")[-1].upper()
            if img_format == "JPG":
                img_format = "JPEG"
            img.save(buffer, format=img_format)
            buffer.seek(0)

            # Generate new key for processed bucket
            processed_key = f"processed-{src_key}"

            # Upload to processed bucket
            s3_client.put_object(
                Bucket=PROCESSED_BUCKET,
                Key=processed_key,
                Body=buffer,
                ContentType=response["ContentType"],
            )

            # Save metadata to DynamoDB
            table = dynamodb.Table(DYNAMODB_TABLE)
            table.put_item(
                Item={
                    "image_id": str(uuid.uuid4()),
                    "original_key": src_key,
                    "processed_key": processed_key,
                    "timestamp": datetime.datetime.utcnow().isoformat(),
                }
            )

        return {"statusCode": 200, "body": "Processing complete"}

    except Exception as e:
        print(e)
        return {"statusCode": 500, "body": str(e)}
