.PHONY: install run health clean help

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

install: ## Install quickserve to ~/.quickserve
	bash install.sh

run: ## Start the dev server on port 3000
	node bin/quickserve serve

health: ## Check health of running instance
	node bin/quickserve health

clean: ## Remove installation
	rm -rf ~/.quickserve ~/.local/bin/quickserve

.DEFAULT_GOAL := help
