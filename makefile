default: dev

dev: sync_schema
	@npm run dev

build:
	@npm run build

db:
	@docker compose up

sync_schema:
	@echo Reading schema from $(PUBLIC_PB_HOST)
	@npx pocketbase-typegen --url $(PUBLIC_PB_HOST) --email $(PB_ADMIN_EMAIL) --password $(PB_ADMIN_PASSWORD) --out ./src/lib/pb-types.d.ts
