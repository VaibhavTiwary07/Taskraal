#!/bin/bash

# Fix project script for Taskraal
echo "Starting project fixes for Taskraal..."

# Set the working directory
cd "$(dirname "$0")"

# Backup the project file first
echo "Backing up project.pbxproj..."
cp Taskraal.xcodeproj/project.pbxproj Taskraal.xcodeproj/project.pbxproj.bak

# 1. Remove SchedulingServices.swift (plural) and only keep SchedulingService.swift (singular)
echo "Fixing SchedulingService vs SchedulingServices issue..."
if [ -f "Taskraal/Services/SchedulingServices.swift" ] && [ -f "Taskraal/Services/SchedulingService.swift" ]; then
    # Update references in project file
    sed -i '' 's/SchedulingServices\.swift/SchedulingService\.swift/g' Taskraal.xcodeproj/project.pbxproj
    
    # Remove the duplicate file
    rm "Taskraal/Services/SchedulingServices.swift"
    echo "Removed duplicate SchedulingServices.swift file"
fi

# 2. Add AIPrioritizationViewController.swift to the project
echo "Adding AIPrioritizationViewController.swift to project..."

# First, check if the file exists
if [ -f "Taskraal/Controllers/AIPrioritizationViewController.swift" ]; then
    # Generate a unique UUID for the new file reference
    NEW_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
    
    # Find the PBXFileReference section and add our new file
    sed -i '' "/^\t\tDB6FA5672D9E862800633F8F.*TaskCell.swift/a\\
        $NEW_UUID /* AIPrioritizationViewController.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AIPrioritizationViewController.swift; sourceTree = \"<group>\"; };" Taskraal.xcodeproj/project.pbxproj
    
    # Find the PBXBuildFile section and add our new file
    BUILD_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
    sed -i '' "/^\t\tDB6FA5682D9E862800633F8F.*TaskCell.swift in Sources/a\\
        $BUILD_UUID /* AIPrioritizationViewController.swift in Sources */ = {isa = PBXBuildFile; fileRef = $NEW_UUID /* AIPrioritizationViewController.swift */; };" Taskraal.xcodeproj/project.pbxproj
    
    # Add the file to the Controllers group
    sed -i '' "/^\t\t\t\tDBBF60652D81857900465BFF.*TaskViewController.swift/a\\
                $NEW_UUID /* AIPrioritizationViewController.swift */," Taskraal.xcodeproj/project.pbxproj
    
    # Add the file to the build sources
    sed -i '' "/^\t\t\tDBBF60662D81857900465BFF.*TaskViewController.swift in Sources/a\\
                $BUILD_UUID /* AIPrioritizationViewController.swift in Sources */," Taskraal.xcodeproj/project.pbxproj
    
    echo "Added AIPrioritizationViewController.swift to project"
else
    echo "Error: AIPrioritizationViewController.swift not found in Taskraal/Controllers/"
    exit 1
fi

# Clean the derived data to force a complete rebuild
echo "Cleaning derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Taskraal-*

echo "Project fixes completed!"
echo "Please rebuild the project in Xcode or using xcodebuild." 