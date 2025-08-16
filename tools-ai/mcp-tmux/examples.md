# Tmux MCP Server Examples

This document provides practical examples of how to use the Tmux MCP Server with Claude CLI.

## Basic Operations

### Listing Sessions

**Claude Command:**
```
List all my tmux sessions with details
```

**What happens:**
- Claude uses `tmux_list_sessions` with `include_details: true`
- Returns information about all sessions, windows, and panes
- Shows which processes are running in each pane

**Example Response:**
```json
{
  "sessions": [
    {
      "name": "development",
      "id": "$0",
      "created": "2024-01-15T10:30:00.000Z",
      "attached": true,
      "windowCount": 2,
      "windows": [
        {
          "index": 0,
          "name": "main",
          "paneCount": 3,
          "active": true,
          "panes": [
            {
              "index": 0,
              "command": "nvim",
              "pid": 12345,
              "active": true,
              "width": 120,
              "height": 30
            }
          ]
        }
      ]
    }
  ]
}
```

### Reading Pane Contents

**Claude Command:**
```
Show me what's in pane 1 of my development session
```

**What happens:**
- Claude uses `tmux_read_pane` with session "development", window "0", pane "1"
- Returns the last 100 lines of content from that pane
- Includes pane information and metadata

**Example Usage:**
```
Read the last 50 lines from the logs pane in my monitoring session
```

### Sending Commands

**Claude Command:**
```
Run "npm test" in pane 2 of my development session
```

**What happens:**
- Claude uses `tmux_send_command` to send the command
- Command is executed in the specified pane
- Returns confirmation of successful execution

## Development Workflows

### Setting Up a Development Environment

**Claude Command:**
```
Create a new development session called "webapp" with the following layout:
- Main pane for the editor
- Split right pane for the development server
- Split the right pane again for running tests
- Start the dev server and test watcher
```

**What happens:**
1. `tmux_create_session` creates "webapp" session
2. `tmux_split_pane` creates vertical split
3. `tmux_split_pane` creates horizontal split on right side
4. `tmux_send_command` starts editor in left pane
5. `tmux_send_command` starts dev server in top-right pane
6. `tmux_send_command` starts test watcher in bottom-right pane

### Monitoring Multiple Services

**Claude Command:**
```
Check the status of all services in my production monitoring session. Look for any errors or warnings in the recent output of each pane.
```

**What happens:**
1. `tmux_list_sessions` gets session details
2. `tmux_read_pane` reads from each pane in the monitoring session
3. Claude analyzes the content for error patterns
4. Reports any issues found across all monitored services

### Debugging Session Setup

**Claude Command:**
```
Set up a debugging session for my Python application:
- Create session called "debug-app"
- Split into 4 panes
- Top-left: code editor
- Top-right: Python debugger
- Bottom-left: application logs
- Bottom-right: interactive Python shell
```

**What happens:**
1. Creates new session with `tmux_create_session`
2. Multiple `tmux_split_pane` calls create the layout
3. Sends appropriate commands to each pane
4. Results in a comprehensive debugging environment

## Advanced Use Cases

### Cross-Session Analysis

**Claude Command:**
```
Analyze all my development sessions and tell me:
1. Which sessions have running servers
2. Any failed tests in test runners
3. Recent error messages across all sessions
4. Resource usage patterns
```

**What happens:**
1. Lists all sessions and their panes
2. Reads content from panes running relevant processes
3. Analyzes output for specific patterns
4. Provides comprehensive development environment status

### Automated Environment Restoration

**Claude Command:**
```
I need to recreate my usual development setup. Create:
1. "frontend" session with React dev server and tests
2. "backend" session with API server and database
3. "monitoring" session watching logs from both
4. Start all necessary processes
```

**What happens:**
1. Creates multiple sessions with appropriate names
2. Sets up specific layouts for each session type
3. Starts all required development processes
4. Configures monitoring to watch all services

### Log Analysis and Monitoring

**Claude Command:**
```
Monitor my production logs in real-time. Check the logs pane every 30 seconds and alert me if:
- Error rates increase
- Response times spike
- Any critical errors appear
- Database connection issues occur
```

**What happens:**
1. Continuously reads from designated log panes
2. Analyzes content for specified patterns
3. Tracks metrics over time
4. Provides intelligent alerting based on trends

## Specific Examples by Development Type

### Web Development

**Setup Command:**
```
Set up my standard web development environment for a React/Node.js project
```

