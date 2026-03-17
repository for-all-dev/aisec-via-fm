.PHONY: paper dev build

paper:
	cd paper && typst compile \
		--input commit=$(shell git rev-parse --short HEAD 2>/dev/null || echo dev) \
		main.typ main.pdf

dev:
	cd website && pnpm run dev

build:
	cd website && pnpm run build
