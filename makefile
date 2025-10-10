export
-include .env.development.example
-include .env.development
-include .env

default: dev

DB_FILE := kaffebase/kaffebase_dev.db

dev: .env.development deps migrate-up svelte_types
	docker compose watch app backend

dev-no-cache: .env.development clean deps migrate-up svelte_types
	@docker compose build --pull --no-cache backend app tools
	@echo "🚀 Starting dev stack (no cache)..."
	docker compose watch app backend

logs:
	docker compose logs -f backend app

deps: ensure-dev-db
	docker compose run --rm backend mix deps.get
	docker compose run --rm tools bun install --frozen-lockfile

migrate-up: ensure-dev-db
	@docker compose run --rm backend mix ecto.migrate

migrate-down:
	@docker compose run --rm backend mix ecto.rollback

# run the prod configuration locally
# Make sure to run with the correct docker-compose file
prod: migrate-up deps svelte_types
	@docker-compose -f docker-compose.yml up -d backend app
	@docker-compose -f docker-compose.yml logs -f backend app

# sync the database from github release
ensure-dev-db:
	@if [ -d "$(DB_FILE)" ]; then \
		echo "⚠️  Removing directory placeholder at $(DB_FILE)"; \
		rm -rf "$(DB_FILE)"; \
	fi
	@if [ ! -f "$(DB_FILE)" ]; then \
		docker compose run --rm tools sh -lc ' \
		REPO=$${GITHUB_REPO:-Kaffe-diem/kaffediem}; \
		TAG=$${GITHUB_RELEASE_TAG:-latest}; \
		echo "📦 Fetching release from $$REPO @ $$TAG..."; \
		if [ "$$TAG" = "latest" ]; then \
			API_URL="https://api.github.com/repos/$$REPO/releases/latest"; \
		else \
			API_URL="https://api.github.com/repos/$$REPO/releases/tags/$$TAG"; \
		fi; \
		ZIP_URL=$$(wget -qO- --header="Accept: application/vnd.github+json" --header="User-Agent: kaffediem-sync-db" "$$API_URL" | grep -o "\"browser_download_url\": *\"[^\"]*\.zip\"" | head -1 | cut -d\" -f4); \
		if [ -z "$$ZIP_URL" ]; then \
			echo "❌ No .zip asset found in release"; \
			exit 1; \
		fi; \
		echo "📥 Downloading from $$ZIP_URL..."; \
		wget -q -O /tmp/backup.zip "$$ZIP_URL"; \
		echo "📦 Extracting..."; \
		unzip -o /tmp/backup.zip -d /tmp/backup_extract; \
		DB_FILE=$$(find /tmp/backup_extract -name "data.db" | head -1); \
		if [ -z "$$DB_FILE" ]; then \
			echo "❌ No .db file found in archive"; \
			rm -rf /tmp/backup.zip /tmp/backup_extract; \
			exit 1; \
		fi; \
		echo "✅ Installing database..."; \
		cp "$$DB_FILE" kaffebase/kaffebase_dev.db; \
		rm -rf /tmp/backup.zip /tmp/backup_extract; \
		echo "✅ Database sync complete!"; \
	'; \
	else \
		echo "ℹ️  Using existing dev database at $(DB_FILE)"; \
	fi


# ordinarily run as part of NPM pipeline.
# Run manually, since we're not relying on that
# https://svelte.dev/docs/kit/cli
svelte_types: deps
	@docker compose run --rm tools bunx svelte-kit sync

.env.development: .env.development.example
	@cp .env.development.example .env.development

format: deps
	@docker compose run --rm tools bunx prettier --write . & \
	docker compose run --rm backend mix format & \
	wait

lint: deps
	docker compose run --rm tools sh -c "bunx svelte-kit sync && bunx svelte-check --tsconfig ./tsconfig.json && bunx eslint src && bunx prettier --check ."

clean:
	@echo "🧹 Stopping containers and clearing build artifacts..."
	-@docker compose down -v --remove-orphans
	-@docker compose rm -sfv
	-@rm -rf node_modules
	-@rm -rf .svelte-kit
	-@rm -rf ./kaffebase/_build
	-@rm -rf ./kaffebase/deps
	-@rm -rf ./kaffebase/priv/static
	-@rm -rf ./kaffebase/priv/cache
	-@rm -rf ./kaffebase/priv/log
	-@rm -rf ./kaffebase/priv/test
	-@rm -rf ./kaffebase/priv/test_coverage
	-@rm -rf ./kaffebase/kaffebase_dev.db*
	@echo "✅ Clean slate ready."
