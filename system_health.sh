#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=70
DISK_THRESHOLD=80

# Function to check CPU usage
check_cpu() {
    CPU_USAGE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
    CPU_USAGE=${CPU_USAGE%.*} # Remove decimal

    if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
        echo -e "${RED}CPU Usage: ${CPU_USAGE}% (High)${NC}"
    else
        echo -e "${GREEN}CPU Usage: ${CPU_USAGE}% (Normal)${NC}"
    fi
}

# Function to check Memory usage
check_memory() {
    MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    MEM_USAGE=${MEM_USAGE%.*} # Remove decimal

    if [ "$MEM_USAGE" -ge "$MEM_THRESHOLD" ]; then
        echo -e "${RED}Memory Usage: ${MEM_USAGE}% (High)${NC}"
    else
        echo -e "${GREEN}Memory Usage: ${MEM_USAGE}% (Normal)${NC}"
    fi
}

# Function to check Disk usage
check_disk() {
    DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

    if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
        echo -e "${RED}Disk Usage: ${DISK_USAGE}% (High)${NC}"
    else
        echo -e "${GREEN}Disk Usage: ${DISK_USAGE}% (Normal)${NC}"
    fi
}

# Function to check Network usage
check_network() {
    ifstat -S 1 1 | tail -n +3 | awk '{printf "TX: %s KB/s, RX: %s KB/s\n", $1, $2}' | while read line; do
        echo -e "${YELLOW}Network Usage: $line${NC}"
    done
}

# Function to display the top 5 memory-consuming processes
check_top_processes() {
    echo -e "${YELLOW}Top 5 Memory-Consuming Processes:${NC}"
    echo "----------------------------------------"
    ps -eo pid,comm,%mem --sort=-%mem | head -n 6 | awk '{printf "%-8s %-30s %-10s\n", $1, $2, $3}'
    echo "----------------------------------------"
}

# Function to check system uptime
check_uptime() {
    UPTIME=$(uptime -p)
    echo -e "${BLUE}System Uptime: $UPTIME${NC}"
}

# Function to display health report
display_health_report() {
    echo -e "${YELLOW}System Health Report${NC}"
    echo "----------------------------------------"
    printf "%-20s %-10s\n" "Component" "Status"
    printf "%-20s %-10s\n" "CPU" "$(check_cpu)"
    printf "%-20s %-10s\n" "Memory" "$(check_memory)"
    printf "%-20s %-10s\n" "Disk" "$(check_disk)"
    check_network
    check_top_processes
    printf "%-20s %-10s\n" "Uptime" "$(check_uptime)"
    echo "----------------------------------------"
}

# Main function to run the health checks
main() {
    display_health_report
}

# Execute the main function
main
