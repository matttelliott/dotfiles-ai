#!/bin/bash
# HTTPie and curl tools setup

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

install_curl() {
    log_info "Checking curl installation..."
    
    if command -v curl &> /dev/null; then
        log_info "curl is already installed: $(curl --version | head -n1)"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            # macOS comes with curl pre-installed
            log_info "curl comes pre-installed on macOS"
            ;;
        debian)
            sudo apt update
            sudo apt install -y curl
            ;;
        *)
            log_warning "Please install curl manually"
            ;;
    esac
    
    log_success "curl installed"
}

install_httpie() {
    log_info "Installing HTTPie..."
    
    if command -v http &> /dev/null; then
        log_info "HTTPie is already installed: $(http --version)"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install httpie
            else
                pip3 install --user httpie
            fi
            ;;
        debian)
            sudo apt update
            sudo apt install -y httpie
            ;;
        *)
            # Install via pip as fallback
            if command -v pipx &> /dev/null; then
                pipx install httpie
            elif command -v pip3 &> /dev/null; then
                pip3 install --user httpie
            else
                log_warning "Could not install HTTPie - pip required"
            fi
            ;;
    esac
    
    log_success "HTTPie installed"
}

install_httpie_plugins() {
    log_info "Installing HTTPie plugins..."
    
    # Check if HTTPie is installed
    if ! command -v http &> /dev/null; then
        log_warning "HTTPie not installed, skipping plugins"
        return 1
    fi
    
    # Install useful plugins
    if command -v pipx &> /dev/null; then
        # Auth plugins
        pipx inject httpie httpie-oauth || true
        pipx inject httpie httpie-jwt-auth || true
        # Format plugins
        pipx inject httpie httpie-msgpack || true
    elif command -v pip3 &> /dev/null; then
        pip3 install --user httpie-oauth httpie-jwt-auth httpie-msgpack 2>/dev/null || true
    fi
    
    log_success "HTTPie plugins installed"
}

install_curlie() {
    log_info "Installing curlie (HTTPie-like curl wrapper)..."
    
    if command -v curlie &> /dev/null; then
        log_info "curlie is already installed"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install curlie
            else
                log_warning "Please install curlie manually"
            fi
            ;;
        debian|linux)
            # Install via Go if available
            if command -v go &> /dev/null; then
                go install github.com/rs/curlie@latest
            else
                log_warning "Go required to install curlie"
            fi
            ;;
    esac
    
    log_success "curlie installed"
}

install_xh() {
    log_info "Installing xh (modern HTTP client)..."
    
    if command -v xh &> /dev/null; then
        log_info "xh is already installed"
        return 0
    fi
    
    case "$PLATFORM" in
        macos)
            if command -v brew &> /dev/null; then
                brew install xh
            elif command -v cargo &> /dev/null; then
                cargo install xh
            else
                log_warning "Please install xh manually"
            fi
            ;;
        debian|linux)
            if command -v cargo &> /dev/null; then
                cargo install xh
            else
                # Download binary
                XH_VERSION=$(curl -s https://api.github.com/repos/ducaale/xh/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
                ARCH=$(uname -m)
                if [[ "$ARCH" == "x86_64" ]]; then
                    ARCH="x86_64"
                elif [[ "$ARCH" == "aarch64" ]]; then
                    ARCH="aarch64"
                fi
                
                curl -L -o xh.tar.gz "https://github.com/ducaale/xh/releases/download/v${XH_VERSION}/xh-v${XH_VERSION}-${ARCH}-unknown-linux-musl.tar.gz"
                tar xzf xh.tar.gz
                sudo mv xh-*/xh /usr/local/bin/
                rm -rf xh.tar.gz xh-*/
            fi
            ;;
    esac
    
    log_success "xh installed"
}

setup_httpie_config() {
    log_info "Setting up HTTPie configuration..."
    
    # Create HTTPie config directory
    mkdir -p "$HOME/.config/httpie"
    
    # Create config file
    cat > "$HOME/.config/httpie/config.json" << 'EOF'
{
    "default_options": [
        "--style=monokai",
        "--print=HhBb"
    ],
    "__meta__": {
        "about": "HTTPie configuration",
        "help": "https://httpie.io/docs#config"
    }
}
EOF
    
    log_success "HTTPie configuration created"
}

setup_curl_config() {
    log_info "Setting up curl configuration..."
    
    # Create .curlrc file
    cat > "$HOME/.curlrc" << 'EOF'
# Follow redirects
--location

# Show progress bar instead of progress meter
--progress-bar

# Timeout settings
--connect-timeout 30
--max-time 300

# User agent
--user-agent "curl"

# Enable compressed responses
--compressed

# Retry on failure
--retry 3
--retry-delay 3

# Show error messages
--show-error

# Silent mode (no progress bar) can be enabled with -s
# --silent
EOF
    
    log_success "curl configuration created"
}

