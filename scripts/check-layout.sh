#!/usr/bin/env bash
set -euo pipefail

missing=0
for dir in modules/vpc modules/eks modules/observability; do
  if [ ! -d "$dir" ]; then
    echo "Missing directory: $dir"
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

echo "Layout OK"
