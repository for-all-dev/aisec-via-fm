.PHONY: paper dev build

paper:
	cd paper && typst compile main.typ main.pdf

dev:
	cd website && pnpm run dev

build:
	cd website && pnpm run build
