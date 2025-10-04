export
-include .env.development.example
-include .env.development
-include .env

default: dev

dev: .env.development
	docker compose watch

build:
	PUBLIC_BACKEND_URL=$(PUBLIC_BACKEND_URL) npx vite build

# ordinarily run as part of NPM pipeline.
# Run manually, since we're not relying on that
# https://svelte.dev/docs/kit/cli
svelte_types:
	@docker compose run --rm tools bunx svelte-kit sync

logs-be:
	   docker-compose logs -f backend

.env.development: .env.development.example
	@cp .env.development.example .env.development

format:
	@docker compose run --rm tools bunx prettier --write .

lint:
	docker compose run --rm tools sh -c "bunx svelte-kit sync && bunx svelte-check --tsconfig ./tsconfig.json && bunx eslint src && bunx prettier --check ."

clean:
	-docker volume rm kaffediem_backend_build kaffediem_backend_deps
	-docker compose down -v --remove-orphans
	-rm -rf ./kaffebase/_build
	-rm -rf ./kaffebase/deps
	-rm -rf ./kaffebase/priv/static
	-rm -rf ./kaffebase/priv/cache
	-rm -rf ./kaffebase/priv/log
	-rm -rf ./kaffebase/priv/test
	-rm -rf ./kaffebase/priv/test_coverage

_hooks: .git/.hooks_installed

.git/.hooks_installed:
	@git config core.hooksPath .githooks
	@chmod +x .githooks/* || true
	@touch $@

backend_migrate:
	docker compose run --rm backend mix ecto.migrate
