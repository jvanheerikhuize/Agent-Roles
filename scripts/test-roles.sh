#!/usr/bin/env bash
# test-roles.sh -- Structural smoke tests for every role in the library.
# Runs without LLM API keys; checks invariants that do not require execution.
#
# Checks per role:
#   1. The built prompt (dist/prompts/<slug>.md) exists and is non-empty.
#   2. The prompt does not exceed a soft size budget.
#   3. If a semanticode variant is declared in index.yaml, it exists and is
#      shorter than the canonical prompt (legacy check; v2 entries declare none).
#   4. Health / minors-involved roles contain an explicit safety-notes marker.
#   5. No hardcoded crisis numbers outside config/crisis-resources.yaml.
#
# An optional --llm-smoke mode is scaffolded but disabled by default — it
# requires an OPENAI_API_KEY or ANTHROPIC_API_KEY and is intended for CI runs
# that opt in explicitly.

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INDEX="$BASE_DIR/index.yaml"

# Soft ceiling -- large health/utility prompts legitimately exceed 24k; the
# test is meant to catch runaway growth, not legislate exact length.
MAX_PROMPT_CHARS=${MAX_PROMPT_CHARS:-60000}
# Crisis-number leak check is a WARN by default. Sensitive roles still embed
# example numbers as ballast -- migration to config/crisis-resources.yaml is
# tracked incrementally. Set STRICT_CRISIS=1 to promote to FAIL.
STRICT_CRISIS=${STRICT_CRISIS:-0}

LLM_SMOKE=false
for arg in "$@"; do
    case "$arg" in
        --llm-smoke) LLM_SMOKE=true ;;
        --help) cat <<EOF
Usage: test-roles.sh [--llm-smoke]

  --llm-smoke   Invoke a live LLM round-trip per role. Requires ANTHROPIC_API_KEY
                or OPENAI_API_KEY. Off by default.
EOF
        exit 0 ;;
    esac
done

errors=0
warnings=0
fail() { echo "FAIL [$1]: $2" >&2; errors=$((errors + 1)); }
warn() { echo "WARN [$1]: $2" >&2; warnings=$((warnings + 1)); }
pass() { echo "  ok: $1"; }

# Crisis-number patterns that should live only in config/crisis-resources.yaml.
CRISIS_PATTERNS='\b(988|911|112|113|116 *123|0800-0113|1-800-273-8255)\b'

# Parse the index into per-role tuples: category|prompt|semanticode|minors
parse_role() {
    local slug="$1"
    awk -v target="$slug" '
        function flush() {
            if (matched) {
                print cat "|" p "|" sc "|" minors
                exit
            }
            matched = 0; cat = ""; p = ""; sc = ""; minors = "false"
        }
        /^  - id:/ { flush() }
        /^    slug:/   { if ($NF == target) matched = 1 }
        /^    category:/ { cat = $NF }
        /^      prompt:/      { p = $NF }
        /^      semanticode:/ { sc = $NF }
        /^      minors_involved:/ { minors = $NF }
        END { flush() }
    ' "$INDEX"
}

mapfile -t slugs < <(awk '/^    slug:/ { print $NF }' "$INDEX")

echo "==> Testing ${#slugs[@]} roles"
for slug in "${slugs[@]}"; do
    tuple=$(parse_role "$slug")
    IFS='|' read -r category prompt semanticode minors <<<"$tuple"

    echo "-- $slug ($category)"

    # 1. prompt.md exists and non-empty
    ppath="$BASE_DIR/$prompt"
    if [[ ! -s "$ppath" ]]; then
        fail "$slug" "prompt missing or empty: $prompt"
        continue
    fi
    pass "prompt present"

    # 2. soft size budget
    psize=$(wc -c <"$ppath")
    if (( psize > MAX_PROMPT_CHARS )); then
        fail "$slug" "prompt is $psize chars (> $MAX_PROMPT_CHARS budget)"
    else
        pass "size ${psize}c"
    fi

    # 3. semanticode shorter than canonical (if declared)
    if [[ -n "$semanticode" && "$semanticode" != "null" ]]; then
        spath="$BASE_DIR/$semanticode"
        if [[ ! -s "$spath" ]]; then
            fail "$slug" "semanticode declared but missing: $semanticode"
        else
            ssize=$(wc -c <"$spath")
            if (( ssize >= psize )); then
                fail "$slug" "semanticode ($ssize) not shorter than prompt ($psize)"
            else
                pass "semanticode compression ok"
            fi
        fi
    fi

    # 4. safety marker for sensitive roles
    if [[ "$category" == "health" || "$minors" == "true" ]]; then
        if ! grep -qiE '(crisis|safety|safeguard|helpline|disclaimer)' "$ppath"; then
            fail "$slug" "sensitive role has no crisis/safety marker in prompt"
        else
            pass "safety marker present"
        fi
    fi

    # 5. crisis numbers only in config
    if grep -qE "$CRISIS_PATTERNS" "$ppath"; then
        if [[ "$STRICT_CRISIS" == "1" ]]; then
            fail "$slug" "hardcoded crisis number in prompt — move to config/crisis-resources.yaml"
        else
            warn "$slug" "hardcoded crisis number in prompt — migrate to config/crisis-resources.yaml"
        fi
    fi

    # 6. optional live LLM smoke test
    if $LLM_SMOKE; then
        if [[ -z "${ANTHROPIC_API_KEY:-}${OPENAI_API_KEY:-}" ]]; then
            fail "$slug" "--llm-smoke requested but no API key in env"
        else
            echo "  (llm-smoke: not implemented — wire to your preferred SDK)"
        fi
    fi
done

echo
if [[ $errors -eq 0 ]]; then
    echo "OK — all role smoke tests passed ($warnings warning(s))."
    exit 0
else
    echo "FAILED — $errors error(s), $warnings warning(s)." >&2
    exit 1
fi
