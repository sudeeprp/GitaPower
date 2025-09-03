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

dart format -l 110 .
flutter analyze
flutter test --dart-define=actionHideInSecs=0 --coverage

echo
filesWithoutFuncs=$(grep -rLE "\)\s*{" ./lib | sed 's/^.\///g' | tr '\n' , | sed 's/,$//g')
exclusion="--exclude=$filesWithoutFuncs,main.dart,generated_plugin_registrant.dart,firebase_options.dart"
dart run test_cov_console --csv $exclusion
if grep -q "no unit test" coverage/test_cov_console.csv; then
  echo -e "${RED}Some files aren't covered${NC}"
  exit 1
fi

set +e
cat coverage/lcov.info | dart run check_coverage 100

if [[ $? -ne 0 ]]; then
  echo -e "${RED}Coverage is below 100%${NC}"
  echo "run command on Ubuntu for html report:"
  echo "genhtml coverage/lcov.info -o coverage"
  exit 1
fi

echo "Check Complete 🙂 at $(date '+%Y-%m-%d %H:%M:%S')"
