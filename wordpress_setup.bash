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
  zip -r ../wordpress.zip .
  rm -rf wordpress/
}

if [ "$1" == ""]; then
  secret=$(openssl rand -hex 64)
else
  secret=$1
fi

download_wordpress

move_htaccess

edit_htaccess $secret

install_wordpress_plugins

edit_wp_config

create_wp_zip

echo "Access Key:" $secret
