elm_main   = src/Main.elm
elm_output = dist/Main.js
css_input  = src/styles.css
css_output = dist/styles.css

.PHONY: all production dev clean help

all: production

production:
	elm make $(elm_main) --output=$(elm_output) --optimize
	tailwindcss -i $(css_input) -o $(css_output) --minify

dev:
	elm make $(elm_main) --output=$(elm_output)
	tailwindcss -i $(css_input) -o $(css_output)

clean:
	rm -rf dist
	rm -rf elm-stuff

help:
	@echo "Usage: make [target] [OPTIONS]"
	@echo ""
	@echo "Targets:"
	@echo "  dev            Build for development (default)"
	@echo "  production     Build for production"
	@echo "  clean          Remove build artifacts"
	@echo "  help           Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make build"
