# GitaPower - Krishna's Gita Application

GitaPower is a Flutter mobile application that provides access to the Bhagavad Gita with narrated tours, chapter browsing, and search functionality. The app includes offline content, comprehensive testing, and is published to Google Play Store.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Initial Setup (REQUIRED - Run these commands first)
- **CRITICAL**: Always start by setting up offline content: `bash gita-begin-offline.sh` - takes 1-2 minutes to clone content. NEVER CANCEL.
- Install Flutter via the standard GitHub Actions approach (see CI configuration) or use `subosito/flutter-action@v2`
- Navigate to the main application directory: `cd feeder/`
- Get dependencies: `flutter pub get` - takes 2-5 minutes depending on network. NEVER CANCEL.
- Setup application icon: `flutter pub run flutter_launcher_icons:main`
- Generate mocks for testing: `dart run build_runner build` - takes 5-10 minutes. NEVER CANCEL.

### Build Commands
- **Format code (ALWAYS run before committing)**: `dart format -l 110 .` - takes 10-30 seconds
- **Static analysis**: `flutter analyze` - takes 30-60 seconds  
- **Run tests with coverage**: `flutter test --dart-define=actionHideInSecs=0 --coverage` - takes 15-30 minutes. NEVER CANCEL. Set timeout to 45+ minutes.
- **Comprehensive check**: `bash checkmycode.sh` - takes 20-40 minutes total. NEVER CANCEL. Set timeout to 60+ minutes.
- **Build release APK**: `flutter build appbundle --release` - takes 45-90 minutes. NEVER CANCEL. Set timeout to 120+ minutes.

### Development Workflow
- **ALWAYS** run `bash gita-begin-offline.sh` first to setup required offline content from GitHub
- **ALWAYS** run `flutter pub get` after any pubspec.yaml changes
- **ALWAYS** run `dart format -l 110 .` before committing (CI will fail otherwise)
- **ALWAYS** ensure tests pass with 100% coverage requirement - this is strictly enforced

## Validation Scenarios

**CRITICAL**: After any code changes, always validate with these complete user scenarios:

### Essential User Scenarios to Test:
1. **App Launch and Tour**: 
   - Launch app → Select "Take a tour" → Play narrated content → Verify audio plays and subtitles appear
2. **Chapter Browse**:
   - Launch app → Select "Start chapter by chapter" → Browse chapters → Open a specific shloka → Verify content loads
3. **Search Functionality**:
   - From main screen → Use search → Enter keywords → Verify results appear and are navigable
4. **Offline Content**:
   - Verify app works without network after initial setup → All content should load from local storage

### Testing Requirements:
- 100% test coverage is **strictly enforced** - the CI will fail if coverage drops below 100%
- All unit tests must pass: `flutter test`
- Integration tests via: `flutter drive --driver=test_driver/screenshot_driver.dart --target=integration_test/integ_test.dart`
- **Manual validation required**: Run through the user scenarios above after any UI changes

## Project Structure

### Key Directories:
- `/feeder/` - **Main Flutter application** (primary development focus)
- `/htmlapp/` - Legacy HTML content
- `/old/` - Legacy Android Java application (deprecated)
- `/feeder/lib/` - Main Dart source code (~7,000 lines)
- `/feeder/test/` - Unit tests (comprehensive test suite)
- `/feeder/gita-begin/` - Offline content (setup via gita-begin-offline.sh)

### Key Files to Know:
- `/feeder/pubspec.yaml` - Dependencies and app configuration
- `/feeder/lib/main.dart` - Application entry point
- `/feeder/lib/home.dart` - Main app navigation
- `/feeder/lib/feedcontent.dart` - Content management and tour functionality  
- `/feeder/checkmycode.sh` - Comprehensive validation script
- `/feeder/gita-begin-offline.sh` - Required content setup script

### Build Configuration:
- Target SDK: Android API 35, iOS latest
- Requires Java 17+ (verified available)
- Flutter SDK 3.5+ (install via standard methods)
- Firebase integration for crash reporting
- Uses fastlane for Google Play Store deployment

## CI/CD Integration

### GitHub Actions Workflows:
- **checkmycode.yml**: Runs format checking and full test suite - takes 20-40 minutes
- **build-apk.yml**: Builds release APK and deploys to Google Play Store - takes 60-120 minutes
- **format.yml**: Code formatting validation
- **screenshots.yml**: Generates app screenshots using Android emulator

### Pre-commit Requirements:
- **ALWAYS** run `dart format -l 110 .` (exactly line length 110)
- **ALWAYS** ensure `bash checkmycode.sh` passes completely
- **NEVER** commit if test coverage drops below 100%

## Common Tasks

### Quick Development Workflow:
```bash
cd feeder/
bash gita-begin-offline.sh  # Setup content (first time only)
flutter pub get              # Get dependencies  
dart run build_runner build  # Generate mocks
flutter test                 # Run tests
dart format -l 110 .        # Format code
flutter analyze             # Static analysis
```

### Content Management:
- Content is fetched from https://github.com/rapalearning/gita-begin
- Offline setup must be run first: `bash gita-begin-offline.sh`
- Content includes compiled JSON files and markdown chapters
- Tour content includes narrated audio files

### Release Process:
- Code formatting and tests must pass
- Build via `flutter build appbundle --release`
- Fastlane handles Google Play Store deployment
- Screenshots are generated via Android emulator integration tests

## Troubleshooting

### Common Issues:
- **gita-begin content missing**: Run `bash gita-begin-offline.sh`
- **Build failures**: Ensure `flutter pub get` has been run
- **Test failures**: Check that all mocks are generated via `dart run build_runner build`
- **Format failures**: Run `dart format -l 110 .` with exactly 110 character line length
- **Coverage failures**: Add tests for any new code - 100% coverage is strictly required

### Network Dependencies:
- Initial content setup requires GitHub access
- Flutter pub get requires package repository access
- All content is cached locally after initial setup

### Android Build Requirements:
- Java 17+ (available in environment)
- Android SDK (setup via Flutter)
- NDK 27.0.12077973 (specified in build.gradle)
- Kotlin support enabled

## Time Expectations

**CRITICAL TIMING INFORMATION - NEVER CANCEL THESE OPERATIONS:**

- Content setup (`gita-begin-offline.sh`): 1-2 minutes
- Dependencies (`flutter pub get`): 2-5 minutes  
- Mock generation (`dart run build_runner build`): 5-10 minutes
- Full test suite (`flutter test`): 15-30 minutes
- Complete validation (`checkmycode.sh`): 20-40 minutes  
- Release build (`flutter build appbundle`): 45-90 minutes
- CI pipeline complete: 60-120 minutes

**Always set timeouts with significant buffer: add 50-100% to expected times. Build cancellation will corrupt the development environment.**

## Development Environment Notes

This is a mature Flutter application with:
- Comprehensive test coverage requirements (100%)
- Established CI/CD pipeline with Google Play Store integration
- Firebase crash reporting and analytics
- Offline-first content approach
- Narrated tour functionality with audio
- Multi-language support infrastructure