rm -rf source-clone-for-gen
git clone https://github.com/RaPaLearning/gita-begin source-clone-for-gen
dart generate_headers.dart
cp consts.dart ../lib/shloka_headers.dart
