.PHONY: deps analyze test build-web ci

deps:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test -j 1

build-web:
	flutter build web --release --no-wasm-dry-run

ci:
	scripts/ci_local.sh
