export
-include .env.development

default: dev

dev: sync pb_types svelte_types
	docker-compose up --watch

build: pb_types
	PUBLIC_PB_HOST=$(PUBLIC_PB_HOST_PROD) npx vite build --mode production

pb_types:
	@npx pocketbase-typegen --url $(PUBLIC_PB_HOST_PROD) --email $(PB_ADMIN_EMAIL) --password $(PB_ADMIN_PASSWORD) --out ./src/lib/pocketbase/index.d.ts

# ordinarily run as part of NPM pipeline.
# Run manually, since we're not relying on that
# https://svelte.dev/docs/kit/cli
svelte_types:
	@npx svelte-kit sync

sync:
	@node scripts/sync-db.js --host=$(PUBLIC_PB_HOST_PROD) --email=$(PB_ADMIN_EMAIL) --password=$(PB_ADMIN_PASSWORD)

format:
	npx prettier --write .

lint:
	npx svelte-kit sync
	npx svelte-check --tsconfig ./tsconfig.json
	npx eslint src
	npx prettier --check .
