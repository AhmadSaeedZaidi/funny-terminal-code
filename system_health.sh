#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check top 5 CPU-consuming processes and calculate total CPU usage
check_cpu_usage() {
    echo -e "${YELLOW}Top 5 CPU-Consuming Processes:${NC}"
    echo "----------------------------------------"

    # Get top 5 CPU-consuming processes and calculate total CPU usage
    echo -e "USER       PID  %CPU  COMMAND"
    #i honestly dont even know what this is, it wasnt working and i asked gpt for help
    ps aux --sort=-%cpu | awk 'NR>1 {printf "%-10s %-5s %-5s %s\n", $1, $2, $3, $11}' | head -n 5
    echo "----------------------------------------"
    
    # Calculate and print total CPU usage
    total_cpu=$(ps aux --sort=-%cpu | awk 'NR>1 {total+=$3} END {print total}' | head -n 1)
    echo -e "${GREEN}Total CPU Usage of Top 5 Processes: ${total_cpu}%${NC}"
    echo
}

# Function to check top 5 memory-consuming processes
check_memory_usage() {
    echo -e "${YELLOW}Top 5 Memory-Consuming Processes:${NC}"
    echo "----------------------------------------"

    # Print top 5 memory-consuming processes
    echo -e "USER       PID  %MEM  COMMAND"
    ps aux --sort=-%mem | awk 'NR>1 {printf "%-10s %-5s %-5s %s\n", $1, $2, $4, $11}' | head -n 5
    echo
}

# Function to check disk usage
check_disk_usage() {
    echo -e "${YELLOW}Disk Usage:${NC}"
    echo "----------------------------------------"

    # Get the disk usage for the root partition
    df -h / | awk 'NR==2 {print "Filesystem:", $1, "| Size:", $2, "| Used:", $3, "| Available:", $4, "| Use%:", $5}'
    echo
}

# Function to check system uptime
check_uptime() {
    echo -e "${YELLOW}System Uptime:${NC}"
    echo "----------------------------------------"

    # Print system uptime
    uptime -p
    echo
}

# Function to check network connectivity by pinging common websites
check_network_connectivity() {
    echo -e "${YELLOW}Network Connectivity:${NC}"
    echo "----------------------------------------"

    # Ping Google, Amazon, and localhost
    for site in "google.com" "amazon.com" "localhost"; do
        ping -c 1 $site &> /dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}$site is reachable.${NC}"
        else
            echo -e "${RED}$site is unreachable.${NC}"
        fi
    done
    echo -e "${YELLOW}Network Adapters:${NC}"
    echo "----------------------------------------"
    ip addr show | awk '/^[0-9]+: / {print $2}' | sed 's/://' 
}

# Main function to run all checks
main() {
    check_cpu_usage
    check_memory_usage
    check_disk_usage
    check_uptime
    check_network_connectivity
}

# Execute the main function
main

