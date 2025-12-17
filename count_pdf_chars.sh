#!/usr/bin/env bash
set -euo pipefail

pdf="${1:-out/main.pdf}"

if [ ! -f "$pdf" ]; then
  echo "ERROR: file not found: $pdf" >&2
  exit 2
fi

# Check if pdftotext is available
if ! command -v pdftotext >/dev/null 2>&1; then
  echo "ERROR: pdftotext not found. Please install poppler-utils." >&2
  exit 3
fi

# Extract text and count characters
count=$(pdftotext "$pdf" - | wc -m)
echo "CHAR_COUNT: $count"
echo "Extracted $count characters from '$pdf'"

