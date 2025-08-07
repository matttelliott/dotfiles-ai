# HTTPie and HTTP Tools

Modern HTTP clients for API testing and web debugging.

## Installation

```bash
./tools-cli/httpie/setup.sh
```

## What Gets Installed

### Core Tools
- **curl** - Classic command-line HTTP client
- **HTTPie** - Human-friendly HTTP client with JSON support
- **curlie** - HTTPie-like interface for curl
- **xh** - Extremely fast HTTP client written in Rust

### HTTPie Plugins
- **httpie-oauth** - OAuth authentication support
- **httpie-jwt-auth** - JWT authentication
- **httpie-msgpack** - MessagePack format support

## HTTPie Usage

### Basic Requests
```bash
# GET request
http GET httpbin.org/get

# POST JSON (default)
http POST httpbin.org/post name=John age=30

# POST form data
http --form POST httpbin.org/post name=John age=30

# Custom headers
http GET httpbin.org/headers User-Agent:MyApp/1.0

# Authentication
http -a username:password GET httpbin.org/basic-auth/username/password
```

### JSON Operations
```bash
# Send JSON
http POST api.example.com/users \
  name="Jane Doe" \
  email="jane@example.com" \
  roles:='["admin", "user"]' \
  active:=true \
  score:=4.5

# Pretty print JSON response
http GET api.example.com/users | jq .

# Download JSON
http --download GET api.example.com/data.json
```

### Sessions
```bash
# Create named session
http --session=myapi POST api.example.com/login \
  username=admin password=secret

# Use session for subsequent requests
http --session=myapi GET api.example.com/protected

# Clear session
http --session=myapi POST api.example.com/logout
```

### File Operations
```bash
# Upload file
http --form POST api.example.com/upload file@/path/to/file.pdf

# Download file
http --download GET example.com/file.zip

# Stream upload
http POST api.example.com/upload < file.txt
```

## curl Usage

### Basic Commands
```bash
# GET request
curl https://api.example.com/users

# POST JSON
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'

# Headers only
curl -I https://example.com

# Follow redirects
curl -L https://bit.ly/shortened

# Verbose output
curl -v https://api.example.com
```

### Authentication
```bash
# Basic auth
curl -u username:password https://api.example.com

# Bearer token
curl -H "Authorization: Bearer TOKEN" https://api.example.com

# Client certificate
curl --cert client.pem --key client-key.pem https://api.example.com
```

### Advanced Options
```bash
# Custom method
curl -X PUT https://api.example.com/resource

# Cookies
curl -c cookies.txt https://example.com/login
curl -b cookies.txt https://example.com/protected

# Proxy
curl -x http://proxy:8080 https://example.com

# Rate limiting
curl --limit-rate 200K https://example.com/large-file

# Resume download
curl -C - -O https://example.com/large-file.zip
```

## xh Usage

### Modern Alternative
```bash
# GET request
xh httpbin.org/get

# POST JSON
xh POST httpbin.org/post name=John age=30

# Custom headers
xh GET httpbin.org/headers User-Agent:MyApp

# Download
xh --download example.com/file.zip

# Form data
xh --form POST httpbin.org/post name=John
```

## Configured Aliases

### HTTPie Shortcuts
- `GET` - http GET
- `POST` - http POST  
- `PUT` - http PUT
- `PATCH` - http PATCH
- `DELETE` - http DELETE
- `HEAD` - http HEAD

### curl Shortcuts
- `curl-json` - curl with JSON headers
- `curl-post` - curl POST
- `curl-put` - curl PUT
- `curl-delete` - curl DELETE
- `curl-headers` - Headers only
- `curl-verbose` - Verbose output
- `curl-download` - Download file