setup_http_aliases() {
    log_info "Setting up HTTP tool aliases..."
    
    local http_aliases='
# HTTP tools aliases

# HTTPie aliases
alias GET="http GET"
alias POST="http POST"
alias PUT="http PUT"
alias PATCH="http PATCH"
alias DELETE="http DELETE"
alias HEAD="http HEAD"

# HTTPie shortcuts
alias http-json="http --json"
alias http-form="http --form"
alias http-download="http --download"
alias http-headers="http --headers"
alias http-verbose="http --verbose"

# curl aliases
alias curl-json="curl -H '\''Content-Type: application/json'\''"
alias curl-post="curl -X POST"
alias curl-put="curl -X PUT"
alias curl-delete="curl -X DELETE"
alias curl-headers="curl -I"
alias curl-verbose="curl -v"
alias curl-silent="curl -s"
alias curl-download="curl -O"
alias curl-follow="curl -L"
alias curl-auth="curl -u"

# Common API testing functions
api-get() {
    http GET "$@"
}

api-post() {
    http POST "$@"
}

api-put() {
    http PUT "$@"
}

api-delete() {
    http DELETE "$@"
}

# JSON pretty print
json-pretty() {
    if command -v jq &> /dev/null; then
        jq .
    elif command -v python3 &> /dev/null; then
        python3 -m json.tool
    else
        cat
    fi
}

# Test API endpoint
api-test() {
    local url="${1:-http://localhost:8080}"
    echo "Testing API at: $url"
    echo "---"
    echo "GET $url"
    http --print=HhBb GET "$url" || curl -i "$url"
}

# Benchmark endpoint
api-bench() {
    local url="${1:-http://localhost:8080}"
    local requests="${2:-100}"
    local concurrency="${3:-10}"
    
    if command -v ab &> /dev/null; then
        ab -n "$requests" -c "$concurrency" "$url"
    elif command -v hey &> /dev/null; then
        hey -n "$requests" -c "$concurrency" "$url"
    else
        echo "Install Apache Bench (ab) or hey for benchmarking"
    fi
}

# Download with resume support
download() {
    local url="$1"
    local output="${2:-$(basename "$url")}"
    curl -L -C - -o "$output" "$url"
}

# Upload file
upload() {
    local file="$1"
    local url="${2:-https://transfer.sh}"
    
    if [[ -f "$file" ]]; then
        curl --upload-file "$file" "$url/$(basename "$file")"
        echo
    else
        echo "File not found: $file"
    fi
}

# Check HTTP status
http-status() {
    local url="$1"
    curl -s -o /dev/null -w "%{http_code}\n" "$url"
}

# Time request
http-time() {
    local url="$1"
    curl -w "@-" -o /dev/null -s "$url" << '\''EOF'\''
    time_namelookup:  %{time_namelookup}s
    time_connect:     %{time_connect}s
    time_appconnect:  %{time_appconnect}s
    time_pretransfer: %{time_pretransfer}s
    time_redirect:    %{time_redirect}s
    time_starttransfer: %{time_starttransfer}s
    ----------
    time_total:       %{time_total}s
EOF
}

# Test REST endpoints
rest-test() {
    local base="${1:-http://localhost:8080}"
    echo "Testing REST endpoints at: $base"
    echo "---"
    echo "GET $base"
    http GET "$base" 2>/dev/null || curl "$base"
    echo "---"
    echo "POST $base"
    http POST "$base" test=data 2>/dev/null || curl -X POST "$base" -d '\''{"test":"data"}'\''
}

# GraphQL query
graphql() {
    local url="$1"
    local query="$2"
    
    if [[ -z "$query" ]]; then
        echo "Usage: graphql <url> <query>"
        return 1
    fi
    
    http POST "$url" Content-Type:application/json query="$query"
}

# WebSocket test
ws-test() {
    local url="$1"
    
    if command -v websocat &> /dev/null; then
        websocat "$url"
    elif command -v wscat &> /dev/null; then
        wscat -c "$url"
    else
        echo "Install websocat or wscat for WebSocket testing"
    fi
}

# Bearer token helper
bearer() {
    local token="$1"
    shift
    http "$@" "Authorization:Bearer $token"
}

# Basic auth helper
basic-auth() {
    local user="$1"
    local pass="$2"
    shift 2
    http -a "$user:$pass" "$@"
}
'
    
    # Add to shell RC files
    for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
        if [[ -f "$rc_file" ]]; then
            if ! grep -q "# HTTP tools aliases" "$rc_file"; then
                echo "$http_aliases" >> "$rc_file"
                log_success "Added HTTP aliases to $(basename $rc_file)"
            else
                log_info "HTTP aliases already configured in $(basename $rc_file)"
            fi
        fi
    done
}

