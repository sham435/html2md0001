#!/bin/bash

# Combined linting script for HTML2MD
# Runs both SwiftLint and SwiftFormat checks

set -e

echo "🧹 Running code quality checks for HTML2MD..."
echo

# Change to the project root directory
cd "$(dirname "$0")/.."

# Track overall success
overall_success=true

# Run SwiftFormat check
echo "1️⃣ Checking code formatting with SwiftFormat..."
if ./scripts/swiftformat.sh --check; then
    echo "✅ SwiftFormat check passed"
else
    echo "❌ SwiftFormat check failed"
    overall_success=false
fi

echo

# Run SwiftLint
echo "2️⃣ Checking code quality with SwiftLint..."
if ./scripts/swiftlint.sh; then
    echo "✅ SwiftLint check passed"
else
    echo "❌ SwiftLint check failed"
    overall_success=false
fi

echo

# Final result
if [ "$overall_success" = true ]; then
    echo "🎉 All code quality checks passed!"
    exit 0
else
    echo "💥 Some code quality checks failed"
    echo
    echo "🔧 To fix formatting issues: ./scripts/swiftformat.sh"
    echo "🔧 To fix some lint issues: ./scripts/swiftlint.sh --fix"
    exit 1
fi