### Functions
- `api-get <url>` - GET request with HTTPie
- `api-post <url>` - POST request with HTTPie
- `api-test <url>` - Test API endpoint
- `api-bench <url> [requests] [concurrency]` - Benchmark endpoint
- `download <url> [output]` - Download with resume
- `upload <file> [url]` - Upload file
- `http-status <url>` - Check HTTP status code
- `http-time <url>` - Measure request timing
- `bearer <token> <url>` - Request with Bearer token
- `basic-auth <user> <pass> <url>` - Basic authentication

## API Testing Workflows

### REST API Testing
```bash
# Test CRUD operations
BASE="http://localhost:8080/api"

# Create
http POST $BASE/items name="Test Item"

# Read
http GET $BASE/items/1

# Update  
http PUT $BASE/items/1 name="Updated Item"

# Delete
http DELETE $BASE/items/1

# List
http GET $BASE/items
```

### GraphQL Testing
```bash
# Query
http POST localhost:4000/graphql \
  query='{ users { id name email } }'

# Mutation
http POST localhost:4000/graphql \
  query='mutation { 
    createUser(input: {name: "John", email: "john@example.com"}) {
      id name email
    }
  }'

# With variables
http POST localhost:4000/graphql \
  query='query GetUser($id: ID!) { user(id: $id) { name } }' \
  variables:='{"id": "1"}'
```

### WebSocket Testing
```bash
# If websocat is installed
websocat ws://localhost:8080/ws

# Send message
echo "Hello WebSocket" | websocat ws://localhost:8080/ws
```

## Performance Testing

### Simple Benchmarking
```bash
# Using Apache Bench (if installed)
ab -n 1000 -c 10 http://localhost:8080/

# Using hey (if installed)
hey -n 1000 -c 10 http://localhost:8080/

# Using curl in a loop
for i in {1..100}; do
  curl -w "%{time_total}\n" -o /dev/null -s http://localhost:8080/
done | awk '{sum+=$1} END {print sum/NR}'
```

### Load Testing
```bash
# Parallel requests with xargs
seq 1 100 | xargs -P 10 -I {} curl -s http://localhost:8080/ > /dev/null

# Measure response times
http-time http://localhost:8080/
```

## Debugging

### Verbose Output
```bash
# HTTPie verbose
http --verbose GET httpbin.org/get

# curl verbose
curl -v https://httpbin.org/get

# Include headers in output
http --print=HhBb GET httpbin.org/get
```

### Request Inspection
```bash
# See what would be sent
http --offline POST httpbin.org/post name=value

# curl dry run
curl --trace-ascii - https://httpbin.org/get
```

## Tips

1. **Use HTTPie for JSON APIs** - Automatic formatting and highlighting
2. **Use curl for scripts** - More portable and scriptable
3. **Use xh for speed** - Fastest option for simple requests
4. **Save sessions** - HTTPie sessions for stateful testing
5. **Learn curl options** - Most versatile and widely available
6. **Pretty print JSON** - Pipe to `jq` for formatting
7. **Use aliases** - Speed up common operations
8. **Check status codes** - Use `http-status` function
9. **Measure performance** - Use `http-time` for timing
10. **Test locally first** - Use httpbin.org for testing

## Common Issues

### SSL Certificate Errors
```bash
# HTTPie - skip verification (dev only!)
http --verify=no https://localhost:8443

# curl - skip verification (dev only!)
curl -k https://localhost:8443
```

### Proxy Configuration
```bash
# HTTPie
http --proxy=http:http://proxy:8080 httpbin.org/get

# curl
curl -x http://proxy:8080 httpbin.org/get

# Environment variables
export HTTP_PROXY=http://proxy:8080
export HTTPS_PROXY=http://proxy:8080
```

### Timeout Issues
```bash
# HTTPie timeout
http --timeout=60 slow-api.example.com

# curl timeout
curl --connect-timeout 5 --max-time 30 slow-api.example.com
```

## Examples

Example scripts are available in `~/.config/http/templates/`:
- `api-test.sh` - Complete API testing script
- `session-example.sh` - HTTPie session management
- `curl-examples.sh` - Common curl patterns
- `graphql.sh` - GraphQL query examples