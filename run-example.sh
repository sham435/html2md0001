#!/bin/bash

# Demark Example App Runner
# This script builds and runs the Demark example application

set -e

echo "🚀 Building and running Demark Example App..."
echo

# Change to the Example directory
cd "$(dirname "$0")/Example"

# Build and run the example
swift run DemarkExample

echo
echo "✨ Thanks for trying Demark!"