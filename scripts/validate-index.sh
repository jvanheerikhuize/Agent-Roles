#!/usr/bin/env bash
# validate-index.sh -- Consistency checks for index.yaml and the roles/ tree.
# Exits non-zero on any mismatch so CI and pre-commit hooks can gate merges.
#
# Checks:
#   1. Every role directory on disk has an index.yaml entry.
#   2. Every index.yaml entry points at files that exist.
#   3. The README role-count badge matches the actual count.
#   4. Each role README agrees with its role.md frontmatter on version/category.
#
# The crisis-resources freshness check moved to agent-personas together with
# config/crisis-resources.yaml and the personas that use it.

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INDEX="$BASE_DIR/index.yaml"
README="$BASE_DIR/README.md"
ROLES_DIR="$BASE_DIR/roles"

for arg in "$@"; do
    case "$arg" in
        --help) echo "Usage: validate-index.sh"; exit 0 ;;
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
        /^      prompt:/ || /^      source:/ || /^      semanticode:/ || /^      variant:/ {
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
# 4. Role README agrees with role.md frontmatter
# ---------------------------------------------------------------------------
# index.yaml and dist/ are generated from role.md, and CI gates that with a
# git-diff check -- so those three can never disagree. The per-role README is
# still hand-written, which leaves exactly one unguarded copy of the version
# and category. That gap is not hypothetical: the v2 migration took its
# versions from the stale index.yaml, and spray shipped on main with a README
# and prompt body saying 2.0 against frontmatter saying 1.0.
#
# Every other check in this file is existence-shaped ("the referenced file is
# present"). This one is agreement-shaped, which is the only kind that catches
# a hand-written copy going stale. It becomes redundant the day the README
# header is generated too (see ROADMAP.md).
echo "==> README metadata agreement"
while IFS= read -r role_md; do
    dir="$(dirname "$role_md")"
    readme="$dir/README.md"
    slug="$(basename "$dir")"
    [[ -f "$readme" ]] || continue

    # Frontmatter is the source of truth; read only the leading --- block.
    fm_version=$(awk '/^---$/{n++; next} n==1 && /^version:/ {gsub(/^version: *"?/,""); gsub(/".*/,""); print; exit}' "$role_md")
    fm_category=$(awk '/^---$/{n++; next} n==1 && /^category:/ {gsub(/^category: *"?/,""); gsub(/".*/,""); print; exit}' "$role_md")

    header=$(grep -m1 '\*\*Version:\*\*' "$readme" || true)
    [[ -n "$header" ]] || continue

    rd_version=$(sed -nE 's/.*\*\*Version:\*\* *([0-9]+(\.[0-9]+)*).*/\1/p' <<<"$header")
    rd_category=$(sed -nE 's/.*\*\*Category:\*\* *([A-Za-z-]+).*/\1/p' <<<"$header")

    if [[ -n "$rd_version" && "$rd_version" != "$fm_version" ]]; then
        fail "$slug: README says version $rd_version, role.md frontmatter says $fm_version"
    fi
    if [[ -n "$rd_category" && "${rd_category,,}" != "${fm_category,,}" ]]; then
        fail "$slug: README says category '$rd_category', role.md frontmatter says '$fm_category'"
    fi
done < <(find "$ROLES_DIR" -mindepth 3 -maxdepth 3 -name role.md | sort)


echo
if [[ $errors -eq 0 ]]; then
    echo "OK — all checks passed."
    exit 0
else
    echo "FAILED — $errors error(s)." >&2
    exit 1
fi
