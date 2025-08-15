#!/bin/bash
# Common utilities for all installers

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case $ID in
            debian|ubuntu)
                OS="debian"
                ;;
            linuxmint)
                OS="mint"
                ;;
            fedora|rhel|centos)
                OS="fedora"
                ;;
            arch|manjaro)
                OS="arch"
                ;;
            *)
                OS="linux"
                ;;
        esac
    else
        OS="unknown"
    fi
    export OS
}

# Check if running in CI/non-interactive mode
is_ci() {
    # Check for explicit CI environment variables
    [[ -n "$CI" ]] || [[ -n "$GITHUB_ACTIONS" ]] || [[ -n "$JENKINS_HOME" ]] || [[ -n "$GITLAB_CI" ]]
}

# Safe sudo that handles CI environments
safe_sudo() {
    if is_ci; then
        log_warning "Running in CI/non-interactive mode, skipping: $*"
        return 1
    else
        sudo "$@"
    fi
}

# Safe apt update that ignores repository errors
safe_apt_update() {
    if is_ci; then
        log_warning "Running in CI/non-interactive mode, skipping apt update"
        return 1
    else
        # Run apt update but don't fail on repository errors
        sudo apt-get update 2>&1 | grep -v "^E: The repository" | grep -v "^W:" || true
        return 0
    fi
}

# Export functions so they're available in subshells
export -f log_info log_success log_warning log_error detect_os is_ci safe_sudo safe_apt_update