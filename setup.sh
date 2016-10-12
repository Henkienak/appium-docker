#!/bin/bash

echo "preparing appium version $APPIUM_VERSION with patched chromedriver $PATCHED_CHROMEDRIVER"

echo "Installing java dependency"
apt-get update
apt-get -y install default-jdk

appium_directory=/root/appium/appium/$APPIUM_VERSION
if [ "$PATCHED_CHROMEDRIVER" = true ]; then
  appium_directory=$appium_directory-patched-chromedriver
fi

npm install appium@$APPIUM_VERSION
mkdir -p /root/appium/appium/
mv /root/node_modules/appium $appium_directory
mkdir $appium_directory/build/SafariLauncher
cp --no-clobber /root/SafariLauncher.zip $appium_directory/build/SafariLauncher/SafariLauncher.zip
rm /root/SafariLauncher.zip

if [ "$APPIUM_VERSION" == '1.4.16' ]; then
  echo "replacing chromium driver"
  cd $appium_directory
  npm install appium-chromedriver@2.5.1

  # fix max buffer exceeded by increasing the buffer to 1MB
  sed -i -- 's/524288/1048576/g' node_modules/appium-adb/lib/adb.js
  sed -i -- 's/524288/1048576/g' node_modules/appium-adb/lib/helpers.js

  patch -p0 < /root/patches/0001-handover-custom-adb-port-to-chromedriver.patch;
fi

chromedriver_directory=$appium_directory/node_modules/appium-android-driver/node_modules/appium-chromedriver/chromedriver/linux

if [ "$PATCHED_CHROMEDRIVER" = true ]; then
  echo "Patching chromedriver"
    
  rm -r $chromedriver_directory
  mv /root/patched-chromedriver-linux $chromedriver_directory
else
  rm -r /root/patched-chromedriver-linux
fi

