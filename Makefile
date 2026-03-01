.PHONY: install build dev clean help

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies and build
	npm install
	npm run build

build: ## Build TypeScript source
	npm run build

dev: ## Watch mode for development
	npm run dev

clean: ## Remove build artifacts
	npm run clean
	rm -rf node_modules

.DEFAULT_GOAL := help
