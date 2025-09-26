export
-include .env.development.example
-include .env.development
-include .env

default: dev

dev: .env.development sync pb_up pb_types svelte_types _hooks
	docker compose watch

build: pb_types
	PUBLIC_PB_HOST=$(PUBLIC_PB_HOST) npx vite build

pb_types:
	docker compose run --rm tools sh -lc '\
		if [ -f "./pb_data/data.db" ]; then \
			bunx pocketbase-typegen --db ./pb_data/data.db --out ./src/lib/pocketbase/index.d.ts; \
		elif [ -n "$$PB_ADMIN_EMAIL" ] && [ -n "$$PB_ADMIN_PASSWORD" ]; then \
			bunx pocketbase-typegen --url http://pb:8081 --email "$$PB_ADMIN_EMAIL" --password "$$PB_ADMIN_PASSWORD" --out ./src/lib/pocketbase/index.d.ts; \
		fi'

# ordinarily run as part of NPM pipeline.
# Run manually, since we're not relying on that
# https://svelte.dev/docs/kit/cli
svelte_types:
	@docker compose run --rm tools bunx svelte-kit sync

.env.development: .env.development.example
	@cp .env.development.example .env.development

sync:
	docker compose run --rm tools sh -lc "bun install --frozen-lockfile && bun scripts/sync-db.js --host=$$PUBLIC_PB_HOST_PROD --githubRepo=$${GITHUB_REPO:-Kaffe-diem/kaffediem} --githubReleaseTag=$${GITHUB_RELEASE_TAG:-latest}"

pb_up:
	docker compose up --wait pb

format:
	@docker compose run --rm tools bunx prettier --write .

lint:
	docker compose run --rm tools sh -c "bunx svelte-kit sync && bunx svelte-check --tsconfig ./tsconfig.json && bunx eslint src && bunx prettier --check ."

clean:
	-docker compose down -v --remove-orphans
	-rm -rf ./pb_data

_hooks: .git/.hooks_installed

.git/.hooks_installed:
	@git config core.hooksPath .githooks
	@chmod +x .githooks/* || true
	@touch $@