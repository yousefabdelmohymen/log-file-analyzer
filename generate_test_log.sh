#!/bin/bash
# Script to generate a larger test log file for comprehensive testing

# Number of log entries to generate
entries=1000

# Output file
output_file="large_sample.log"

# IP addresses to use
ips=("192.168.1.100" "192.168.1.101" "192.168.1.102" "192.168.1.103" "192.168.1.104" 
     "192.168.1.105" "192.168.1.106" "192.168.1.107" "192.168.1.108" "192.168.1.109")

# Request paths
paths=("/home" "/products" "/about" "/contact" "/profile" "/search" "/login" "/logout" "/api/data" "/admin")

# HTTP methods
methods=("GET" "GET" "GET" "GET" "POST" "POST" "PUT" "DELETE")

# Status codes with weights (more common codes appear more often)
status_codes=("200" "200" "200" "200" "301" "302" "304" "400" "401" "403" "404" "404" "500")

# Clean existing file if it exists
if [[ -f "$output_file" ]]; then
    > "$output_file"
fi

echo "Generating $entries log entries in $output_file..."

# Generate random logs
for ((i=1; i<=entries; i++)); do
    # Random components
    ip=${ips[$RANDOM % ${#ips[@]}]}
    day=$(( 1 + RANDOM % 10 ))
    hour=$(( RANDOM % 24 ))
    minute=$(( RANDOM % 60 ))
    second=$(( RANDOM % 60 ))
    path=${paths[$RANDOM % ${#paths[@]}]}
    method=${methods[$RANDOM % ${#methods[@]}]}
    status=${status_codes[$RANDOM % ${#status_codes[@]}]}
    bytes=$(( 100 + RANDOM % 5000 ))
    
    # Format day with leading zero if needed
    if [[ $day -lt 10 ]]; then
        day="0$day"
    fi
    
    # Format time components with leading zeros
    printf -v hour_fmt "%02d" $hour
    printf -v minute_fmt "%02d" $minute
    printf -v second_fmt "%02d" $second
    
    # Write log entry
    echo "$ip - - [$day/May/2025:$hour_fmt:$minute_fmt:$second_fmt -0500] \"$method $path HTTP/1.1\" $
