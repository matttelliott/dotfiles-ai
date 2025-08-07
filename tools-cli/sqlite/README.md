# SQLite - Embedded Database Engine

Complete SQLite setup with enhanced CLI, utilities, and GUI tools.

## Installation

```bash
./tools-cli/sqlite/setup.sh
```

## What Gets Installed

### Core Tools
- **SQLite3** - Embedded SQL database engine
- **litecli** - Enhanced CLI with auto-completion and syntax highlighting
- **sqlite-utils** - CLI tool for manipulating SQLite databases
- **datasette** - Web-based interface for exploring SQLite data
- **DB Browser for SQLite** - GUI application for SQLite

### Configuration
- **~/.sqliterc** - SQLite CLI configuration
- **~/.config/litecli/config** - litecli settings
- **Templates** - Sample schemas and queries

## Basic Usage

### Command Line

```bash
# Open database
sqlite3 database.db

# Create in-memory database
sqlite3 :memory:

# Execute SQL file
sqlite3 database.db < script.sql

# Execute single query
sqlite3 database.db "SELECT * FROM users"

# Export to CSV
sqlite3 -csv -header database.db "SELECT * FROM users" > users.csv
```

### Interactive Commands

```sql
-- In sqlite3 prompt
.help               -- Show all commands
.tables             -- List tables
.schema             -- Show CREATE statements
.schema tablename   -- Show specific table
.indexes            -- List indexes
.mode column        -- Column output mode
.headers on         -- Show column headers
.quit               -- Exit
```

## Using litecli

### Enhanced Features
```bash
# Launch litecli
litecli database.db

# Features:
# - Auto-completion for tables, columns, keywords
# - Syntax highlighting
# - Multi-line editing
# - Smart completion
# - Query history
```

### Key Bindings
- `Tab` - Auto-complete
- `Ctrl+R` - Search history
- `F3` - Toggle multi-line
- `Ctrl+D` - Exit

## Using sqlite-utils

### Data Manipulation
```bash
# Insert JSON data
sqlite-utils insert database.db users users.json

# Insert CSV
sqlite-utils insert database.db users users.csv --csv

# Query as JSON
sqlite-utils rows database.db users --json

# Query as CSV
sqlite-utils rows database.db users --csv

# Create table from JSON
echo '[{"name": "Alice", "age": 30}]' | sqlite-utils insert database.db people -
```

### Schema Operations
```bash
# Create table
sqlite-utils create-table database.db posts \
  id integer \
  title text \
  content text \
  --pk id

# Add column
sqlite-utils add-column database.db users email text

# Create index
sqlite-utils create-index database.db users email

# Enable FTS (full-text search)
sqlite-utils enable-fts database.db posts title content
```

## Using datasette

### Web Interface
```bash
# Launch web server
datasette database.db

# With plugins
datasette database.db --plugins-dir plugins/

# Publish online
datasette publish heroku database.db
```

### Features
- Browse tables and views
- Execute SQL queries
- Export data (JSON, CSV)
- Visualizations
- API endpoints
- Plugin system

## Configured Aliases

### Basic
- `sq` - sqlite3
- `sql` - sqlite3
- `sqm` - sqlite3 :memory:
- `lite` - litecli

### Functions
- `sqopen db` - Open with better defaults
- `sqmem` - In-memory DB with sample data
- `sqbackup db` - Create timestamped backup
- `sqtables db` - List tables
- `sqschema db [table]` - Show schema
- `sqcount db table` - Count rows
- `sqjson db table` - Export as JSON
- `sqcsv db "query"` - Export as CSV
- `sqweb db` - Open in datasette
- `sqvacuum db` - Vacuum and analyze
- `sqintegrity db` - Check integrity

## Common Operations

### Creating Tables
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Indexes
```sql
-- Create index
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE UNIQUE INDEX idx_users_email ON users(email);

-- Analyze for query optimization
ANALYZE;
```

### Triggers
```sql
-- Update timestamp trigger
CREATE TRIGGER update_users_timestamp
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    UPDATE users SET updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.id;
END;
```

### Views
```sql
CREATE VIEW active_users AS
SELECT * FROM users
WHERE last_login > datetime('now', '-30 days');
```

## JSON Support

### JSON Functions
```sql
-- Store JSON
INSERT INTO data (json_col) VALUES (json('{"name": "Alice"}'));

-- Extract values
SELECT json_extract(json_col, '$.name') FROM data;

-- Update JSON
UPDATE data SET json_col = json_set(json_col, '$.age', 30);

-- Query JSON arrays
SELECT * FROM data WHERE json_extract(json_col, '$.tags[0]') = 'important';
```

## Full-Text Search

