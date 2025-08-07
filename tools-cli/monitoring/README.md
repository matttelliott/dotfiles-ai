# System Monitoring Tools

Comprehensive system monitoring and resource analysis tools for performance optimization and troubleshooting.

## Installation

```bash
./tools-cli/monitoring/setup.sh
```

## What Gets Installed

### Process Monitoring
- **htop** - Interactive process viewer with CPU/memory meters
- **btop++** - Modern resource monitor with graphs and themes
- **glances** - Cross-platform monitoring tool with web UI
- **procs** - Modern ps replacement written in Rust
- **bottom** - Yet another system monitor with vi keybindings

### Disk & Storage
- **ncdu** - NCurses disk usage analyzer
- **duf** - Better df alternative with color output
- **iotop** - I/O usage monitor (Linux only)

### Network Monitoring
- **nethogs** - Network bandwidth by process
- **bmon** - Bandwidth monitor with graphs
- **iftop** - Display bandwidth usage by connection

## Quick Usage

### Process Monitoring

#### htop
```bash
htop                    # Launch htop
htop -u username        # Show only user's processes
htop -p PID1,PID2       # Monitor specific PIDs
```

**Key bindings:**
- `F1` - Help
- `F2` - Setup/Configure
- `F3` - Search process
- `F4` - Filter
- `F5` - Tree view
- `F6` - Sort by column
- `F9` - Kill process
- `F10` - Quit

#### btop
```bash
btop                    # Launch btop
btop -p 1               # Preset 1 (CPU)
btop -t                 # TTY mode
```

**Key bindings:**
- `Esc/q` - Quit
- `h` - Help
- `o` - Options
- `p` - Toggle processes
- `d` - Toggle disks
- `n` - Toggle network
- `m` - Toggle mem/swap

#### glances
```bash
glances                 # Terminal UI
glances -w              # Web server mode (port 61208)
glances -1              # 1-second refresh
glances --export csv    # Export to CSV
```

**Key bindings:**
- `q/Esc` - Quit
- `1` - Global CPU
- `2` - Per-CPU
- `m` - Sort by memory
- `p` - Sort by name
- `i` - Sort by I/O rate
- `d` - Show/hide disk I/O
- `n` - Show/hide network

### Disk Usage

#### ncdu
```bash
ncdu /                  # Analyze root filesystem
ncdu -x /               # Stay on same filesystem
ncdu -r /path           # Read-only mode
ncdu -o file.json /     # Export to JSON
```

**Key bindings:**
- `↑/↓` - Navigate
- `→/Enter` - Enter directory
- `←` - Go back
- `d` - Delete (if not read-only)
- `n` - Sort by name
- `s` - Sort by size
- `g` - Show graph
- `i` - Show info
- `q` - Quit

#### duf
```bash
duf                     # Show all filesystems
duf /home /var          # Specific paths
duf --only local        # Local filesystems only
duf --json              # JSON output
duf --theme dark        # Dark theme
```

### Network Monitoring

#### nethogs
```bash
sudo nethogs            # Monitor all interfaces
sudo nethogs eth0       # Specific interface
sudo nethogs -d 5       # 5-second delay
sudo nethogs -v 1       # KB/s mode
```

**Key bindings:**
- `q` - Quit
- `s` - Sort by sent
- `r` - Sort by received
- `m` - Switch units (KB/s, MB/s)

#### bmon
```bash
bmon                    # Launch bmon
bmon -p eth0            # Specific interface
bmon -r 1               # 1-second rate
bmon -o curses          # Output format
```

**Key bindings:**
- `q` - Quit
- `g` - Show graphs
- `d` - Detailed view
- `i` - Info screen
- `?` - Help

## Configured Aliases

### Quick Access
- `h` - htop
- `bt` - btop
- `g` - glances
- `nc` - ncdu
- `df` - duf (replaces traditional df)
- `ps` - procs (replaces traditional ps)
- `top` - htop (replaces traditional top)

### Monitoring Functions
- `sysinfo` - Complete system information
- `health` - System health check
- `monitor <process>` - Watch specific process
- `topmem [n]` - Top n memory consumers
- `topcpu [n]` - Top n CPU consumers
- `diskusage [path] [n]` - Top n space users
- `ports` - Show listening ports
- `load` - System load and CPU cores
- `temp` - Temperature (if available)
- `connections` - Active network connections
- `watchio` - Monitor disk I/O

### Process Management
- `psg <pattern>` - grep processes
- `kill9 <pid>` - Force kill
- `killall <name>` - Kill by name

## Configuration Files

### htop Configuration
Located at `~/.config/htop/htoprc`:
- CPU meters configuration
- Color scheme settings
- Column display preferences
- Sort preferences

