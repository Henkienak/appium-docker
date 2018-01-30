FROM busybox

ARG APPIUM_VERSION

ADD . /root/appium/appium/$APPIUM_VERSION

VOLUME /root/appium/appium/$APPIUM_VERSION

# Useless ENTRYPOINT so docker is happy building and running this image
ENTRYPOINT ["/bin/echo", "foo"]