### Setup FTS
```sql
-- Create FTS table
CREATE VIRTUAL TABLE posts_fts USING fts5(
    title, 
    content,
    tokenize='porter unicode61'
);

-- Populate FTS
INSERT INTO posts_fts SELECT title, content FROM posts;

-- Search
SELECT * FROM posts_fts WHERE posts_fts MATCH 'sqlite';
SELECT * FROM posts_fts WHERE posts_fts MATCH 'title:database';
```

## Window Functions

### Examples
```sql
-- Row numbering
SELECT 
    ROW_NUMBER() OVER (ORDER BY score DESC) as rank,
    name, 
    score
FROM players;

-- Running totals
SELECT 
    date,
    amount,
    SUM(amount) OVER (ORDER BY date) as running_total
FROM transactions;

-- Moving average
SELECT 
    date,
    value,
    AVG(value) OVER (
        ORDER BY date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as moving_avg
FROM metrics;
```

## Common Table Expressions (CTEs)

### Recursive CTE
```sql
WITH RECURSIVE series(n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM series WHERE n < 10
)
SELECT n FROM series;

-- Hierarchical data
WITH RECURSIVE tree AS (
    SELECT id, name, parent_id, 0 as level
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    SELECT c.id, c.name, c.parent_id, t.level + 1
    FROM categories c
    JOIN tree t ON c.parent_id = t.id
)
SELECT * FROM tree ORDER BY level, name;
```

## Performance Optimization

### Query Planning
```sql
-- Explain query plan
EXPLAIN QUERY PLAN SELECT * FROM users WHERE email = 'alice@example.com';

-- Analyze tables
ANALYZE;

-- Update statistics
ANALYZE users;
```

### Optimization Tips
```sql
-- Use PRAGMA for performance
PRAGMA cache_size = 10000;
PRAGMA temp_store = MEMORY;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;

-- Vacuum regularly
VACUUM;

-- Check integrity
PRAGMA integrity_check;
PRAGMA foreign_key_check;
```

## Backup and Recovery

### Backup Methods
```bash
# SQL dump
sqlite3 database.db .dump > backup.sql

# Binary backup
sqlite3 database.db ".backup backup.db"

# Hot backup (while in use)
sqlite3 database.db "VACUUM INTO 'backup.db'"

# Incremental backup with sqlite-utils
sqlite-utils backup database.db backup.db
```

### Recovery
```bash
# From SQL dump
sqlite3 new_database.db < backup.sql

# From binary backup
cp backup.db database.db
```

## Migration Management

### Simple Migrations
```sql
-- Version tracking
CREATE TABLE IF NOT EXISTS schema_version (
    version INTEGER PRIMARY KEY,
    applied_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Apply migration
BEGIN TRANSACTION;
-- Your changes here
ALTER TABLE users ADD COLUMN status TEXT DEFAULT 'active';
INSERT INTO schema_version (version) VALUES (1);
COMMIT;
```

## Tips and Best Practices

1. **Use transactions** - Wrap multiple operations in BEGIN/COMMIT
2. **Enable foreign keys** - PRAGMA foreign_keys = ON
3. **Use prepared statements** - Prevent SQL injection
4. **Index wisely** - Index columns used in WHERE/JOIN
5. **VACUUM regularly** - Reclaim space and optimize
6. **Use WAL mode** - Better concurrency
7. **Monitor size** - SQLite works best under 1TB
8. **Backup frequently** - SQLite is a single file
9. **Test integrity** - Run PRAGMA integrity_check
10. **Use appropriate types** - INTEGER, TEXT, REAL, BLOB

## Troubleshooting

### Database Locked
```sql
-- Check for locks
PRAGMA busy_timeout = 5000;  -- 5 second timeout

-- Use WAL mode for better concurrency
PRAGMA journal_mode = WAL;
```

### Corruption Recovery
```bash
# Check integrity
sqlite3 database.db "PRAGMA integrity_check"

# Attempt recovery
sqlite3 database.db ".dump" | sqlite3 recovered.db

# Or use .recover command (SQLite 3.29+)
sqlite3 database.db ".recover" | sqlite3 recovered.db
```

### Performance Issues
```sql
-- Check slow queries
.timer on
SELECT * FROM large_table;

-- Analyze query plan
EXPLAIN QUERY PLAN SELECT * FROM users WHERE email = 'test@example.com';

-- Update statistics
ANALYZE;

-- Check indexes are being used
PRAGMA index_list(table_name);
PRAGMA index_info(index_name);
```

## GUI with DB Browser

### Features
- Visual table designer
- Browse/edit data
- Execute SQL queries
- Import/export data
- Visual query builder
- Database structure viewer

### Usage
```bash
# Launch GUI
sqlitebrowser database.db

# Or open from application menu
# "DB Browser for SQLite"
```