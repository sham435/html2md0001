#!/bin/bash

# SwiftFormat runner for Demark
# This script runs SwiftFormat with appropriate configuration

set -e

echo "🎨 Running SwiftFormat for Demark..."

# Check if SwiftFormat is installed
if ! command -v swiftformat &> /dev/null; then
    echo "❌ SwiftFormat is not installed."
    echo "📦 Install via Homebrew: brew install swiftformat"
    echo "📦 Or via Mint: mint install nicklockwood/SwiftFormat"
    exit 1
fi

# Change to the project root directory
cd "$(dirname "$0")/.."

# Display SwiftFormat version
echo "📋 SwiftFormat version: $(swiftformat --version)"

# Run SwiftFormat
if [ "$1" = "--check" ] || [ "$1" = "--lint" ]; then
    echo "🔍 Running SwiftFormat in lint mode..."
    swiftformat --config .swiftformat --lint .
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ SwiftFormat check passed - code is properly formatted!"
    else
        echo "❌ SwiftFormat found formatting issues"
        echo "💡 Tip: Run './scripts/swiftformat.sh' to auto-format the code"
    fi
else
    echo "🔧 Running SwiftFormat to format code..."
    swiftformat --config .swiftformat .
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ SwiftFormat completed successfully!"
    else
        echo "❌ SwiftFormat encountered issues (exit code: $exit_code)"
    fi
fi

exit $exit_code