#!/usr/bin/env sh

set -e

cleanup() {
    trap - INT TERM
    echo "Stopping watchers..."
    kill -- -$$
}

trap cleanup INT TERM

PORT=4443

# Parse flags
while [ $# -gt 0 ]; do
    case $1 in
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-p|--port PORT]"
            exit 1
            ;;
    esac
done

echo "Starting development watchers..."

find src/ -name "*.elm" | entr -r elm make src/Main.elm --output=dist/Main.js &
find src/ -name '*.css' -o -name '*.elm' | entr -r tailwindcss -i ./src/styles.css -o ./dist/styles.css &

echo "listen on port: ${PORT}"
busybox httpd -f -p "${PORT}" &

wait