#!/bin/bash

BASE_URL=$1
if [ -z $BASE_URL ]; then
    echo "Missing url"
    echo "$0 base_url build_number"
    exit 1;
fi

BUILD_NUMBER=$2
if [ -z $BUILD_NUMBER ]; then
    echo "Missing build number"
    echo "$0 base_url build_number"
    exit 2;
fi

# http://qa.nuxeo.org/jenkins/job/addons_nuxeo-web-mobile-cordova-iOS-master/19/artifact/iOS/nuxeo-web-mobile-ios/build/nuxeo-web-mobile-Release-19.ipa

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
  <key>items</key>
  <array>
    <dict>
      <key>assets</key>
      <array>
        <dict>
          <key>kind</key>
          <string>software-package</string>
          <key>url</key>
          <string>$BASE_URL/artifact/iOS/nuxeo-web-mobile-ios/build/nuxeo-web-mobile-Release-$BUILD_NUMBER.ipa</string>
        </dict>
      </array>
      <key>metadata</key>
      <dict>
        <key>bundle-identifier</key>
        <string>org.nuxeo.nuxeo.web.mobile</string>
        <key>kind</key>
        <string>software</string>
        <key>subtitle</key>
        <string>Nuxeo Web Mobile application</string>
        <key>title</key>
        <string>nuxeo-web-mobile</string>
      </dict>
    </dict>
  </array>
</dict>
</plist>" > nuxeo-web-mobile.plist
