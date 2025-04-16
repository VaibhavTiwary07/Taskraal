# Taskraal

A modern task management iOS application with AI-powered task prioritization.

## Features

- Create, edit and delete tasks with due dates and priority levels
- Organize tasks by categories
- AI-powered task prioritization
- Dark and light theme support
- Neumorphic UI design
- Core Data integration for local storage
- Calendar integration for task scheduling

## Requirements

- iOS 14.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

1. Clone the repository:
```
git clone https://github.com/yourusername/Taskraal.git
cd Taskraal
```

2. Open the project in Xcode:
```
open Taskraal.xcodeproj
```

3. Build and run the application (⌘+R).

## Project Structure

- **Controllers/**: View controllers for different screens
- **Views/**: Custom views and cells
- **Models/**: Data models
- **Services/**: Core services (CoreDataManager, ThemeManager, etc.)
- **Extensions/**: Swift extensions

## Building for Production

The project includes a build script for creating production-ready builds:

```
./build.sh
```

This script:
1. Cleans previous build artifacts
2. Builds and runs tests
3. Creates an archive
4. Exports an IPA file

The resulting IPA will be in the `build/Export` directory.

## Manual Deployment

### TestFlight

1. Archive the app in Xcode: Product > Archive
2. In the Archives organizer, click "Distribute App"
3. Select "App Store Connect" and follow the steps
4. Upload to App Store Connect
5. Configure the build in TestFlight and add testers

### App Store

1. Complete all App Store submission requirements in App Store Connect
2. Upload the build via Xcode
3. Submit for review

## Configuration

### OpenAI API

To use the AI prioritization feature, you need to provide an OpenAI API key:

1. Get an API key from [OpenAI](https://openai.com)
2. Enter the key in the app settings screen

## Troubleshooting

### Common Build Issues

- **Code Signing Issues**: Ensure you have the proper provisioning profiles set up
- **Missing Files**: Check the project structure for any references to missing files
- **Core Data Issues**: Make sure the Core Data model is up to date

### Running Tests

Run tests using:
```
xcodebuild test -project Taskraal.xcodeproj -scheme Taskraal -destination "platform=iOS Simulator,name=iPhone 15"
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any inquiries, please contact [your-email@example.com]. 