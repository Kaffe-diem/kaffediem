export
-include .env.development
-include .env

default: dev

dev: sync pb_up pb_types svelte_types
	docker compose watch

build: pb_types
	PUBLIC_PB_HOST=$(PUBLIC_PB_HOST) npx vite build

pb_types:
	docker compose run --rm tools \
		npx pocketbase-typegen \
			--url http://pb:8081 \
			--email $$PB_ADMIN_EMAIL \
			--password $$PB_ADMIN_PASSWORD \
			--out ./src/lib/pocketbase/index.d.ts

# ordinarily run as part of NPM pipeline.
# Run manually, since we're not relying on that
# https://svelte.dev/docs/kit/cli
svelte_types:
	@docker compose run --rm tools npx svelte-kit sync

sync:
	@docker compose run --rm tools sh -lc "npm ci && node scripts/sync-db.js --host=$$PUBLIC_PB_HOST_PROD --email=$$PB_ADMIN_EMAIL --password=$$PB_ADMIN_PASSWORD"

pb_up:
	docker compose up --wait pb

format:
	npx prettier --write .

lint:
	npx svelte-kit sync
	npx svelte-check --tsconfig ./tsconfig.json
	npx eslint src
	npx prettier --check .
