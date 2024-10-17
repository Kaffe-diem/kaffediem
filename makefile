default: dev

dev: sync_schema
	@npm run dev

build:
	@npm run build

sync_schema:
	@echo Reading schema from $(PB_HOST)
	@npx pocketbase-typegen --url $(PB_HOST) --email $(PB_USER) --password $(PB_PASS) --out ./src/pb.d.ts