#!/bin/bash

# on windows, run from Git Bash

set -e
RED='\033[0;31m'
NC='\033[0m'

if [[ -d gita-begin/gita ]] && [[ -d gita-begin/compile ]]
then
  echo "Skipping Gita clone, since gita-begin/gita gita-begin/compile already exist"
else
  bash gita-begin-offline.sh
fi

dart format -l 100 .
flutter analyze
flutter test --dart-define=actionHideInSecs=0 --coverage

echo
filesWithoutFuncs=$(grep -rLE "\)\s*{" ./lib | sed 's/^.\///g' | tr '\n' , | sed 's/,$//g')
exclusion="--exclude=$filesWithoutFuncs,main.dart,generated_plugin_registrant.dart,firebase_options.dart"

echo "run command on Ubuntu for html report:"
echo "genhtml coverage/lcov.info -o coverage"

dart run test_cov_console $exclusion
sed -i 's/\\/\//g' coverage/lcov.info
dart run test_cov_console --pass=100 | grep -q PASS

dart run test_cov_console --csv $exclusion
if grep -q "no unit test" coverage/test_cov_console.csv; then
  echo -e "${RED}Some files aren't covered${NC}"
  exit 1
fi

echo Check Complete :\)