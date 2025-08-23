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
   - Launch app → Select "Take a tour" → Select a guided tour → Play narrated content → Verify audio plays and subtitles appear → Test pause/resume functionality
2. **Chapter Browse**:
   - Launch app → Select "Start chapter by chapter" → Browse chapters → Open a specific shloka (e.g., Chapter 2, Shloka 47) → Verify markdown content renders correctly → Test navigation between shlokas
3. **Search Functionality**:
   - From main screen → Use search → Enter keywords like "dharma" or "karma" → Verify results appear → Tap result → Verify navigation to correct content
4. **Offline Content**:
   - Verify app works without network after initial setup → All content should load from local storage → Test that tours, chapters, and search all work offline
5. **Content Navigation**:
   - Test back/forward navigation → Verify proper state management → Test deep linking if app supports it

### Testing Requirements:
- 100% test coverage is **strictly enforced** - the CI will fail if coverage drops below 100%
- All unit tests must pass: `flutter test`
- Widget tests use GetX dependency injection - see test files for mocking patterns
- Integration tests via: `flutter drive --driver=test_driver/screenshot_driver.dart --target=integration_test/integ_test.dart`
- Mock generation required: `dart run build_runner build` (generates .mocks.dart files)
- Test coverage report: `dart run test_cov_console --csv` with exclusions for generated files
- **Manual validation required**: Run through the user scenarios above after any UI changes

### Test Patterns in this Codebase:
- Uses `mockito` for mocking dependencies (see `guided_tour_test.mocks.dart`)
- GetX dependency injection with `Get.put()` and `Get.find()` patterns  
- Widget testing with `flutter_test` framework
- DioAdapter for mocking HTTP requests in tests
- Audio player mocking for tour functionality tests

## Project Structure

### Key Directories:
- `/feeder/` - **Main Flutter application** (primary development focus)
- `/htmlapp/` - Legacy HTML content
- `/old/` - Legacy Android Java application (deprecated)
- `/feeder/lib/` - Main Dart source code (~7,000 lines)
- `/feeder/test/` - Unit tests (comprehensive test suite)
- `/feeder/gita-begin/` - Offline content (setup via gita-begin-offline.sh)

### Key Files to Know:
- `/feeder/pubspec.yaml` - Dependencies and app configuration (Flutter 3.5+, key packages: get, dio, firebase)
- `/feeder/lib/main.dart` - Application entry point with Firebase initialization
- `/feeder/lib/home.dart` - Main app navigation and routing setup
- `/feeder/lib/feedcontent.dart` - Content management, tour functionality, and audio player integration
- `/feeder/lib/content_source.dart` - GitHub content fetching and caching logic
- `/feeder/lib/guided_tour.dart` - Tour UI and narration controls
- `/feeder/lib/mdcontent.dart` - Markdown content rendering
- `/feeder/checkmycode.sh` - Comprehensive validation script (format, analyze, test, coverage)
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

### Full Validation Workflow:
```bash
cd feeder/
bash checkmycode.sh         # Complete validation (20-40 minutes)
```

### Release Build Workflow:
```bash
cd feeder/
flutter build appbundle --release --build-name 1.0.0 --build-number 1
```

### Content Management:
- Content is fetched from https://github.com/rapalearning/gita-begin
- Offline setup must be run first: `bash gita-begin-offline.sh`
- Content includes compiled JSON files and markdown chapters in `gita-begin/gita/`
- Compiled metadata in `gita-begin/compile/` includes opener questions and navigation data
- Tour content includes narrated audio files served from GitHub CDN

### Generated Files (Do Not Edit Manually):
- `lib/shloka_headers.dart` - Generated from tools/generate_headers.sh
- Test mock files - Generated via `dart run build_runner build`
- Firebase configuration files - Generated via FlutterFire CLI

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
- **Flutter version issues**: CI uses Flutter stable via `subosito/flutter-action@v2`
- **Android build issues**: Ensure Java 17+ and Android SDK are properly configured

### Content Issues:
- **Missing audio**: Audio files are served from GitHub CDN, ensure network access during runtime
- **Missing chapters**: Verify gita-begin content was properly cloned and compiled JSON exists
- **Navigation issues**: Check that prior/next navigation data in compiled JSON is valid

### Performance Issues:
- **Slow app start**: Normal due to offline content loading and Firebase initialization
- **Memory issues**: Large content dataset - verify efficient loading in feedcontent.dart
- **Build slowness**: Dart compilation and test coverage analysis are intensive operations

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
- **Architecture**: GetX state management with reactive programming patterns
- **Content Strategy**: Offline-first with GitHub-hosted markdown and audio content
- **Audio Integration**: just_audio package for narrated tours with background music
- **UI Framework**: Material Design with custom theming and Google Fonts
- **Backend**: Firebase for crash reporting and analytics (no authentication required)
- **Testing**: Comprehensive test coverage requirements (100%) with widget and integration tests
- **CI/CD**: Established pipeline with Google Play Store integration via fastlane
- **Content Management**: External content repository (rapalearning/gita-begin) with automated synchronization
- **Navigation**: GetX routing with deep link support for content pages
- **Localization**: Infrastructure present for multi-language support
- **Performance**: Optimized for offline usage with efficient content caching

### Technical Stack:
- **State Management**: GetX (reactive programming)
- **HTTP Client**: Dio with mock adapters for testing
- **Audio**: just_audio with playlist support
- **Markdown**: Flutter markdown rendering
- **Fonts**: Google Fonts with local caching
- **Icons**: Cupertino icons with custom launcher icons
- **Testing**: mockito + flutter_test + integration_test
- **Build**: Standard Flutter build tools with fastlane deployment