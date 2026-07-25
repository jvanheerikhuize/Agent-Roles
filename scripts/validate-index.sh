#!/usr/bin/env bash
# validate-index.sh -- Consistency checks for index.yaml and the roles/ tree.
# Exits non-zero on any mismatch so CI and pre-commit hooks can gate merges.
#
# Checks:
#   1. Every role directory on disk has an index.yaml entry.
#   2. Every index.yaml entry points at files that exist.
#   3. The README role-count badge matches the actual count.
#   4. index.yaml, prompt.md and README.md agree on each role's version and
#      category (they store it three times; nothing else catches drift).
#   5. (--check-crisis) config/crisis-resources.yaml entries are verified within
#      the last 12 months.

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INDEX="$BASE_DIR/index.yaml"
README="$BASE_DIR/README.md"
ROLES_DIR="$BASE_DIR/roles"
CRISIS_CFG="$BASE_DIR/config/crisis-resources.yaml"

CHECK_CRISIS=false
for arg in "$@"; do
    case "$arg" in
        --check-crisis) CHECK_CRISIS=true ;;
        --help) cat <<EOF
Usage: validate-index.sh [--check-crisis]

  --check-crisis   Also verify crisis-resources.yaml freshness (<= 12 months).
EOF
        exit 0 ;;
    esac
done

errors=0
fail() { echo "FAIL: $*" >&2; errors=$((errors + 1)); }
info() { echo "  $*"; }

[[ -f "$INDEX" ]]    || { echo "missing: $INDEX" >&2; exit 2; }
[[ -d "$ROLES_DIR" ]] || { echo "missing: $ROLES_DIR" >&2; exit 2; }

# ---------------------------------------------------------------------------
# 1. Role directories vs. index entries
# ---------------------------------------------------------------------------
echo "==> Role inventory"
mapfile -t disk_roles < <(
    find "$ROLES_DIR" -mindepth 2 -maxdepth 2 -type d -printf '%P\n' | sort
)
mapfile -t index_ids < <(
    awk '/^  - id:/ { gsub(/^  - id: */, ""); print }' "$INDEX" | sort
)

info "roles on disk: ${#disk_roles[@]}"
info "index entries: ${#index_ids[@]}"

# Cross-check disk slugs against index slugs
mapfile -t index_slugs < <(
    awk '/^    slug:/ { gsub(/^    slug: */, ""); print }' "$INDEX" | sort
)
mapfile -t disk_slugs < <(printf '%s\n' "${disk_roles[@]}" | awk -F/ '{print $2}' | sort)

for slug in "${disk_slugs[@]}"; do
    if ! printf '%s\n' "${index_slugs[@]}" | grep -qx "$slug"; then
        fail "role '$slug' exists on disk but has no index.yaml entry"
    fi
done
for slug in "${index_slugs[@]}"; do
    if ! printf '%s\n' "${disk_slugs[@]}" | grep -qx "$slug"; then
        fail "index.yaml references slug '$slug' but no directory roles/*/$slug exists"
    fi
done

# ---------------------------------------------------------------------------
# 2. Prompt files referenced by index exist on disk
# ---------------------------------------------------------------------------
echo "==> Prompt file references"
while IFS= read -r rel; do
    [[ -z "$rel" || "$rel" == "null" ]] && continue
    if [[ ! -f "$BASE_DIR/$rel" ]]; then
        fail "index.yaml references missing file: $rel"
    fi
