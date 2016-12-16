#!/bin/bash

usage() {
    echo "Usage: $0 [-a <appium_version>] [-p <true|false>] [-c <chromedriver version>] [-t <tag>] [-r <true|false>]"
    echo "-p: whether to replace chromedriver with patched binary"
}

while getopts ":a:p:c:t:r:" o; do
      case "${o}" in
	  a)
	      appium_version=${OPTARG}
	      ;;
	  p)
	      patched_chromedriver=${OPTARG}
	      ;;
	  c)
	      chromedriver_version=${OPTARG}
	      ;;
	  t)
	      tag=${OPTARG}
	      ;;
	  r)
	      release_images=${OPTARG}
	      ;;
	  *)
	      usage
	      ;;
      esac
done

docker build --build-arg APPIUM_VERSION=$appium_version --build-arg PATCHED_CHROMEDRIVER=$patched_chromedriver --build-arg CHROMEDRIVER_VERSION=$chromedriver_version -t testobject-appium:$tag .

if [ "$release_images" = true ]; then
    docker tag testobject-appium:$tag testobject/appium:$tag
    docker push testobject/appium:$tag

    docker tag testobject-appium:$tag quay.io/testobject/appium:$tag
    docker push quay.io/testobject/appium:$tag
fi
