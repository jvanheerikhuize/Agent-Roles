#!/usr/bin/env bash
# resolve.sh -- Lightweight role resolver for Agent-Roles
# Parses index.yaml using native bash/awk. Zero external dependencies.
# Usage: ./resolve.sh --list | --id <id> | --category <cat> | --tag <tag> | ...

set -euo pipefail

# Fail fast if required tools are missing (bash 4+ for associative arrays, awk).
for dep in awk; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "Error: required dependency '$dep' not found in PATH" >&2
        exit 127
    fi
done
if (( BASH_VERSINFO[0] < 4 )); then
    echo "Error: bash 4+ required (found $BASH_VERSION)" >&2
    exit 127
fi

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
INDEX="$BASE_DIR/index.yaml"

usage() {
    cat <<'EOF'
Usage: resolve.sh [OPTIONS]

Role queries:
  --list                 List all role IDs
  --id <id>              Print the prompt content for a role by ID
  --id <id> --path       Print the prompt file path instead of content
  --id <id> --semanticode  Print the semanticode variant instead
  --category <category>  List role IDs in a category
  --tag <tag>            List role IDs matching a tag

Composition queries:
  --companions <id>      List companion role IDs for a role
  --chain <id>           Print the full ordered pipeline containing a role
  --group <name>         List all role IDs in a named group
  --workflows            List all defined workflow IDs
  --workflow <name>      Print steps or members for a named workflow

General:
  --base-dir <path>      Override the base directory (default: script directory)
  --help                 Show this help message
EOF
    exit 0
}

# Parse arguments
ACTION=""
TARGET=""
VARIANT="prompt"
PATH_ONLY=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)         ACTION="list"; shift ;;
        --id)           ACTION="id"; TARGET="$2"; shift 2 ;;
        --category)     ACTION="category"; TARGET="$2"; shift 2 ;;
        --tag)          ACTION="tag"; TARGET="$2"; shift 2 ;;
        --companions)   ACTION="companions"; TARGET="$2"; shift 2 ;;
        --chain)        ACTION="chain"; TARGET="$2"; shift 2 ;;
        --group)        ACTION="group"; TARGET="$2"; shift 2 ;;
        --workflows)    ACTION="workflows"; shift ;;
        --workflow)     ACTION="workflow"; TARGET="$2"; shift 2 ;;
        --base-dir)     BASE_DIR="$2"; INDEX="$BASE_DIR/index.yaml"; shift 2 ;;
        --semanticode)  VARIANT="semanticode"; shift ;;
        --path)         PATH_ONLY=true; shift ;;
        --help)         usage ;;
        *)              echo "Unknown option: $1" >&2; usage ;;
    esac
done

if [[ -z "$ACTION" ]]; then
    usage
fi

if [[ ! -f "$INDEX" ]]; then
    echo "Error: index.yaml not found at $INDEX" >&2
    exit 1
fi
if [[ ! -r "$INDEX" ]]; then
    echo "Error: index.yaml not readable at $INDEX" >&2
    exit 1
fi
# Minimal sanity check: file must declare a top-level `roles:` section.
if ! grep -qE '^roles:' "$INDEX"; then
    echo "Error: index.yaml is malformed (no 'roles:' section at $INDEX)" >&2
    exit 65
fi

# =============================================================================
# Role queries
# =============================================================================

list_ids() {
    awk '/^  - id:/ { gsub(/^  - id: */, ""); print }' "$INDEX"
}

