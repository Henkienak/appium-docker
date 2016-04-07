#!/bin/bash
appium_version=$1
tag=$2

docker build --build-arg APPIUM_VERSION=$appium_version -t testobject-appium .

docker tag -f testobject-appium testobject/appium:$appium_version
docker push testobject/appium:$appium_version

docker tag -f testobject-appium quay.io/testobject/appium:$appium_version
docker push quay.io/testobject/appium:$appium_version
