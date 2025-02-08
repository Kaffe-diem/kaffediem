-include .env

default: dev

dev: pb_types dependencies
	bun run vite dev

build: pb_types dependencies
	bun run vite build

db: dependencies
	docker compose up

pb_types: dependencies
	@bun run pocketbase-typegen --url $(PUBLIC_PB_HOST) --email $(PB_ADMIN_EMAIL) --password $(PB_ADMIN_PASSWORD) --out ./src/lib/pocketbase/index.d.ts

format: dependencies
	bun run prettier --write .

lint: dependencies
	bun run prettier --check .
	bun run svelte-kit sync
	bun run svelte-check --tsconfig ./tsconfig.json
	bun run eslint src

dependencies:
	bun install
