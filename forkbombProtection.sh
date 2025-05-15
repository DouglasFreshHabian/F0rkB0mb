#!/bin/bash

# Fork Bomb Protection Setup Script for Ubuntu
set -euo pipefail
trap 'echo "❌ An error occurred. Aborting." >&2; exit 1' ERR

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; PURPLE='\033[0;35m'; WHITE='\033[0;37m'; RESET='\033[0m'
REDB='\033[1;31m'; GREENB='\033[1;32m'; YELLOWB='\033[1;33m'
BLUEB='\033[1;34m'; CYANB='\033[1;36m'; PURPLEB='\033[1;35m'; WHITEB='\033[1;37m'

allcolors=("RED" "GREEN" "YELLOW" "BLUE" "CYAN" "PURPLE" "WHITE")

# Paths
LIMITS_CONF="/etc/security/limits.d/forkbomb.conf"
PAM_SESSION="/etc/pam.d/common-session"

# Flags
DRY_RUN=false
RESTORE=false
QUIET=false
STATUS=false

# Get real user
TARGET_USER="${SUDO_USER:-$(logname)}"

# Parse args
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --restore) RESTORE=true ;;
        --quiet) QUIET=true ;;
        --status) STATUS=true ;;
        *) echo -e "${YELLOW}Unknown option: $arg${RESET}" && exit 1 ;;
    esac
done

ascii_banner() {
    $QUIET && return
    random_color="${allcolors[$((RANDOM % ${#allcolors[@]}))]}"
    case $random_color in
        "RED") color_code=$RED ;; "GREEN") color_code=$GREEN ;;
        "YELLOW") color_code=$YELLOW ;; "BLUE") color_code=$BLUE ;;
        "CYAN") color_code=$CYAN ;; "PURPLE") color_code=$PURPLE ;;
        "WHITE") color_code=$WHITE ;;
    esac

    echo -e "${color_code}"
    cat << "EOF"
            . . .
              \|/
            `--+--'
              /|\
             ' | '
               |
               |
           ,--'#`--.
           |#######|
        _.-'#######`-._
     ,-'###############`-.
   ,'#####################`,
  /#########################\
 |###########################|
|#############################|
|#############################|
|#############################|
|#############################|
 |###########################|
  \#########################/
   `.#####################,'
     `._###############_,'
        `--..#####..--'
EOF
    echo -e "${RESET}"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "❌ ${YELLOWB}Please run this script as ${REDB}root${RESET} (${BLUEB}use sudo${RESET})"
        exit 1
    fi
}

print_ulimit_report() {
    echo -e "🧾 ${BLUEB}Ulimit status for user${RESET}: ${CYANB}$TARGET_USER${RESET}"
    echo -e "${WHITEB}-----------------------------------------${RESET}"
#    su - "$TARGET_USER" -c "ulimit -a"
    sudo -u "$TARGET_USER" bash -c "ulimit -a"
    echo -e "${WHITEB}-----------------------------------------${RESET}"
    echo
}

apply_limits_conf() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "[DRY-RUN] Would write to $LIMITS_CONF:"
    else
        echo -e "📄 ${GREENB}Writing process/file size limits to${RESET}: $LIMITS_CONF"
    fi

    cat <<EOF | tee >(if [ "$DRY_RUN" = false ]; then cat > "$LIMITS_CONF"; else cat > /dev/null; fi)
# Fork bomb protection
$TARGET_USER  hard  nproc   100
$TARGET_USER  soft  nproc    80
$TARGET_USER  hard  fsize 10000
$TARGET_USER  soft  fsize  8000
$TARGET_USER  hard  core      0
$TARGET_USER  hard  nofile 4096
$TARGET_USER  soft  nofile 2048
$TARGET_USER  hard  stack  8192
$TARGET_USER  soft  stack  4096
EOF

    [ "$DRY_RUN" = false ] && echo -e "✅ Limits written."
}

patch_pam_limits() {
    echo -e "🔧 ${PURPLEB}Ensuring PAM loads resource limits${RESET}..."
    if grep -q 'pam_limits.so' "$PAM_SESSION"; then
        echo -e "✅ PAM already configured."
    elif [ "$DRY_RUN" = true ]; then
        echo -e "[DRY-RUN] Would append 'session required pam_limits.so' to $PAM_SESSION"
    else
        echo 'session required pam_limits.so' >> "$PAM_SESSION"
        echo -e "✅ Added pam_limits.so to $PAM_SESSION"
    fi
}

restore_defaults() {
    echo -e "🧹 ${YELLOWB}Restoring system defaults...${RESET}"
    [ -f "$LIMITS_CONF" ] && rm -f "$LIMITS_CONF" && echo "🗑 Removed $LIMITS_CONF"

    if grep -q 'pam_limits.so' "$PAM_SESSION"; then
        sed -i '/pam_limits.so/d' "$PAM_SESSION"
        echo "🧼 Cleaned up $PAM_SESSION"
    fi

    echo -e "${GREENB}✅ System limits restored.${RESET}"
}

main() {
    check_root
    $QUIET || ascii_banner

    if [ "$RESTORE" = true ]; then
        restore_defaults
        exit 0
    fi

    if [ "$STATUS" = true ]; then
        print_ulimit_report
        exit 0
    fi

    echo -e "🔍 ${YELLOWB}BEFORE applying limits${RESET}:"
    print_ulimit_report

    apply_limits_conf
    patch_pam_limits

    echo -e "🔁 ${BLUEB}AFTER applying limits${RESET} (some changes require logout/login):"
    print_ulimit_report

    echo -e "✅ ${GREENB}Protection applied${RESET}. Please log out and back in for full effect."
}

main
