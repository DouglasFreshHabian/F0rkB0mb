#!/bin/bash

# Fork Bomb & Dangerous Pattern Detector

set -euo pipefail
shopt -s nullglob

# ─── COLORS ──────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; PURPLE='\033[0;35m'
WHITE='\033[0;37m'; RESET='\033[0m'
allcolors=("RED" "GREEN" "YELLOW" "BLUE" "CYAN" "PURPLE" "WHITE")

# ─── ASCII BANNER ────────────────────────────────
ascii_banner() {
    local rc="${allcolors[$((RANDOM % ${#allcolors[@]}))]}"
    local cc=${!rc}
    echo -e "${cc}"
    cat << "EOF"
	        ,--.!,
	     __/   -*-
	   ,d08b.  '|`
	   0088MM
	   `9MMP'
EOF
    echo -e "${RESET}"
}

# ─── ARGUMENT HANDLING ───────────────────────────
MODE="all"
FILES=()

for arg in "$@"; do
    case "$arg" in
        --forkbombs) MODE="forkbombs" ;;
        --dangerous) MODE="dangerous" ;;
        *) FILES+=("$arg") ;;
    esac
done

# ─── TARGET FILES ────────────────────────────────
if [ ${#FILES[@]} -eq 0 ]; then
    FILES=(./*.sh)
fi

if [ ${#FILES[@]} -eq 0 ]; then
    echo -e "${YELLOW}No .sh files found to scan.${RESET}"
    exit 1
fi

# ─── PATTERN GROUPS ──────────────────────────────
declare -a forkbomb_patterns=(
    ': *\(\) *{ *: *\| *: *& *}; *:'                # Classic
    'while +true; *do.*\$0'                         # Self-calling loop
    '[a-zA-Z_]+\(\) *{ *[a-zA-Z_]+ *\| *[a-zA-Z_]+.*}' # Recursive func
    '\$0 *&'                                         # Background self-call
    'bash +\$0'                                      # Explicit self-call
    'alias +[a-zA-Z]+ *= *".*:.*&.*;.*"'             # Aliased forkbomb
    '[a-zA-Z_]+\(\) *{ *: *; *}; *[a-zA-Z_]+'        # Obfuscated variant
)

declare -a dangerous_patterns=(
    'rm +-rf +/'                                     # Dangerous delete
    'dd +if=.* +of=.*'                               # Overwrite disks
    'mkfs\.\w+ +/dev/[a-z]+'                         # Format disk
    'yes +.*| +yes'                                  # CPU spam
    ':\s*;?\s*:'                                     # Empty infinite loop
    'fork *\(\)'                                     # C-style fork()
)

# ─── SCAN FUNCTION ───────────────────────────────
scan_file() {
    local file="$1"
    local found=0

    echo -e "${GREEN}Scanning:${RESET} $file"

    local patterns=()
    [[ "$MODE" == "forkbombs" || "$MODE" == "all" ]] && patterns+=("${forkbomb_patterns[@]}")
    [[ "$MODE" == "dangerous" || "$MODE" == "all" ]] && patterns+=("${dangerous_patterns[@]}")

    for pattern in "${patterns[@]}"; do
        grep_output=$(grep -En "$pattern" "$file" 2>/dev/null || true)
        if [[ -n "$grep_output" ]]; then
            while IFS= read -r match; do
                lineno=$(cut -d: -f1 <<< "$match")
                code=$(cut -d: -f2- <<< "$match")
                echo -e "${RED}⚠ Match at line $lineno:${RESET}"
                echo -e "   ${YELLOW}$code${RESET}"
                found=1
            done <<< "$grep_output"
        fi
    done

    echo
    return $found
}

# ─── RUN ─────────────────────────────────────────
ascii_banner
echo -e "${BLUE}🔍 Pattern Detection Mode: ${MODE}${RESET}\n"

issues=0
for f in "${FILES[@]}"; do
    if ! scan_file "$f"; then
        issues=1
    fi
done

if [ "$issues" -eq 0 ]; then
    echo -e "${GREEN}✅ No suspicious patterns detected.${RESET}"
else
    echo -e "${RED}🚨 Review detected patterns above.${RESET}"
fi

exit $issues
