# PostgreSQL Client Tools

Complete PostgreSQL client setup with enhanced CLI and utilities.

## Installation

```bash
./tools-cli/postgres/setup.sh
```

## What Gets Installed

### Core Tools
- **PostgreSQL Client** - psql and related tools
- **pg_dump/pg_restore** - Backup and restore utilities
- **pgcli** - Enhanced PostgreSQL CLI with auto-completion

### Configuration
- **~/.psqlrc** - psql configuration with useful aliases
- **~/.pgpass** - Secure password storage (chmod 600)
- **~/.psqlrc.d/** - Additional configuration modules

## Basic Usage

### Connecting to Database
```bash
# Basic connection
psql -U username -h hostname -d database

# Connection string
psql "postgresql://user:pass@localhost:5432/dbname"

# With pgcli (enhanced)
pgcli -U username -h hostname -d database

# Using aliases
pgconnect localhost 5432 mydb myuser
```

### Common Operations
```bash
# List databases
psql -l
pgl  # alias

# Execute query
psql -c "SELECT * FROM users"

# Execute file
psql -f script.sql

# Interactive mode
psql
\l              # List databases
\c dbname       # Connect to database
\dt             # List tables
\d tablename    # Describe table
\q              # Quit
```

## Configured Aliases

### Connection
- `psql` - psql -U postgres (default user)
- `pg` - psql shorthand
- `pgd` - psql -d (with database)
- `pgl` - List all databases

### Information
- `pgdu` - Show database sizes
- `pgt` - List all tables

### Functions
- `pgconnect host port db user` - Connect with parameters
- `pgdump database` - Backup database with timestamp
- `pgrestore database file` - Restore from backup
- `pgsize database` - Show table sizes
- `pgkill pid` - Terminate backend process

## psqlrc Configuration

### Display Settings
- Unicode borders for tables
- NULL values shown as ¤
- Auto-expanded display for wide tables
- Query execution timing enabled
- Per-database history files

### Quick Commands
Type these in psql:
```sql
:version        -- PostgreSQL version
:extensions     -- Available extensions
:tables         -- List user tables
:indexes        -- List indexes
:dbsize         -- Database sizes
:tablesize      -- Table sizes
:locks          -- Show blocking queries
:activity       -- Active queries
:slow_queries   -- Slowest queries (requires pg_stat_statements)
```

## pgcli Features

### Auto-completion
- Table names
- Column names
- SQL keywords
- Function names
- File paths

### Smart Features
```bash
# Launch pgcli
pgcli -U user -h host -d database

# Features:
# - Syntax highlighting
# - Smart completion
# - Multi-line queries
# - Query history
# - Special commands (\d, \l, etc.)
```

### Key Bindings
- `Tab` - Auto-complete
- `Ctrl+R` - Search history
- `F3` - Toggle multiline
- `Ctrl+D` - Exit

## Backup and Restore

### Backup Database
```bash
# Full backup
pg_dump -U postgres dbname > backup.sql
pgdump dbname  # Using function (adds timestamp)

# Compressed backup
pg_dump -U postgres -Fc dbname > backup.dump

# Schema only
pg_dump -U postgres -s dbname > schema.sql

# Data only
pg_dump -U postgres -a dbname > data.sql

# Specific tables
pg_dump -U postgres -t table1 -t table2 dbname > tables.sql
```

### Restore Database
```bash
# From SQL file
psql -U postgres dbname < backup.sql
pgrestore dbname backup.sql  # Using function

# From compressed dump
pg_restore -U postgres -d dbname backup.dump

# Create database first
createdb -U postgres newdb
psql -U postgres newdb < backup.sql
```

## Query Optimization

### Explain Plans
```sql
EXPLAIN SELECT * FROM users;
EXPLAIN ANALYZE SELECT * FROM users;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users;
```

### Index Usage
```sql
-- Find missing indexes
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
  AND n_distinct > 100
  AND correlation < 0.1
ORDER BY n_distinct DESC;

-- Index usage stats
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan;
```

## Performance Monitoring

### Active Queries
```sql
-- Currently running queries
SELECT pid, usename, application_name, client_addr, query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY query_start;

-- Long running queries
SELECT pid, now() - query_start AS duration, query
FROM pg_stat_activity
WHERE state != 'idle'
  AND now() - query_start > interval '1 minute'
ORDER BY duration DESC;
```

### Blocking Queries
```sql
-- Find blocking queries
SELECT 
  blocking.pid AS blocking_pid,
  blocking.query AS blocking_query,
  blocked.pid AS blocked_pid,
  blocked.query AS blocked_query
FROM pg_stat_activity AS blocked
JOIN pg_stat_activity AS blocking
  ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));
```

### Kill Query
```sql
-- Terminate connection
SELECT pg_terminate_backend(pid);

-- Cancel query
SELECT pg_cancel_backend(pid);
```

## Security

### Password File
```bash
# Create .pgpass file
echo "hostname:port:database:username:password" >> ~/.pgpass
chmod 600 ~/.pgpass

# Format
localhost:5432:mydb:myuser:mypass
*:5432:*:postgres:adminpass
```

### SSL Connections
```bash
# Require SSL
psql "postgresql://user@host/db?sslmode=require"

# With certificate
psql "postgresql://user@host/db?sslmode=verify-full&sslcert=client.crt&sslkey=client.key"
```

## Common Tasks

### User Management
```sql
-- Create user
CREATE USER myuser WITH PASSWORD 'mypass';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO myuser;

-- Change password
ALTER USER myuser WITH PASSWORD 'newpass';
```

### Database Management
```sql
-- Create database
CREATE DATABASE mydb OWNER myuser;

-- Drop database
DROP DATABASE mydb;

-- Rename database
ALTER DATABASE oldname RENAME TO newname;
```

### Table Operations
```sql
-- Vacuum and analyze
VACUUM ANALYZE tablename;

-- Reindex
REINDEX TABLE tablename;

-- Table size
SELECT pg_size_pretty(pg_total_relation_size('tablename'));
```

## Tips

1. **Use pgcli** for interactive work - better than psql
2. **Set up .pgpass** - Avoid typing passwords
3. **Use transactions** - BEGIN/COMMIT/ROLLBACK
4. **Monitor connections** - pg_stat_activity
5. **Regular VACUUM** - Maintain performance
6. **Create indexes** - But not too many
7. **Use EXPLAIN** - Understand query plans
8. **Backup regularly** - Automate with cron
9. **Test restores** - Backups are only good if they work
10. **Monitor logs** - Set up proper log_statement

## Troubleshooting

### Connection Issues
```bash
# Test connection
psql -U postgres -h localhost -c "SELECT 1"

# Check PostgreSQL service
sudo systemctl status postgresql
sudo service postgresql status  # Older systems

# Check port
netstat -an | grep 5432
lsof -i :5432
```

### Permission Denied
```sql
-- Check user permissions
\du  -- List users
\l   -- List databases with permissions

-- Grant permissions
GRANT CONNECT ON DATABASE dbname TO username;
GRANT USAGE ON SCHEMA public TO username;
```

### Performance Issues
```sql
-- Check slow queries
SELECT * FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;

-- Check table bloat
SELECT schemaname, tablename, 
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Run VACUUM
VACUUM ANALYZE;
```