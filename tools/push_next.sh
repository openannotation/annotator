echo "Generating package files"
cake package
cake package:kitchensink

# Upload release to S3
echo "Uploading 'next' to S3"
s3cmd --acl-public sync pkg/*.{js,css} "s3://assets.annotateit.org/annotator/next/"