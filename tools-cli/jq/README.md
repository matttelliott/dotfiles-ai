# jq Configuration

A lightweight and flexible command-line JSON processor.

## Features

- Parse and transform JSON data
- Extract specific fields from JSON
- Filter and map JSON arrays
- Combine multiple JSON sources
- Pretty-print JSON output

## Installation

```bash
./jq/setup.sh
```

## Common Usage

### Pretty-print JSON
```bash
curl https://api.github.com/users/github | jq .
```

### Extract specific field
```bash
echo '{"name": "John", "age": 30}' | jq .name
```

### Filter arrays
```bash
echo '[1,2,3,4,5]' | jq '.[] | select(. > 2)'
```

### Transform data
```bash
echo '{"first": "John", "last": "Doe"}' | jq '{name: (.first + " " + .last)}'
```

### Parse GitHub API
```bash
curl https://api.github.com/repos/user/repo/releases/latest | jq '.tag_name'
```

## Advanced Examples

### Extract multiple fields
```bash
cat package.json | jq '{name: .name, version: .version, deps: .dependencies}'
```

### Array to CSV
```bash
echo '[{"name":"Alice","age":30},{"name":"Bob","age":25}]' | jq -r '.[] | [.name, .age] | @csv'
```

### Conditional processing
```bash
cat data.json | jq 'if .status == "active" then .data else empty end'
```

## Custom Modules

Create reusable jq functions in `~/.config/jq/modules.jq`:

```jq
def extract_urls: 
  .. | strings | select(test("https?://"));

def to_lowercase:
  ascii_downcase;
```

## Integration with Other Tools

### With curl
```bash
curl -s https://api.example.com/data | jq '.results[] | {id, name}'
```

### With Docker
```bash
docker inspect container_name | jq '.[0].State'
```

### With AWS CLI
```bash
aws ec2 describe-instances | jq '.Reservations[].Instances[] | {id: .InstanceId, type: .InstanceType}'
```

## Tips

1. Use `-r` for raw output (no quotes)
2. Use `-c` for compact output
3. Use `-s` to slurp entire input into array
4. Use `--tab` for tab-indented output
5. Pipe to `jq` for any JSON processing needs