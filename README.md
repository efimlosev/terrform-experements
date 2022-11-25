# terrform-experements

I am a student at foothill college and studying AWS. The tasks I have in that class are all very basic. I don't know terraform, so I use these basic tasks to learn a bit of terraform code.

The class just began, so I have covered  only one module so far:
- Creation an S3 bucket with a lifecycle policy.
- Creation an EFS share with exposure of mount points in several availability zones.
- Creation of an EBS volume 

The task for the third  module  the first lab is basic create an ec2 instance so I did.

The fourth module is pretty create a load balancer for autoscaling groups.

I followed  this tutorial https://docs.aws.amazon.com/lambda/latest/dg/with-s3-tutorial.html#s3-tutorial-events-adminuser-create-test-function-upload-zip-test-manual-invoke to completethe miodule #8. One of chalenges I faced was undestanding how IAM assume role works.
The command bellow helped me to build dependicies  for the Lambda function"
```bash  docker run --rm -it -v "$PWD/lambda-s3:/lambda-s3" node:lts-bullseye-slim /bin/bash -c "cd /lambda-s3/;mkdir node_modules;cd node_modules;npm install sharp;exit"```
