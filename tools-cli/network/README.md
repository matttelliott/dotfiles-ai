# Network Tools

Comprehensive network analysis, scanning, and diagnostic tools for troubleshooting and security testing.

## Installation

```bash
./tools-cli/network/setup.sh
```

## What Gets Installed

### Core Tools
- **nmap** - Network exploration and security auditing
- **netcat (nc)** - TCP/IP Swiss army knife
- **mtr** - Network diagnostic tool combining ping and traceroute
- **tcpdump** - Packet analyzer
- **iperf3** - Network bandwidth testing
- **dig** - DNS lookup utility
- **traceroute** - Trace packet route
- **whois** - Domain/IP information lookup
- **socat** - Multipurpose relay (SOcket CAT)
- **telnet** - Telnet client
- **speedtest** - Internet bandwidth testing
- **RustScan** - Modern, fast port scanner

## Quick Usage Guide

### Port Scanning with nmap

#### Basic Scans
```bash
# Quick scan
nmap target.com

# Scan specific ports
nmap -p 80,443 target.com

# Scan port range
nmap -p 1-1000 target.com

# Scan all ports
nmap -p- target.com
```

#### Advanced Scans
```bash
# Service version detection
nmap -sV target.com

# OS detection
nmap -O target.com

# Aggressive scan (OS, version, scripts, traceroute)
nmap -A target.com

# Stealth SYN scan
sudo nmap -sS target.com

# UDP scan
sudo nmap -sU target.com

# Network discovery (ping scan)
nmap -sn 192.168.1.0/24
```

### Using netcat

#### Port Testing
```bash
# Test if port is open
nc -zv google.com 80

# Scan port range
nc -zv target.com 20-30

# Banner grabbing
nc -nv target.com 80
```

#### File Transfer
```bash
# Receiver
nc -l 9999 > received_file

# Sender
nc target_ip 9999 < file_to_send
```

#### Chat/Communication
```bash
# Server
nc -l 9999

# Client
nc server_ip 9999
```

#### Simple Web Server
```bash
# Serve a file
{ echo -ne "HTTP/1.0 200 OK\r\n\r\n"; cat index.html; } | nc -l 8080
```

### Network Diagnostics with mtr

```bash
# Basic usage
mtr google.com

# Report mode (non-interactive)
mtr --report google.com

# Specify packet count
mtr --report --report-cycles 100 google.com

# Show IP addresses
mtr --show-ips google.com

# Use TCP instead of ICMP
mtr --tcp google.com
```

### Packet Analysis with tcpdump

```bash
# Capture all packets on interface
sudo tcpdump -i eth0

# Capture and save to file
sudo tcpdump -i any -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Filter by host
sudo tcpdump host 192.168.1.1

# Filter by port
sudo tcpdump port 80

# HTTP traffic (verbose)
sudo tcpdump -i any -A -s 0 'tcp port 80'

# DNS queries
sudo tcpdump -i any port 53

# Show packet contents in hex and ASCII
sudo tcpdump -XX -i eth0
```

### Bandwidth Testing with iperf3

```bash
# Server mode
iperf3 -s

# Client mode
iperf3 -c server_ip

# Test for 30 seconds
iperf3 -c server_ip -t 30

# Parallel streams
iperf3 -c server_ip -P 4

# Reverse mode (server sends)
iperf3 -c server_ip -R

# UDP test
iperf3 -c server_ip -u
```

### DNS Queries with dig

```bash
# Basic lookup
dig example.com

# Short answer
dig +short example.com

# Specific record type
dig example.com MX
dig example.com TXT
dig example.com NS

# Reverse lookup
dig -x 8.8.8.8

# Query specific nameserver
dig @8.8.8.8 example.com

# Trace DNS path
dig +trace example.com

# All records
dig example.com ANY
```

## Configured Aliases and Functions

### Quick Aliases
- `n` - nmap
- `ns` - nmap ping scan
- `np` - nmap port scan
- `nv` - nmap version detection
- `na` - nmap aggressive scan
- `d` - dig
- `dx` - dig +short
- `dns` - dig +trace
- `w` - whois

### Scanning Functions
- `scan-ports <host>` - Quick port scan
- `scan-all-ports <host>` - Scan all 65535 ports
- `scan-tcp <host>` - TCP connect scan
- `scan-udp <host>` - UDP scan (requires sudo)
- `scan-network [network]` - Scan local network
- `fast-scan <host>` - RustScan with nmap (if available)

