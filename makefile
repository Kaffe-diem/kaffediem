export
-include .env.development

.PHONY: default dev build pb_types svelte_types sync format lint clean

default: dev

dev: sync pb_types svelte_types
	docker-compose up --watch

build: pb_types
	(cd webapp && PUBLIC_PB_HOST=$(PUBLIC_PB_HOST_PROD) npx vite build)

pb_types:
	npx pocketbase-typegen \
		--url $(PUBLIC_PB_HOST_PROD) \
		--email $(PB_ADMIN_EMAIL) \
		--password $(PB_ADMIN_PASSWORD) \
		--out ./webapp/src/lib/pocketbase/index.d.ts

# ordinarily run as part of NPM pipeline.
# Run manually, since we're not relying on that
# https://svelte.dev/docs/kit/cli
svelte_types:
	@(cd webapp && npx svelte-kit sync)

sync:
	@node scripts/sync-db.js --host=$(PUBLIC_PB_HOST_PROD) --email=$(PB_ADMIN_EMAIL) --password=$(PB_ADMIN_PASSWORD)

format:
	npx prettier --write .

lint:
	(cd webapp && \
		npx svelte-kit sync && \
		npx svelte-check --tsconfig ./tsconfig.json && \
		npx eslint .)
	npx prettier --check .

clean:
	docker-compose down --volumes --remove-orphans --rmi all
	rm -f webapp/src/lib/pocketbase/index.d.ts
	rm -rf webapp/.svelte-kit webapp/build