create_http_templates() {
    log_info "Creating HTTP request templates..."
    
    mkdir -p "$HOME/.config/http/templates"
    
    # API test script
    cat > "$HOME/.config/http/templates/api-test.sh" << 'EOF'
#!/bin/bash
# API testing script template

BASE_URL="${1:-http://localhost:8080}"
TOKEN="${API_TOKEN:-}"

echo "Testing API at: $BASE_URL"
echo "================================"

# Health check
echo -e "\n[Health Check]"
http GET "$BASE_URL/health"

# Authentication
if [[ -n "$TOKEN" ]]; then
    echo -e "\n[Authenticated Request]"
    http GET "$BASE_URL/api/user" "Authorization:Bearer $TOKEN"
fi

# GET request
echo -e "\n[GET /api/items]"
http GET "$BASE_URL/api/items"

# POST request
echo -e "\n[POST /api/items]"
http POST "$BASE_URL/api/items" \
    name="Test Item" \
    description="Test Description"

# PUT request
echo -e "\n[PUT /api/items/1]"
http PUT "$BASE_URL/api/items/1" \
    name="Updated Item"

# DELETE request
echo -e "\n[DELETE /api/items/1]"
http DELETE "$BASE_URL/api/items/1"

echo -e "\n================================"
echo "API test complete"
EOF
    chmod +x "$HOME/.config/http/templates/api-test.sh"
    
    # HTTPie session example
    cat > "$HOME/.config/http/templates/session-example.sh" << 'EOF'
#!/bin/bash
# HTTPie session example

SESSION_NAME="my-api"
BASE_URL="http://localhost:8080"

# Login and save session
echo "Logging in..."
http --session="$SESSION_NAME" POST "$BASE_URL/auth/login" \
    username="user" \
    password="pass"

# Use session for authenticated requests
echo "Making authenticated request..."
http --session="$SESSION_NAME" GET "$BASE_URL/api/protected"

# Logout
echo "Logging out..."
http --session="$SESSION_NAME" POST "$BASE_URL/auth/logout"
EOF
    chmod +x "$HOME/.config/http/templates/session-example.sh"
    
    # curl examples
    cat > "$HOME/.config/http/templates/curl-examples.sh" << 'EOF'
#!/bin/bash
# Common curl examples

# GET request
curl -X GET https://api.example.com/users

# POST JSON
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'

# POST form data
curl -X POST https://api.example.com/login \
  -d "username=admin&password=secret"

# Upload file
curl -X POST https://api.example.com/upload \
  -F "file=@/path/to/file.pdf"

# Download file
curl -O https://example.com/file.zip

# With authentication
curl -H "Authorization: Bearer TOKEN" \
  https://api.example.com/protected

# Follow redirects
curl -L https://example.com/redirect

# Show headers only
curl -I https://example.com

# Verbose output
curl -v https://example.com

# Save cookies
curl -c cookies.txt https://example.com/login

# Use cookies
curl -b cookies.txt https://example.com/protected

# Custom headers
curl -H "X-Custom-Header: value" \
  -H "Another-Header: value" \
  https://api.example.com

# Timeout
curl --connect-timeout 5 --max-time 30 \
  https://slow-api.example.com

# Proxy
curl -x http://proxy:8080 https://example.com

# Client certificate
curl --cert client.pem --key client-key.pem \
  https://secure-api.example.com
EOF
    
    # GraphQL template
    cat > "$HOME/.config/http/templates/graphql.sh" << 'EOF'
#!/bin/bash
# GraphQL query examples

GRAPHQL_ENDPOINT="http://localhost:4000/graphql"

# Simple query
http POST "$GRAPHQL_ENDPOINT" \
  Content-Type:application/json \
  query='{
    users {
      id
      name
      email
    }
  }'

# Query with variables
http POST "$GRAPHQL_ENDPOINT" \
  Content-Type:application/json \
  query='query GetUser($id: ID!) {
    user(id: $id) {
      id
      name
      email
    }
  }' \
  variables:='{"id": "1"}'

# Mutation
http POST "$GRAPHQL_ENDPOINT" \
  Content-Type:application/json \
  query='mutation CreateUser($input: UserInput!) {
    createUser(input: $input) {
      id
      name
      email
    }
  }' \
  variables:='{"input": {"name": "John", "email": "john@example.com"}}'

# With authentication
http POST "$GRAPHQL_ENDPOINT" \
  Authorization:"Bearer $TOKEN" \
  Content-Type:application/json \
  query='{
    me {
      id
      name
      email
    }
  }'
EOF
    chmod +x "$HOME/.config/http/templates/graphql.sh"
    
    log_success "HTTP templates created"
}

# Main installation
main() {
    log_info "Setting up HTTP tools..."
    
    install_curl
    install_httpie
    install_httpie_plugins
    install_curlie
    install_xh
    setup_httpie_config
    setup_curl_config
    setup_http_aliases
    create_http_templates
    
    log_success "HTTP tools setup complete!"
    echo
    echo "Installed tools:"
    echo "  • curl - Command line HTTP client"
    echo "  • HTTPie - Human-friendly HTTP client"
    echo "  • curlie - HTTPie-like curl wrapper"
    echo "  • xh - Modern HTTP client"
    echo
    echo "Configuration:"
    echo "  • ~/.curlrc - curl configuration"
    echo "  • ~/.config/httpie/config.json - HTTPie configuration"
    echo
    echo "Quick commands:"
    echo "  http GET httpbin.org/get      - HTTPie GET request"
    echo "  http POST httpbin.org/post    - HTTPie POST request"
    echo "  curl -I example.com            - Headers only"
    echo "  xh httpbin.org/get            - xh GET request"
    echo
    echo "Templates available in ~/.config/http/templates/"
    echo
    echo "Try: http httpbin.org/get"
}

main "$@"