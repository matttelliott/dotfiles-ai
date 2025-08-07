#!/bin/bash
# PostgreSQL client tools setup

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Detect OS
OS="$(uname)"
if [[ "$OS" == "Darwin" ]]; then
    PLATFORM="macos"
elif [[ "$OS" == "Linux" ]]; then
    if [[ -f /etc/debian_version ]]; then
        PLATFORM="debian"
    else
        PLATFORM="linux"
    fi
else
    log_warning "Unknown platform: $OS"
    exit 1
fi

install_postgres_client() {
    log_info "Installing PostgreSQL client tools..."
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install postgresql@16
                brew link postgresql@16 --force
            else
                log_warning "Homebrew not found, please install PostgreSQL manually"
                exit 1
            fi
            ;;
        debian)
            # Add PostgreSQL APT repository
            sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
            wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
            sudo apt update
            sudo apt install -y postgresql-client-16 postgresql-client-common
            ;;
        *)
            log_warning "Unsupported platform for PostgreSQL installation"
            exit 1
            ;;
    esac
    
    log_success "PostgreSQL client tools installed"
}

install_pgcli() {
    log_info "Installing pgcli (enhanced PostgreSQL CLI)..."
    
    if command -v pgcli &> /dev/null; then
        log_info "pgcli is already installed"
        return 0
    fi
    
    # Install via pip/pipx if available
    if command -v pipx &> /dev/null; then
        pipx install pgcli
    elif command -v pip3 &> /dev/null; then
        pip3 install --user pgcli
    elif [[ "$PLATFORM" == "macos" ]] && command -v brew &> /dev/null; then
        brew install pgcli
    else
        log_warning "Could not install pgcli - pip or pipx required"
    fi
    
    log_success "pgcli installed"
}

setup_postgres_config() {
    log_info "Setting up PostgreSQL configuration..."
    
    # Create pgpass file for password storage
    touch "$HOME/.pgpass"
    chmod 600 "$HOME/.pgpass"
    
    # Create psql config directory
    mkdir -p "$HOME/.psqlrc.d"
    
    # Create psqlrc configuration
    cat > "$HOME/.psqlrc" << 'EOF'
-- Better NULL display
\pset null '¤'

-- Expanded output for wide tables
\x auto

-- Show query times
\timing

-- History per database
\set HISTFILE ~/.psql_history- :DBNAME

-- Bigger history
\set HISTSIZE 5000

-- Verbose error reports
\set VERBOSITY verbose

-- Prompt customization
\set PROMPT1 '%[%033[1m%]%M %n@%/%R%[%033[0m%]%# '
\set PROMPT2 '[more] %R > '

-- Useful aliases
\set version 'SELECT version();'
\set extensions 'SELECT * FROM pg_available_extensions;'
\set tables 'SELECT schemaname,tablename,tableowner FROM pg_tables WHERE schemaname NOT IN (''pg_catalog'', ''information_schema'');'
\set indexes 'SELECT schemaname,tablename,indexname FROM pg_indexes WHERE schemaname NOT IN (''pg_catalog'', ''information_schema'');'
\set dbsize 'SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database ORDER BY pg_database_size(datname) DESC;'
\set tablesize 'SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||''.''||tablename)) AS size FROM pg_tables WHERE schemaname NOT IN (''pg_catalog'', ''information_schema'') ORDER BY pg_total_relation_size(schemaname||''.''||tablename) DESC;'
\set locks 'SELECT pid, usename, pg_blocking_pids(pid) AS blocked_by, query FROM pg_stat_activity WHERE cardinality(pg_blocking_pids(pid)) > 0;'
\set activity 'SELECT pid, usename, application_name, client_addr, backend_start, state, query FROM pg_stat_activity WHERE state != ''idle'' ORDER BY backend_start;'
\set slow_queries 'SELECT query, calls, mean, total_time FROM pg_stat_statements ORDER BY mean DESC LIMIT 10;'

-- Better table display
\pset linestyle unicode
\pset border 2
EOF
    
    log_success "PostgreSQL configuration created"
}

setup_postgres_aliases() {
    log_info "Setting up PostgreSQL aliases..."
    
    local pg_aliases='
# PostgreSQL aliases
alias psql="psql -U postgres"
alias pg="psql"
alias pgd="psql -d"
alias pgl="psql -l"  # List databases
alias pgdu="psql -c \"SELECT datname, pg_size_pretty(pg_database_size(datname)) FROM pg_database ORDER BY pg_database_size(datname) DESC;\""  # Database sizes
alias pgt="psql -c \"SELECT schemaname,tablename FROM pg_tables WHERE schemaname NOT IN ('"'"'pg_catalog'"'"', '"'"'information_schema'"'"');\""  # List tables

# PostgreSQL functions
pgconnect() {
    # Connect with common format
    psql "postgresql://${1:-localhost}:${2:-5432}/${3:-postgres}?user=${4:-postgres}"
}

pgdump() {
    # Dump database
    pg_dump -U postgres -h localhost -d "$1" -f "${1}_$(date +%Y%m%d_%H%M%S).sql"
}

pgrestore() {
    # Restore database
    psql -U postgres -h localhost -d "$1" -f "$2"
}

pgsize() {
    # Get table sizes
    psql -U postgres -d "$1" -c "SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'"'"'.'"'"'||tablename)) AS size FROM pg_tables WHERE schemaname NOT IN ('"'"'pg_catalog'"'"', '"'"'information_schema'"'"') ORDER BY pg_total_relation_size(schemaname||'"'"'.'"'"'||tablename) DESC LIMIT 20;"
}

pgkill() {
    # Kill query by PID
    psql -U postgres -c "SELECT pg_terminate_backend($1);"
}
'
    
    # Add to shell RC files
    for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q "# PostgreSQL aliases" "$rc_file"; then
                echo "$pg_aliases" >> "$rc_file"
                log_success "Added PostgreSQL aliases to $(basename $rc_file)"
            else
                log_info "PostgreSQL aliases already configured in $(basename $rc_file)"
            fi
        fi
    done
}

# Main installation
main() {
    log_info "Setting up PostgreSQL client tools..."
    
    install_postgres_client
    install_pgcli
    setup_postgres_config
    setup_postgres_aliases
    
    log_success "PostgreSQL client setup complete!"
    echo
    echo "Installed tools:"
    echo "  • psql - PostgreSQL client"
    echo "  • pg_dump/pg_restore - Backup tools"
    echo "  • pgcli - Enhanced PostgreSQL CLI with auto-completion"
    echo
    echo "Configuration:"
    echo "  • ~/.psqlrc - psql configuration"
    echo "  • ~/.pgpass - Password file (chmod 600)"
    echo
    echo "Quick commands:"
    echo "  psql -U user -h host -d database"
    echo "  pgcli -U user -h host -d database"
    echo
    echo "Note: For full PostgreSQL server, install separately"
}

main "$@"