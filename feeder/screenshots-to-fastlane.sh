#!/bin/bash
set -e

PHONE_SCREENS_FOLDER=./android/fastlane/metadata/android/en-US/images/phoneScreenshots
rm $PHONE_SCREENS_FOLDER/*

cp ./screenshots/tour-light.png  $PHONE_SCREENS_FOLDER/1_en-US.png
cp ./screenshots/browse-chapters-light.png $PHONE_SCREENS_FOLDER/2_en-US.png
cp ./screenshots/shlokaheaders-light.png $PHONE_SCREENS_FOLDER/3_en-US.png
cp ./screenshots/browse-notes-light.png $PHONE_SCREENS_FOLDER/4_en-US.png
cp ./screenshots/shloka-light.png $PHONE_SCREENS_FOLDER/5_en-US.png
cp ./screenshots/shloka-dark.png $PHONE_SCREENS_FOLDER/6_en-US.png
cp ./screenshots/feed-light.png $PHONE_SCREENS_FOLDER/7_en-US.png
cp ./screenshots/personalize-light.png $PHONE_SCREENS_FOLDER/8_en-US.png
