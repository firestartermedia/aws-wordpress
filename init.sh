#!/bin/bash

function download_wordpress {
  curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
  tar -zxf wordpress.tar.gz
  rm -f wordpress.tar.gz
}

function edit_htaccess {
  sed -i ".bak" "s/SECRETKEY/$1/g" wordpress/.htaccess
  sed -i ".bak" "s/SECRETKEY/$1/g" wordpress/wp-admin/.htaccess
  rm -f wordpress/.htaccess.bak
  rm -f wordpress/wp-admin/.htaccess.bak
}

function move_htaccess {
  cp templates/root.htaccess wordpress
  cp templates/wp-admin.htaccess wordpress/wp-admin
  mv wordpress/root.htaccess wordpress/.htaccess
  mv wordpress/wp-admin/wp-admin.htaccess wordpress/wp-admin/.htaccess
}

function install_wordpress_plugins {
  cp -r templates/plugins/* wordpress/wp-content/plugins/
}

function edit_wp_config {
  configText=$(printf "define('WP_HOME',$_SERVER['WP_HOME']);\ndefine('WP_SITEURL', $_SERVER['REQUEST_SCHEME'] . '://' . $_SERVER[‘HTTP_HOST']);
")
  sed -i ".bak" "s/'database_name_here'/\$_SERVER['RDS_DB_NAME']/g" wordpress/wp-config-sample.php
  sed -i ".bak" "s/'username_here'/\$_SERVER['RDS_DB_USER']/g" wordpress/wp-config-sample.php
  sed -i ".bak" "s/'password_here'/\$_SERVER['RDS_DB_PASSWORD']/g" wordpress/wp-config-sample.php
  sed -i ".bak" "s/'localhost'/\$_SERVER['RDS_DB_HOST']/g" wordpress/wp-config-sample.php
  sed -i ".bak" "/<?php/r templates/wp-config-section.php" wordpress/wp-config-sample.php
  rm -f wordpress/wp-config-sample.php.bak
  mv wordpress/wp-config-sample.php wordpress/wp-config.php
}

function create_wp_zip {
  cd wordpress
  zip -r ../wordpress.zip . > /dev/null 2>&1
  cd ..
  rm -rf wordpress/
}


function create_cloud_formation {

  if ! aws s3 ls s3://$2/ > /dev/null 2>&1 ; then
    aws s3 mb s3://$2 --region $3
  fi
  aws s3 rm s3://$2/wordpress.zip
  aws s3 cp wordpress.zip s3://$2/

  aws cloudformation create-stack --template-body file://formation.yaml --stack-name wordpress-$(date "+%Y-%m-%d-%H-%M-%S") --parameters ParameterKey=wordpressDBName,ParameterValue=wordpress ParameterKey=wordpressDBUser,ParameterValue=wordpress ParameterKey=wordpressDBPass,ParameterValue=$1 ParameterKey=S3CodeStorageBucketName,ParameterValue=$2 ParameterKey=S3BucketName,ParameterValue=wordpress-$(date "+%Y-%m-%d-%H-%M-%S")
}


if [ "$1" == "" ]; then
  secret=$(openssl rand -hex 64)
else
  secret=$1
fi

dbPass=$(openssl rand -hex 16)
S3StorageBucketName="wordpress-aws-code-storage"
awsRegion="eu-west-2"

download_wordpress
move_htaccess
edit_htaccess $secret
install_wordpress_plugins
edit_wp_config
create_wp_zip
create_cloud_formation $dbPass $S3StorageBucketName $awsRegion

echo "Database Password:" $dbPass
echo "Access Key:" $secret
