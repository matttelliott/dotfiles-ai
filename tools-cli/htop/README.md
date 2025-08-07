# htop - Interactive Process Viewer

An interactive process viewer and system monitor with a better UI than top.

## Installation

```bash
./tools-cli/htop/setup.sh
```

## Features

- **Interactive UI** - Mouse support and function keys
- **Process tree** - Hierarchical view of processes
- **Color coding** - Visual CPU and memory usage
- **Sorting** - Sort by any column
- **Filtering** - Search and filter processes
- **Killing** - Send signals to processes
- **Customizable** - Configure meters and display

## Key Bindings

### Navigation
- `↑/↓` or `j/k` - Move cursor
- `←/→` or `h/l` - Scroll horizontally
- `PgUp/PgDn` - Page up/down
- `Home/End` - Jump to top/bottom
- `Space` - Tag/untag process
- `U` - Untag all
- `c` - Tag process and children

### Views
- `t` or `F5` - Tree view toggle
- `H` - Hide/show user threads
- `K` - Hide/show kernel threads
- `p` - Show full paths
- `F2` or `S` - Setup screen

### Actions
- `F9` or `k` - Kill process (send signal)
- `F7/F8` or `]/[` - Nice value (priority) +/-
- `I` - Invert sort order
- `F6` or `>` - Select sort column
- `u` - Filter by user
- `F4` or `\` - Filter processes
- `F3` or `/` - Search processes
- `F1` or `h` - Help
- `F10` or `q` - Quit

### Process manipulation
- `F8` - Increase nice value (lower priority)
- `F7` - Decrease nice value (higher priority)
- `a` - Set CPU affinity
- `e` - Show environment
- `i` - Set IO priority
- `l` - List open files (lsof)
- `s` - Trace syscalls (strace)

## Display Elements

### Header Meters
- **CPU bars** - Usage per core
- **Memory bar** - RAM usage
- **Swap bar** - Swap usage
- **Tasks** - Process counts
- **Load average** - System load
- **Uptime** - System uptime

### Process Columns
- `PID` - Process ID
- `USER` - Process owner
- `PRI` - Priority
- `NI` - Nice value
- `VIRT` - Virtual memory
- `RES` - Resident memory
- `SHR` - Shared memory
- `S` - State (R/S/D/Z/T)
- `CPU%` - CPU usage
- `MEM%` - Memory usage
- `TIME+` - CPU time used
- `Command` - Process name/command

## Process States
- `R` - Running
- `S` - Sleeping
- `D` - Disk sleep (uninterruptible)
- `Z` - Zombie
- `T` - Traced/stopped
- `I` - Idle kernel thread

## Common Usage

### Basic monitoring
```bash
htop                    # Launch htop
htop -d 10             # Update every second (tenths)
htop -u username       # Show only user's processes
htop -p PID1,PID2      # Monitor specific PIDs
```

### Tree view
```bash
htop -t                # Start in tree view
# Then press 't' to toggle
```

### Configuration
```bash
# Press F2 to enter setup
# Configure meters, colors, columns
# Settings saved to ~/.config/htop/htoprc
```

## Configured Aliases

- `top` - Aliased to htop
- `htop-tree` - Start in tree view
- `htop-user` - Show only current user

## Color Meanings

### CPU bars
- **Blue** - Low priority processes
- **Green** - Normal processes
- **Red** - Kernel processes
- **Orange** - IRQ time
- **Magenta** - Soft IRQ time
- **Grey** - IO wait
- **Cyan** - Steal time (VMs)

### Memory bar
- **Green** - Used memory
- **Blue** - Buffers
- **Orange** - Cache

### Process highlighting
- **Green** - Your processes
- **Blue** - Low priority
- **Yellow** - Kernel threads
- **Red** - High priority
- **Cyan** - New processes
- **Magenta** - Modified processes

## Tips

1. **Tag multiple processes** - Space to tag, then act on all
2. **Follow process** - F to follow selected process
3. **Kill gracefully** - Try SIGTERM (15) before SIGKILL (9)
4. **Custom meters** - F2 to add CPU temp, battery, etc.
5. **Save config** - F2 settings are auto-saved
6. **Filter quickly** - Type to search as you type
7. **Sort smartly** - F6 then pick column
8. **Tree relationships** - t shows parent/child
9. **Monitor specific** - Use -p flag for PIDs
10. **Check threads** - H to toggle thread view

## Comparison with top

| Feature | top | htop |
|---------|-----|------|
| Interactive UI | Limited | Full |
| Mouse support | No | Yes |
| Color coding | Basic | Rich |
| Process tree | No | Yes |
| Scrolling | No | Yes |
| Search | No | Yes |
| Config save | Manual | Auto |
| Meters | Fixed | Custom |