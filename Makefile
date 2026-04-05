COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo dev)

.PHONY: dev paper build

sync-texts:
	cp paper/common/tooltips.json website/lib/tooltips.json

dev: sync-texts
	cd paper && typst watch --input commit=$(COMMIT) main.typ main.pdf &
	cd website && bun run dev

paper:
	cd paper && typst compile --input commit=$(COMMIT) main.typ main.pdf

build: sync-texts
	cd website && bun run build
