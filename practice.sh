#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR"
APP_DIR="$ROOT_DIR/app"

usage() {
  cat <<'EOF'
Usage: ./practice.sh <command> [args]

Commands:
  setup           Install dependencies in app/
  dev [args]      Run Next.js dev server (for local use)
  build           Build the Next.js app
  start           Start the Next.js production server
  lint [args]     Run ESLint
  typecheck       Run TypeScript type checks (no emit)
  clean           Remove build artifacts and node_modules in app/
  help            Show this help

Examples:
  ./practice.sh setup
  ./practice.sh dev -- --port 3001
  ./practice.sh build && ./practice.sh start
  ./practice.sh lint -- --fix
  ./practice.sh typecheck
  ./practice.sh clean && ./practice.sh setup
EOF
}

ensure_app_dir() {
  if [[ ! -d "$APP_DIR" ]]; then
    echo "Error: expected Next.js app at $APP_DIR" >&2
    exit 1
  fi
}

run_in_app() {
  (cd "$APP_DIR" && "$@")
}

COMMAND="${1:-help}"
if [[ $# -gt 0 ]]; then
  shift || true
fi

ensure_app_dir

case "$COMMAND" in
  setup)
    if [[ -f "$APP_DIR/package-lock.json" ]]; then
      run_in_app npm ci
    else
      run_in_app npm install
    fi
    ;;
  dev)
    # Note: Long-lived; prefer running manually in local terminals
    run_in_app npm run dev -- "$@"
    ;;
  build)
    run_in_app npm run build
    ;;
  start)
    run_in_app npm run start
    ;;
  lint)
    run_in_app npm run lint -- "$@"
    ;;
  typecheck)
    run_in_app npx --yes tsc --noEmit
    ;;
  clean)
    rm -rf "$APP_DIR/node_modules" "$APP_DIR/.next" "$APP_DIR/.turbo"
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    echo "Unknown command: $COMMAND" >&2
    echo
    usage
    exit 2
    ;;
esac
