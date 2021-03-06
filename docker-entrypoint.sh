#!/bin/bash
set -euo pipefail
set -o errexit
IFS=$'\n\t'

export S3_REGION=$S3_REGION
export S3_ACL=${S3_ACL:-private}

mkdir -p ${MNT_POINT}

if [ "$IAM_ROLE" == "none" ]; then
  export AWSACCESSKEYID=${AWSACCESSKEYID:-$AWS_KEY}
  export AWSSECRETACCESSKEY=${AWSSECRETACCESSKEY:-$AWS_SECRET_KEY}

  echo "${AWS_KEY}:${AWS_SECRET_KEY}" > /etc/passwd-s3fs
  chmod 0400 /etc/passwd-s3fs

  echo 'IAM_ROLE is not set - mounting S3 with credentials from ENV'
  /usr/bin/s3fs  ${S3_BUCKET} ${MNT_POINT} -d -d -f -o endpoint=${S3_REGION},allow_other,retries=5,rw -o use_cache=/tmp -o umask=0022
  echo 'Done!'
else
  echo 'IAM_ROLE is set - using it to mount S3'
  /usr/bin/s3fs ${S3_BUCKET} ${MNT_POINT} -d -d -f -o endpoint=${S3_REGION},iam_role=${IAM_ROLE},allow_other,retries=5
fi