done < <(
    awk '
        /^      prompt:/ || /^      semanticode:/ || /^      variant:/ {
            val = $0
            sub(/^      [a-z]+: */, "", val)
            gsub(/"/, "", val)
            print val
        }
    ' "$INDEX"
)

# ---------------------------------------------------------------------------
# 3. README badge count
# ---------------------------------------------------------------------------
echo "==> README badge"
if [[ -f "$README" ]]; then
    badge_count=$(grep -oE 'roles-[0-9]+' "$README" | head -n1 | grep -oE '[0-9]+' || true)
    if [[ -n "$badge_count" ]]; then
        if [[ "$badge_count" != "${#index_ids[@]}" ]]; then
            fail "README badge says $badge_count roles, index.yaml has ${#index_ids[@]}"
        else
            info "badge OK ($badge_count)"
        fi
    else
        info "no role-count badge found (skipping)"
    fi
fi

# ---------------------------------------------------------------------------
# 4. Metadata agreement across index.yaml, prompt.md and README.md
# ---------------------------------------------------------------------------
# Role version and category live in three places today. Nothing regenerates
# them, so they drift silently -- and every other check here is existence-
# shaped ("the referenced file is present"), which cannot catch disagreement.
# This check is agreement-shaped. It becomes redundant once role.md frontmatter
# is the single source of truth (see ROADMAP.md phase 2); until then it is the
# gate that keeps the three copies honest.
echo "==> Metadata agreement"
while IFS='|' read -r id category version prompt_rel; do
    [[ -z "$id" ]] && continue
    role_dir="$BASE_DIR/$(dirname "$prompt_rel")"

    # Version as declared by the prompt and the role README, if they declare one.
    for f in prompt.md README.md; do
        path="$role_dir/$f"
        [[ -f "$path" ]] || continue
        declared=$(grep -oE '\*\*Version:\*\*[[:space:]]*[0-9]+(\.[0-9]+)*' "$path" |
                   head -n1 | grep -oE '[0-9]+(\.[0-9]+)*' || true)
        [[ -z "$declared" ]] && continue
        if [[ "$declared" != "$version" ]]; then
            fail "$id: $f says version $declared, index.yaml says $version"
        fi
    done

    # Category is repeated in the role README header.
    readme="$role_dir/README.md"
    if [[ -f "$readme" ]]; then
        rc=$(grep -oE '\*\*Category:\*\*[[:space:]]*[A-Za-z-]+' "$readme" |
             head -n1 | sed -E 's/.*\*\*Category:\*\*[[:space:]]*//' || true)
        if [[ -n "$rc" ]] && [[ "${rc,,}" != "${category,,}" ]]; then
            fail "$id: README.md says category '$rc', index.yaml says '$category'"
        fi
    fi
done < <(
    awk '
        /^  - id:/ {
            if (id != "") print id "|" cat "|" ver "|" prompt
            id = $0; sub(/^  - id: */, "", id)
            cat = ""; ver = ""; prompt = ""
        }
        /^    category:/ { cat = $0; sub(/^    category: */, "", cat); gsub(/"/, "", cat) }
        /^    version:/  { ver = $0; sub(/^    version: */, "", ver);  gsub(/"/, "", ver) }
        /^      prompt:/ { prompt = $0; sub(/^      prompt: */, "", prompt); gsub(/"/, "", prompt) }
        END { if (id != "") print id "|" cat "|" ver "|" prompt }
    ' "$INDEX"
)

# ---------------------------------------------------------------------------
# 5. Crisis resources freshness (opt-in)
# ---------------------------------------------------------------------------
if $CHECK_CRISIS; then
    echo "==> Crisis resources freshness"
    if [[ ! -f "$CRISIS_CFG" ]]; then
        fail "missing $CRISIS_CFG"
    else
        cutoff=$(date -d '12 months ago' +%Y-%m-%d 2>/dev/null || \
                 date -v-12m +%Y-%m-%d)  # BSD date fallback
        while IFS= read -r checked; do
            if [[ "$checked" < "$cutoff" ]]; then
                fail "crisis-resources.yaml entry last checked $checked (cutoff $cutoff)"
            fi
        done < <(
            awk '/source_checked:/ {
                gsub(/.*source_checked: *"?/, "")
                gsub(/".*/, "")
                print
            }' "$CRISIS_CFG"
        )
    fi
fi

echo
if [[ $errors -eq 0 ]]; then
    echo "OK — all checks passed."
    exit 0
else
    echo "FAILED — $errors error(s)." >&2
    exit 1
fi