get_prompt_path() {
    local role_id="$1"
    local variant="$2"

    awk -v id="$role_id" -v variant="$variant" '
        /^  - id:/ {
            current_id = $NF
            in_block = (current_id == id)
            next
        }
        in_block && $0 ~ "^      " variant ": " {
            val = $0
            sub("^[ ]*" variant ": *", "", val)
            gsub(/"/, "", val)
            if (val == "null" || val == "") {
                print "NULL"
            } else {
                print val
            }
            exit
        }
        in_block && /^  - id:/ { exit }
    ' "$INDEX"
}

list_by_category() {
    local category="$1"

    awk -v cat="$category" '
        /^  - id:/ {
            current_id = $NF
            next
        }
        /^    category:/ {
            current_cat = $NF
            if (current_cat == cat) {
                print current_id
            }
        }
    ' "$INDEX"
}

list_by_tag() {
    local tag="$1"

    awk -v tag="$tag" '
        /^  - id:/ {
            current_id = $NF
            in_tags = 0
            next
        }
        /^    tags:/ {
            in_tags = 1
            next
        }
        in_tags && /^      - / {
            t = $NF
            if (t == tag) {
                print current_id
            }
            next
        }
        in_tags && !/^      - / {
            in_tags = 0
        }
    ' "$INDEX"
}

# =============================================================================
# Composition queries
# =============================================================================

# List companion IDs for a role
list_companions() {
    local role_id="$1"

    awk -v id="$role_id" '
        /^  - id:/ {
            current_id = $NF
            in_block = (current_id == id)
            in_companions = 0
            next
        }
        in_block && /^      companions:/ {
            # Inline list: companions: [a, b]
            if ($0 ~ /\[/) {
                val = $0
                sub(/.*\[/, "", val)
                sub(/\].*/, "", val)
                gsub(/,/, "\n", val)
                gsub(/ /, "", val)
                print val
                exit
            }
            in_companions = 1
            next
        }
        in_block && in_companions && /^        - / {
            print $NF
            next
        }
        in_block && in_companions && !/^        - / {
            exit
        }
        in_block && /^  - id:/ { exit }
    ' "$INDEX"
}

# Get chain_after list for a role
get_chain_field() {
    local role_id="$1"
    local field="$2"

    awk -v id="$role_id" -v field="$field" '
        /^  - id:/ {
            current_id = $NF
            in_block = (current_id == id)
            next
        }
        in_block && $0 ~ "^      " field ": " {
            if ($0 ~ /\[/) {
                val = $0
                sub(/.*\[/, "", val)
                sub(/\].*/, "", val)
                gsub(/,/, "\n", val)
                gsub(/ /, "", val)
                print val
            }
            exit
        }
        in_block && /^  - id:/ { exit }
    ' "$INDEX"
}

# Walk the chain containing a role, output in order
walk_chain() {
    local start_id="$1"
    local -a chain=()
    local -A visited=()
    local current="$start_id"

    # Walk backwards via chain_after to find the head
    while true; do
        visited["$current"]=1
        local prev
        prev=$(get_chain_field "$current" "chain_after")
        if [[ -z "$prev" ]] || [[ -n "${visited[$prev]:-}" ]]; then
            break
        fi
        current="$prev"
    done

    # Walk forwards via chain_before from the head
    visited=()
    while true; do
        chain+=("$current")
        visited["$current"]=1
        local next_id
        next_id=$(get_chain_field "$current" "chain_before")
        if [[ -z "$next_id" ]] || [[ -n "${visited[$next_id]:-}" ]]; then
            break
        fi
        current="$next_id"
    done

    printf '%s\n' "${chain[@]}"
}

# List all role IDs belonging to a named group
list_by_group() {
    local group_name="$1"

    awk -v grp="$group_name" '
        /^  - id:/ {
            current_id = $NF
            next
        }
        /^      group:/ {
            g = $NF
            if (g == grp) {
                print current_id
            }
        }
    ' "$INDEX"
}

# List all workflow IDs
list_workflows() {
    awk '
        /^workflows:/ { in_workflows = 1; next }
        in_workflows && /^  [a-z]/ && /:/ {
            wf = $1
            sub(/:$/, "", wf)
            print wf
        }
        in_workflows && /^[a-z]/ && !/^  / { exit }
    ' "$INDEX"
}

# List steps or members for a named workflow
get_workflow() {
    local wf_name="$1"

    awk -v wf="$wf_name" '
        /^workflows:/ { in_workflows = 1; next }
        in_workflows && /^  [a-z]/ && /:/ {
            current_wf = $1
            sub(/:$/, "", current_wf)
            in_block = (current_wf == wf)
            in_list = 0
            next
        }
        in_block && (/^    steps:/ || /^    members:/) {
            in_list = 1
            next
        }
        in_block && in_list && /^      - / {
            print $NF
            next
        }
        in_block && in_list && !/^      - / {
            in_list = 0
        }
        # Next workflow or end
        in_block && /^  [a-z]/ && /:/ { exit }
        in_workflows && /^[a-z]/ && !/^  / { exit }
    ' "$INDEX"
}

# =============================================================================
# Execute
# =============================================================================

case "$ACTION" in
    list)
        list_ids
        ;;
    id)
        prompt_path=$(get_prompt_path "$TARGET" "$VARIANT")
        if [[ -z "$prompt_path" || "$prompt_path" == "NULL" ]]; then
            echo "Error: no $VARIANT file for role '$TARGET'" >&2
            exit 1
        fi
        full_path="$BASE_DIR/$prompt_path"
        if $PATH_ONLY; then
            echo "$full_path"
        else
            if [[ ! -f "$full_path" ]]; then
                echo "Error: file not found: $full_path" >&2
                exit 1
            fi
            cat "$full_path"
        fi
        ;;
    category)
        results=$(list_by_category "$TARGET")
        if [[ -z "$results" ]]; then
            echo "No roles found in category '$TARGET'" >&2
            exit 1
        fi
        echo "$results"
        ;;
    tag)
        results=$(list_by_tag "$TARGET")
        if [[ -z "$results" ]]; then
            echo "No roles found with tag '$TARGET'" >&2
            exit 1
        fi
        echo "$results"
        ;;
    companions)
        results=$(list_companions "$TARGET")
        if [[ -z "$results" ]]; then
            echo "No companions found for role '$TARGET'" >&2
            exit 1
        fi
        echo "$results"
        ;;
    chain)
        results=$(walk_chain "$TARGET")
        if [[ -z "$results" ]]; then
            echo "No chain found containing role '$TARGET'" >&2
            exit 1
        fi
        echo "$results"
        ;;
    group)
        results=$(list_by_group "$TARGET")
        if [[ -z "$results" ]]; then
            echo "No roles found in group '$TARGET'" >&2
            exit 1
        fi
        echo "$results"
        ;;
    workflows)
        results=$(list_workflows)
        if [[ -z "$results" ]]; then
            echo "No workflows defined" >&2
            exit 1
        fi
        echo "$results"
        ;;
    workflow)
        results=$(get_workflow "$TARGET")
        if [[ -z "$results" ]]; then
            echo "No workflow found with name '$TARGET'" >&2
            exit 1
        fi
        echo "$results"
        ;;
esac
