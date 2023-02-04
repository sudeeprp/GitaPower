#!/bin/bash

# on windows, run from Git Bash

set -e
RED='\033[0;31m'
NC='\033[0m'

flutter format .
flutter analyze
flutter test --coverage

echo
filesWithoutFuncs=$(grep -rLE "\)\s*{" ./lib | sed 's/^.\///g' | tr '\n' , | sed 's/,$//g')
if [ -z "$filesWithoutFuncs" ]
then
    echo "Only generated files excluded from coverage"
    exclusion="--exclude=generated_plugin_registrant.dart"
else
    echo "Coverage ignored for files without functions and generated code:"
    echo $filesWithoutFuncs
    exclusion="--exclude=$filesWithoutFuncs,generated_plugin_registrant.dart"
fi

flutter pub run test_cov_console $exclusion
sed -i 's/\\/\//g' coverage/lcov.info
flutter pub run test_cov_console --pass=100 | grep -q PASS

echo "run command on Ubuntu for html report:"
echo "genhtml coverage/lcov.info -o coverage"

flutter pub run test_cov_console --csv $exclusion
if grep -q "no unit test" coverage/test_cov_console.csv; then
  echo -e "${RED}Some files aren't covered${NC}"
  exit 1
fi

echo Check Complete :\)