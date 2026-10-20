#!/bin/bash

# SwiftLint runner for Demark
# This script runs SwiftLint with appropriate configuration

set -e

echo "🔍 Running SwiftLint for Demark..."

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint is not installed."
    echo "📦 Install via Homebrew: brew install swiftlint"
    echo "📦 Or via Mint: mint install realm/SwiftLint"
    exit 1
fi

# Change to the project root directory
cd "$(dirname "$0")/.."

# Display SwiftLint version
echo "📋 SwiftLint version: $(swiftlint version)"

# Run SwiftLint
if [ "$1" = "--fix" ] || [ "$1" = "--autocorrect" ]; then
    echo "🔧 Running SwiftLint with autocorrect..."
    swiftlint --fix --config .swiftlint.yml
    exit_code=$?
else
    echo "🔍 Running SwiftLint lint..."
    swiftlint lint --config .swiftlint.yml
    exit_code=$?
fi

# Check result
if [ $exit_code -eq 0 ]; then
    echo "✅ SwiftLint passed!"
else
    echo "❌ SwiftLint found issues (exit code: $exit_code)"
    echo "💡 Tip: Run './scripts/swiftlint.sh --fix' to auto-correct some issues"
fi

exit $exit_code