**Result:**
- Session: "webdev"
- Pane 0: Code editor (nvim/vscode)
- Pane 1: React development server (`npm start`)
- Pane 2: Node.js API server (`npm run server`)
- Pane 3: Test runner (`npm run test:watch`)
- Pane 4: Git operations and terminal commands

### Data Science

**Setup Command:**
```
Create a data analysis environment for my Python project
```

**Result:**
- Session: "datascience"
- Pane 0: Jupyter notebook server
- Pane 1: Python REPL/IPython
- Pane 2: Data processing scripts
- Pane 3: Model training monitoring
- Pane 4: Resource monitoring (htop/nvidia-smi)

### DevOps/Infrastructure

**Setup Command:**
```
Set up monitoring for my Kubernetes cluster
```

**Result:**
- Session: "k8s-monitor"
- Pane 0: kubectl commands and cluster info
- Pane 1: Pod logs streaming
- Pane 2: Resource monitoring
- Pane 3: Application metrics
- Pane 4: Alert monitoring

### Microservices Development

**Setup Command:**
```
Create a development environment for my microservices architecture with 5 different services
```

**Result:**
- Session: "microservices"
- Multiple windows, each dedicated to a service:
  - Window 0: API Gateway (panes for code, server, logs)
  - Window 1: User Service (panes for code, server, database)
  - Window 2: Order Service (similar layout)
  - Window 3: Payment Service (similar layout)
  - Window 4: Notification Service (similar layout)
  - Window 5: Infrastructure (docker-compose, monitoring, logs)

## Interactive Debugging Examples

### Finding and Fixing Issues

**Claude Command:**
```
My tests are failing. Help me debug by:
1. Showing me the test output
2. Identifying which tests are failing
3. Reading the application logs for errors
4. Suggesting what might be wrong
```

**Process:**
1. Reads test runner pane output
2. Analyzes failure messages and stack traces
3. Checks application server logs for related errors
4. Correlates timing of errors with test failures
5. Provides specific debugging suggestions

### Performance Investigation

**Claude Command:**
```
My application seems slow. Help me investigate by checking:
1. Server response times in the logs
2. Database query performance
3. System resource usage
4. Any bottlenecks in the request pipeline
```

**Process:**
1. Reads server logs from multiple panes
2. Analyzes response time patterns
3. Checks database logs for slow queries
4. Monitors system resources across panes
5. Identifies performance bottlenecks

## Team Collaboration Examples

### Code Review Sessions

**Claude Command:**
```
Set up a code review session where I can:
1. View the code changes
2. Run tests for the modified code
3. Monitor the application behavior
4. Check for any integration issues
```

**Setup:**
- Dedicated session for the review
- Panes for diff viewing, test execution, app monitoring
- Ability to quickly switch between different views

### Pair Programming

**Claude Command:**
```
Create a pair programming environment with:
1. Shared code editing view
2. Separate test execution
3. Application monitoring
4. Communication tools running
```

**Features:**
- Optimized layout for collaboration
- Easy switching between driver/navigator roles
- Comprehensive monitoring of all aspects

## Automation and Workflows

### Daily Startup Routine

**Claude Command:**
```
Run my daily development startup routine:
1. Start all my usual sessions
2. Pull latest code in each project
3. Start development servers
4. Run initial tests
5. Open monitoring dashboards
```

**Automation:**
- Scripted session creation
- Automated git operations
- Service startup orchestration
- Health checks and verification

### End-of-Day Cleanup

**Claude Command:**
```
Clean up my development environment:
1. Save any unsaved work
2. Stop running services
3. Commit work in progress
4. Create session snapshots for tomorrow
5. Kill unnecessary sessions
```

**Process:**
- Intelligent work detection and saving
- Graceful service shutdown
- Automated git operations
- Session state preservation

## Error Handling and Recovery

### Session Recovery

**Claude Command:**
```
My tmux session crashed. Help me recover by:
1. Checking what sessions are still running
2. Recreating my development environment
3. Restoring my previous work state
4. Restarting necessary services
```

**Recovery Process:**
- Assessment of current state
- Intelligent environment recreation
- Work state restoration
- Service health verification

### Process Monitoring

**Claude Command:**
```
Monitor all my development processes and alert me if:
1. Any service stops unexpectedly
2. Tests start failing
3. Build processes encounter errors
4. System resources become constrained
```

**Monitoring Features:**
- Continuous health checking
- Intelligent alerting
- Automatic recovery suggestions
- Performance trend analysis

These examples demonstrate the power and flexibility of the Tmux MCP Server integration with Claude CLI, enabling sophisticated terminal workspace management and development workflow automation.