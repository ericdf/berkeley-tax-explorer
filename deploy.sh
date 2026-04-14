#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: ./deploy.sh \"describe what changed\""
  exit 1
fi

git add index.html specification.md README.md deploy.sh
git commit -m "$1"
git push

echo ""
echo "Pushed. GitHub Actions will publish to Pages in ~30 seconds."
echo "https://ericdf.github.io/berkeley-tax-explorer/"