### Network Information
- `myip` - Show public IP address
- `localip` - Show local IP addresses
- `ports` - Show listening ports
- `connections` - Show established connections
- `test-port <host> <port>` - Test if port is open

### DNS Functions
- `dns-lookup <domain>` - Multiple DNS tool lookup
- `reverse-dns <ip>` - Reverse DNS lookup
- `whois-ip <ip>` - Quick IP whois info

### Testing Functions
- `speed` - Run internet speed test
- `bandwidth [mode/host]` - iperf3 bandwidth test
- `net-debug <host>` - Complete network diagnosis
- `http-server [port]` - Quick Python HTTP server
- `tcp-server [port]` - Simple TCP server
- `tcp-client <host> <port>` - Connect to TCP server

### Packet Capture
- `capture [interface] [output]` - Capture packets to file
- `capture-http` - Capture HTTP traffic
- `capture-dns` - Capture DNS queries

### Proxy Functions
- `proxy-tcp <lport> <rhost> <rport>` - TCP proxy with socat

## Advanced Usage

### Network Mapping
```bash
# Discover hosts on network
nmap -sn 192.168.1.0/24

# Detailed network map
nmap -sn -PS21,22,25,80,443 192.168.1.0/24

# ARP scan (local network only)
sudo nmap -PR 192.168.1.0/24
```

### Service Enumeration
```bash
# HTTP headers
nc -nv target.com 80
HEAD / HTTP/1.0

# SMTP enumeration
nc -nv target.com 25
HELO test
VRFY root

# Banner grabbing multiple ports
for port in 21 22 25 80 443; do
  echo "Port $port:"
  nc -w 1 -v target.com $port
done
```

### Security Testing
```bash
# Check for common vulnerabilities
nmap --script vuln target.com

# SSL/TLS testing
nmap --script ssl* -p 443 target.com

# Check for default credentials
nmap --script default* target.com
```

### RustScan Usage
```bash
# Basic scan
rustscan -a target.com

# With nmap integration
rustscan -a target.com -- -sV -sC

# Custom ports
rustscan -a target.com -p 80,443

# Increase speed (ulimit)
rustscan -a target.com -u 5000
```

### Traffic Analysis
```bash
# Monitor HTTP traffic
sudo tcpdump -i any -s 0 -A 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

# Monitor specific host
sudo tcpdump -i any host 192.168.1.100

# Monitor network segment
sudo tcpdump -i eth0 net 192.168.1.0/24

# Save specific traffic
sudo tcpdump -i any -w http.pcap 'tcp port 80'
```

### Performance Testing
```bash
# Latency testing
ping -c 100 -i 0.2 target.com | tail -1

# Jitter testing
mtr --report --report-cycles 100 target.com

# Throughput testing
iperf3 -c server -t 60 -i 10

# Packet loss testing
ping -c 1000 -q target.com
```

## Troubleshooting Networks

### Connection Issues
```bash
# Full diagnosis
net-debug target.com

# Step by step:
# 1. Check DNS
dig target.com

# 2. Check routing
traceroute target.com

# 3. Check connectivity
ping target.com

# 4. Check ports
nmap -p 80,443 target.com

# 5. Check MTU
ping -M do -s 1472 target.com
```

### DNS Problems
```bash
# Check resolvers
cat /etc/resolv.conf

# Test different resolvers
dig @8.8.8.8 target.com
dig @1.1.1.1 target.com

# Clear DNS cache (macOS)
sudo dscacheutil -flushcache

# Clear DNS cache (Linux)
sudo systemd-resolve --flush-caches
```

### Network Performance
```bash
# Check interface statistics
netstat -i

# Check for errors
ifconfig | grep errors

# Check routing table
netstat -rn

# Check ARP table
arp -a
```

## Security Best Practices

1. **Always get permission** before scanning networks you don't own
2. **Use rate limiting** to avoid overwhelming targets
3. **Log your activities** for accountability
4. **Use encryption** when capturing sensitive traffic
5. **Anonymize data** before sharing packet captures
6. **Update tools regularly** for latest features and fixes
7. **Understand the law** regarding network scanning in your jurisdiction

## Tips

1. **Combine tools** - Use multiple tools for verification
2. **Start simple** - Basic scans before aggressive ones
3. **Document findings** - Keep logs of network tests
4. **Learn protocols** - Understand what you're testing
5. **Use scripts** - Automate common tasks
6. **Monitor continuously** - Set up regular network checks
7. **Practice legally** - Use test environments
8. **Understand output** - Know what results mean
9. **Check both ways** - Test from multiple locations
10. **Stay updated** - Network tools evolve quickly