### glances Configuration
Located at `~/.config/glances/glances.conf`:
- Refresh rate
- Alert thresholds
- Module visibility
- Network interface filters

## Advanced Usage

### System Health Check Script
```bash
health() {
    echo "=== System Health Check ==="
    echo
    echo "Load Average:"
    uptime
    echo
    echo "Memory Usage:"
    free -h
    echo
    echo "Disk Usage:"
    df -h | grep -E "^/dev/"
    echo
    echo "Top Processes:"
    ps aux | sort -rk 3 | head -5
}
```

### Resource Monitoring Dashboard
```bash
# Terminal 1: CPU and Memory
htop

# Terminal 2: Disk I/O
sudo iotop

# Terminal 3: Network
sudo nethogs

# Terminal 4: System overview
glances
```

### Performance Analysis
```bash
# CPU bottleneck detection
top -o %CPU | head -20

# Memory leak detection
watch -n 1 'ps aux | sort -rk 4 | head -10'

# Disk I/O patterns
iotop -o -P -a

# Network bandwidth per process
sudo nethogs -d 1
```

## Monitoring Strategies

### 1. Baseline Establishment
```bash
# Capture normal system metrics
glances --export csv --export-csv-file baseline.csv

# Record for 1 hour
timeout 3600 glances --export csv
```

### 2. Troubleshooting High Load
```bash
# Check load average
uptime

# Identify CPU consumers
htop -s PERCENT_CPU

# Check I/O wait
iostat -x 1

# Memory pressure
vmstat 1
```

### 3. Memory Analysis
```bash
# Memory by process
ps aux --sort=-%mem | head

# Detailed memory info
cat /proc/meminfo

# Cache and buffers
free -h

# Memory maps
pmap -x PID
```

### 4. Disk Performance
```bash
# Disk usage by directory
ncdu /

# I/O statistics
iostat -x 1

# Process I/O
iotop -o

# Filesystem usage
df -i  # Check inodes
```

### 5. Network Analysis
```bash
# Bandwidth by process
sudo nethogs

# Connection states
ss -tan | awk '{print $1}' | sort | uniq -c

# Network statistics
netstat -s

# Interface statistics
ip -s link
```

## Integration with Other Tools

### Logging and Alerting
```bash
# Log system metrics
glances --export influxdb

# Email alerts
glances --export mail

# SNMP export
glances --export snmp
```

### Automation
```bash
# Kill high memory process
ps aux | sort -rk 4 | head -1 | awk '{print $2}' | xargs kill

# Auto-restart service on high load
if [[ $(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1) > 5 ]]; then
    systemctl restart service
fi
```

## Performance Tuning

### CPU Optimization
```bash
# Check CPU frequency
cat /proc/cpuinfo | grep MHz

# CPU governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Set performance mode
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### Memory Optimization
```bash
# Clear caches
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

# Swappiness
cat /proc/sys/vm/swappiness
echo 10 | sudo tee /proc/sys/vm/swappiness
```

### Disk Optimization
```bash
# I/O scheduler
cat /sys/block/sda/queue/scheduler

# Read-ahead
blockdev --getra /dev/sda
blockdev --setra 256 /dev/sda
```

## Tips

1. **Learn htop colors** - Red=kernel, green=user, blue=low priority
2. **Use tree view** - F5 in htop shows process hierarchy
3. **Filter processes** - F4 in htop for specific processes
4. **Export metrics** - glances can export to CSV, InfluxDB, etc.
5. **Watch patterns** - Combine with watch command for custom monitoring
6. **Set alerts** - Configure thresholds in glances
7. **Use nice/renice** - Adjust process priorities
8. **Monitor trends** - Not just current values
9. **Check logs** - Correlate with system logs
10. **Automate responses** - Script common fixes

## Troubleshooting

### High CPU Usage
1. Identify process: `htop` → Sort by CPU
2. Check threads: `htop` → F2 → Display options → Show threads
3. Trace syscalls: `strace -p PID`
4. Profile: `perf top -p PID`

### Memory Issues
1. Check usage: `free -h`
2. Find leaks: `valgrind --leak-check=full program`
3. Clear cache: `sync && echo 3 | sudo tee /proc/sys/vm/drop_caches`
4. Check OOM killer: `dmesg | grep -i "killed process"`

### Disk Problems
1. Check space: `df -h` and `df -i`
2. Find large files: `ncdu /` or `find / -size +1G`
3. Check I/O: `iotop -o`
4. Test speed: `dd if=/dev/zero of=test bs=1M count=1000`

### Network Issues
1. Check bandwidth: `nethogs`
2. Connection count: `ss -tan | wc -l`
3. Packet loss: `ping -c 100 google.com`
4. DNS resolution: `time nslookup google.com`