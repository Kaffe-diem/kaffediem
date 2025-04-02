-include .env

default: dev

dev: pb_types
	docker-compose up --watch

build: pb_types
	npx vite build

pb_types:
	@npx pocketbase-typegen --url $(PUBLIC_PB_HOST) --email $(PB_ADMIN_EMAIL) --password $(PB_ADMIN_PASSWORD) --out ./src/lib/pocketbase/index.d.ts

format:
	npx prettier --write .

lint:
	npx svelte-kit sync
	npx svelte-check --tsconfig ./tsconfig.json
	npx eslint src
	npx prettier --check .
