#!/bin/bash

# Build script for Taskraal app
# This script performs cleaning, building, testing, and archiving for production

# Set workspace and scheme
PROJECT_NAME="Taskraal"
SCHEME_NAME="Taskraal"
WORKSPACE_PATH="${PROJECT_NAME}.xcodeproj"

# Set build directories
BUILD_DIR="build"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/Export"
IPA_PATH="${EXPORT_PATH}/${PROJECT_NAME}.ipa"

# Set export options
EXPORT_OPTIONS_FILE="ExportOptions.plist"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print section header
print_header() {
    echo -e "\n${BLUE}==================== $1 ====================${NC}\n"
}

# Print status message
print_status() {
    echo -e "${YELLOW}$1${NC}"
}

# Print success message
print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Print error message
print_error() {
    echo -e "${RED}$1${NC}"
}

# Create required directories
create_directories() {
    print_header "Creating build directories"
    mkdir -p "${BUILD_DIR}"
    mkdir -p "${EXPORT_PATH}"
    print_success "Build directories created."
}

# Clean build artifacts
clean_build() {
    print_header "Cleaning previous build"
    xcodebuild clean -project "${WORKSPACE_PATH}" -scheme "${SCHEME_NAME}" || {
        print_error "Failed to clean project."
        exit 1
    }
    print_success "Project cleaned successfully."
}

# Build for testing
build_for_testing() {
    print_header "Building for testing"
    xcodebuild build-for-testing -project "${WORKSPACE_PATH}" -scheme "${SCHEME_NAME}" -destination "platform=iOS Simulator,name=iPhone 15" || {
        print_error "Build for testing failed."
        exit 1
    }
    print_success "Build for testing completed successfully."
}

# Run tests
run_tests() {
    print_header "Running tests"
    xcodebuild test -project "${WORKSPACE_PATH}" -scheme "${SCHEME_NAME}" -destination "platform=iOS Simulator,name=iPhone 15" || {
        print_error "Tests failed."
        exit 1
    }
    print_success "All tests passed."
}

# Build for archiving
build_archive() {
    print_header "Building archive"
    xcodebuild archive -project "${WORKSPACE_PATH}" -scheme "${SCHEME_NAME}" -archivePath "${ARCHIVE_PATH}" || {
        print_error "Archive build failed."
        exit 1
    }
    print_success "Archive build completed successfully."
}

# Create export options plist if it doesn't exist
create_export_options() {
    if [ ! -f "${EXPORT_OPTIONS_FILE}" ]; then
        print_status "Creating export options file: ${EXPORT_OPTIONS_FILE}"
        cat > "${EXPORT_OPTIONS_FILE}" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>3LUNZ43L4D</string>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF
        print_success "Export options file created."
    else
        print_status "Using existing export options file: ${EXPORT_OPTIONS_FILE}"
    fi
}

# Export IPA
export_ipa() {
    print_header "Exporting IPA"
    create_export_options
    xcodebuild -exportArchive -archivePath "${ARCHIVE_PATH}" -exportPath "${EXPORT_PATH}" -exportOptionsPlist "${EXPORT_OPTIONS_FILE}" || {
        print_error "Export failed."
        exit 1
    }
    print_success "IPA exported successfully."
}

# Main build process
main() {
    print_header "Starting Taskraal production build"

    # Make sure we're in the right directory (project root)
    cd "$(dirname "$0")" || {
        print_error "Failed to navigate to script directory."
        exit 1
    }

    # Run build steps
    create_directories
    clean_build
    build_for_testing
    run_tests
    build_archive
    export_ipa

    # Verify IPA exists
    if [ -f "${IPA_PATH}" ]; then
        print_success "Build successful! IPA is located at: ${IPA_PATH}"
    else
        print_error "Build process completed, but IPA file not found."
        exit 1
    fi
}

# Execute the main function
main 