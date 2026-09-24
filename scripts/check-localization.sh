#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATALOG="$SCRIPT_DIR/../FineTune/Localizable.xcstrings"

if [[ ! -f "$CATALOG" ]]; then
    echo "Localization catalog not found: $CATALOG" >&2
    exit 1
fi

missing_keys="$(jq -r '
    .strings
    | to_entries[]
    | select(.value.localizations["zh-Hans"] == null
        or .value.localizations["zh-Hans"].stringUnit.state != "translated")
    | select(.key | test("^[A-Za-z][A-Za-z ]+$"))
    | select(.key != "FineTune" and .key != "EQ" and .key != "Hz")
    | .key
' "$CATALOG")"

if [[ -n "$missing_keys" ]]; then
    echo "Untranslated Simplified Chinese keys:" >&2
    printf '%s\n' "$missing_keys" >&2
    exit 1
fi

echo "Simplified Chinese localization catalog is complete."
