#!/usr/bin/env sh

set -e

echo "Building project..."

# Build Elm
echo -e "\033[5;33mCompiling Elm... \033[0m"
elm make src/Main.elm --output=dist/Main.js --optimize

# Build CSS
echo -e  "\033[5;33mBuilding CSS... \033[0m"
tailwindcss -i ./src/styles.css -o ./dist/styles.css --minify