# appium-docker

### Example usages

Build normal Appium version: `./build.sh -a 1.6.0 -p false -t 1.6.0`

Build Appium with patched chromedriver: `./build.sh -a 1.5.2 -p true -t 1.6.0-patched-chromedriver`

Build Appium with specific chromedriver version: `./build.sh -a 1.6.0 -p false -c 2.26 -t 1.6.0-updated-chromedriver`

Using the "patched chromedriver" overwrites Appium's chromedriver with the binary in the directory `patched-chromedriver-linux`.
