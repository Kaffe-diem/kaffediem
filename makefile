default: dev

dev: pb_types
	@npm run dev

build: pb_types
	@npm run build

db:
	@docker compose up

pb_types:
	@echo Reading schema from $(PUBLIC_PB_HOST)
	@npx --yes pocketbase-typegen@1.2.1 --url $(PUBLIC_PB_HOST) --email $(PB_ADMIN_EMAIL) --password $(PB_ADMIN_PASSWORD) --out ./src/lib/pocketbase/index.d.ts
