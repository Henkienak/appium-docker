#!/bin/bash

echo "preparing appium version $APPIUM_VERSION with patched chromedriver $PATCHED_CHROMEDRIVER"

function set_appium_directory
{
    appium_directory=/root/appium/appium/$APPIUM_VERSION
    if [ "$PATCHED_CHROMEDRIVER" = true ]; then
	appium_directory=$appium_directory-patched-chromedriver
    fi
}

function install_jdk
{
    echo "INSTALLING JDK"
    apt-get update
    apt-get -y install default-jdk
}

function install_appium
{
    npm install appium@$APPIUM_VERSION
    mkdir -p /root/appium/appium/
    mv /root/node_modules/appium $appium_directory
    mkdir $appium_directory/build/SafariLauncher
    cp --no-clobber /root/SafariLauncher.zip $appium_directory/build/SafariLauncher/SafariLauncher.zip
    rm /root/SafariLauncher.zip
}

function patch_chromedriver
{
    chromedriver_directory=$appium_directory/node_modules/appium-android-driver/node_modules/appium-chromedriver/chromedriver/linux
    rm -r $chromedriver_directory
    mv /root/patched-chromedriver-linux $chromedriver_directory
}

function patch_appium_1_4_16
{
    echo "replacing chromium driver"
    cd $appium_directory
    npm install appium-chromedriver@2.5.1
    
    # fix max buffer exceeded by increasing the buffer to 1MB
    sed -i -- 's/524288/1048576/g' node_modules/appium-adb/lib/adb.js
    sed -i -- 's/524288/1048576/g' node_modules/appium-adb/lib/helpers.js

    patch -p0 < /root/patches/0001-handover-custom-adb-port-to-chromedriver.patch;
}

install_jdk
set_appium_directory
install_appium

if [ "$APPIUM_VERSION" == '1.4.16' ]; then
    patch_appium_1_4_16
fi

if [ "$PATCHED_CHROMEDRIVER" = true ]; then
  patch_chromedriver
else
  rm -r /root/patched-chromedriver-linux
fi

