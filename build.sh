#!/usr/bin/env sh

set -e

MODE="dev"
PORT=4443

# Parse arguments
while [ $# -gt 0 ]; do
    case $1 in
        dev|build)
            MODE="$1"
            shift
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [dev|build] [-p|--port PORT]"
            echo ""
            echo "Commands:"
            echo "  dev    Start development watchers (default)"
            echo "  build  Build for production"
            echo ""
            echo "Options:"
            echo "  -p, --port PORT  Port for dev server (default: 4443)"
            exit 1
            ;;
    esac
done

if [ "$MODE" = "build" ]; then
    # Build mode
    echo "Building project..."
    
    echo -e "\033[5;33mCompiling Elm... \033[0m"
    elm make src/Main.elm --output=dist/Main.js --optimize
    
    echo -e "\033[5;33mBuilding CSS... \033[0m"
    tailwindcss -i ./src/styles.css -o ./dist/styles.css --minify
    
    echo "Build complete!"
else
    # Dev mode
    cleanup() {
        trap - INT TERM
        echo "Stopping watchers..."
        kill -- -$$
    }
    
    trap cleanup INT TERM
    
    echo "Starting development watchers..."
    
    find src/ -name "*.elm" | entr -r elm make src/Main.elm --output=dist/Main.js &
    find src/ -name '*.css' -o -name '*.elm' | entr -r tailwindcss -i ./src/styles.css -o ./dist/styles.css &
    
    echo "Listen on port: ${PORT}"
    busybox httpd -f -p "${PORT}" &
    
    wait
fi