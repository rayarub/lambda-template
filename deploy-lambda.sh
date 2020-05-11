#!/bin/bash
set -e

#####
# CONFIGURE ME!
#
s3_bucket=''
lambda_function_name=''
#####

echo "Building project..."
npm i

echo "Packaging lambda..."
tmp_dir=$(mktemp -d -t lambda-build-XXXXXXXXXX)
tmp_file="${tmp_dir}/package.zip"

stage_dir="${tmp_dir}/stage"
mkdir "${stage_dir}"

cp -R ./* "${stage_dir}"
pushd "${stage_dir}"
zip -r "$tmp_file" ./
popd

echo "Uploading lambda to S3..."
s3_key="${lambda_function_name}/${timestamp}.zip"
aws s3 cp "${tmp_file}" "s3://${s3_bucket}/${s3_key}"

echo "Updating lambda function code from S3..."
aws lambda update-function-code \
    --function-name "${lambda_function_name}" \
    --s3-bucket ${s3_bucket} \
    --s3-key "${s3_key}"

echo "Cleaning up..."
rm -rf "$tmp_dir"

echo "Done!"