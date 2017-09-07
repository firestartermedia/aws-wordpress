
# Site Configuration
WPHome="https://www.test.com/"
CNAME="www.test.com"

# Admin Configuration
AdminIP="77.98.191.19"

# AWS Config
stackName=wordpress-$(date "+%Y-%m-%d-%H-%M-%S")
awsRegion="eu-west-2" # Make sure this is the same as your aws-cli region
S3CodeStorageBucketName="wordpress-aws-code-storage"

# Database Config
dbPass=$(openssl rand -hex 16)
allocatedStorage=5 # DB Storage in GB
DBInstanceClass="db.t2.micro" # DB Instance Type
SQLUsername="wordpress"

