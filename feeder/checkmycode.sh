#!/bin/bash
set -e
RED='\033[0;31m'
NC='\033[0m'

jscpd --min-lines 3 --min-tokens 50 --threshold 0 --gitignore --ignore "**/*.xml,**/*.json,windows"
flutter analyze
flutter test --coverage

echo
filesWithoutFuncs=$(grep -rLE "\)\s*{" ./lib | sed 's/^.\///g' | tr '\n' , | sed 's/,$//g')
echo "Files without functions, coverage ignored:"
echo $filesWithoutFuncs

flutter pub run test_cov_console --exclude=$filesWithoutFuncs
flutter pub run test_cov_console --pass=100 | grep -q PASS

flutter pub run test_cov_console --csv --exclude=$filesWithoutFuncs
if grep -q "no unit test" coverage/test_cov_console.csv; then
  echo -e "${RED}Some files aren't covered${NC}"
  exit 1
fi

echo Check Complete :\)