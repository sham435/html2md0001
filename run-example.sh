#!/bin/bash

# HTML2MD Example App Runner
# This script builds and runs the HTML2MD example application

set -e

echo "🚀 Building and running HTML2MD Example App..."
echo

# Change to the Example directory
cd "$(dirname "$0")/Example"

# Build and run the example
swift run HTML2MDExample

echo
echo "✨ Thanks for trying HTML2MD!"