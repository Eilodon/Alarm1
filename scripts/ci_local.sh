#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

status=0
step() { echo -e "\n=== $* ==="; }

step "Flutter version"
flutter --version || true

step "Pub get"
flutter pub get

step "Analyze (non-blocking)"
if ! flutter analyze; then
  echo "Analyze reported issues (continuing)"
fi

step "Run tests"
set +e
flutter test -j 1
t_status=$?
set -e

step "Build web"
set +e
flutter build web --release --no-wasm-dry-run
b_status=$?
set -e

if [ $t_status -ne 0 ]; then
  echo "Tests failed with exit code $t_status"
  status=$t_status
fi
if [ $b_status -ne 0 ]; then
  echo "Build failed with exit code $b_status"
  # Only set status to build failure if tests passed
  if [ $status -eq 0 ]; then status=$b_status; fi
fi

exit $status
