#!/bin/bash
appium_version=$1
patched_chromedriver=$2
tag=$3

docker build --build-arg APPIUM_VERSION=$appium_version --build-arg PATCHED_CHROMEDRIVER=$patched_chromedriver -t testobject-appium:$tag .
    
docker tag -f testobject-appium:$tag testobject/appium:$tag
docker push testobject/appium:$tag

docker tag -f testobject-appium:$tag quay.io/testobject/appium:$tag
docker push quay.io/testobject/appium:$tag
