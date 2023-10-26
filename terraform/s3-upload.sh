#!/bin/bash

# Defining S3 Bucket name
S3_BUCKET="www.aidandethlefs.com"

# Defining an array of local files and directories to upload
FILES_AND_DIRS=(
    "../src/index.html"
    "../src/robots.txt"
    "../src/404.html"
    "../src/script.js"
    "../src/assets"
    "../src/css"
)

# Loop through the array and upload each one
for ITEM in "${FILES_AND_DIRS[@]}"; do
    # Check if item is a file
    if [ -f "$ITEM" ]; then
        # Extract file from path
        FILENAME=$(basename "$ITEM")
        # Upload to S3 Bucket
        aws s3 cp "$ITEM" "s3://$S3_BUCKET/$FILENAME"
    elif [ -d "$ITEM" ]; then
        # Check if item is a directory then sync to S3 Bucket
        aws s3 sync "$ITEM" "s3://$S3_BUCKET/$(basename "$ITEM")"
    fi
done