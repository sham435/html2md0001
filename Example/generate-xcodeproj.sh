#!/bin/bash

# HTML2MD Example Xcode Project Generator
# This script creates an Xcode project for the HTML2MD example app

set -e

echo "🔨 Creating Xcode project for HTML2MD Example..."
echo

# Change to the Example directory
cd "$(dirname "$0")"

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo "⚠️  XcodeGen not found. Installing..."
    
    # Try to install via homebrew
    if command -v brew &> /dev/null; then
        echo "Installing XcodeGen via Homebrew..."
        brew install xcodegen
    else
        echo "❌ Homebrew not found. Please install XcodeGen manually:"
        echo "   brew install xcodegen"
        echo "   or"
        echo "   mint install yonaskolb/XcodeGen"
        exit 1
    fi
fi

# Generate the Xcode project
echo "📦 Generating Xcode project..."
xcodegen generate

# Open in Xcode if requested
if [ "$1" = "--open" ]; then
    echo "📱 Opening project in Xcode..."
    open HTML2MDExample.xcodeproj
fi

echo
echo "✅ Xcode project generated successfully!"
echo "   Project: $(pwd)/HTML2MDExample.xcodeproj"
echo
echo "To open in Xcode:  open HTML2MDExample.xcodeproj"
echo "To select scheme:  Use 'HTML2MDExample-iOS' or 'HTML2MDExample-macOS'"
echo
echo "💡 Note: If you see Xcode build warnings about recommended settings,"
echo "   just run this script again to regenerate with updated settings."