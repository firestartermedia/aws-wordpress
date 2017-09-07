stackName=wordpress-$(date "+%Y-%m-%d-%H-%M-%S")
siteURL="www.test.com"
S3CodeStorageBucketName="wordpress-aws-code-storage"
awsRegion="eu-west-2" # Make sure this is the same as your aws-cli region
dbPass=$(openssl rand -hex 16)

