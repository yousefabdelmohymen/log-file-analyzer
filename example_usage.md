# Example Usage and Test Data

This document provides examples of how to use the log analyzer script and includes sample test data to verify functionality.

## Example Log File

Below is a small sample log file you can use to test the script. Save this to a file named `sample.log`:

```
192.168.1.100 - - [01/May/2025:08:05:32 -0500] "GET /home HTTP/1.1" 200 1234
192.168.1.101 - - [01/May/2025:08:10:45 -0500] "POST /login HTTP/1.1" 200 543
192.168.1.100 - - [01/May/2025:08:15:21 -0500] "GET /profile HTTP/1.1" 200 2345
192.168.1.102 - - [01/May/2025:09:05:11 -0500] "GET /products HTTP/1.1" 404 321
192.168.1.103 - - [01/May/2025:09:10:33 -0500] "GET /about HTTP/1.1" 200 876
192.168.1.100 - - [01/May/2025:09:25:17 -0500] "POST /comment HTTP/1.1" 201 123
192.168.1.104 - - [01/May/2025:10:05:50 -0500] "GET /products HTTP/1.1" 200 4321
192.168.1.100 - - [01/May/2025:10:20:10 -0500] "GET /home HTTP/1.1" 200 1235
192.168.1.105 - - [01/May/2025:11:15:22 -0500] "POST /upload HTTP/1.1" 500 321
192.168.1.101 - - [01/May/2025:11:30:45 -0500] "GET /contact HTTP/1.1" 200 654
192.168.1.100 - - [01/May/2025:12:05:15 -0500] "GET /search HTTP/1.1" 200 987
192.168.1.106 - - [01/May/2025:12:15:30 -0500] "GET /unknown HTTP/1.1" 404 234
192.168.1.102 - - [01/May/2025:13:05:12 -0500] "POST /login HTTP/1.1" 401 123
192.168.1.100 - - [01/May/2025:13:20:19 -0500] "GET /profile HTTP/1.1" 200 2346
192.168.1.107 - - [01/May/2025:14:10:33 -0500] "GET /home HTTP/1.1" 200 1236
192.168.1.101 - - [01/May/2025:14:25:45 -0500] "POST /comment HTTP/1.1" 201 345
192.168.1.100 - - [01/May/2025:15:05:22 -0500] "GET /logout HTTP/1.1" 302 123
192.168.1.108 - - [01/May/2025:15:30:19 -0500] "GET /products HTTP/1.1" 200 4322
192.168.1.102 - - [01/May/2025:16:15:21 -0500] "GET /about HTTP/1.1" 200 877
192.168.1.100 - - [01/May/2025:16:45:10 -0500] "POST /feedback HTTP/1.1" 201 432
192.168.1.109 - - [02/May/2025:08:05:32 -0500] "GET /home HTTP/1.1" 200 1237
192.168.1.100 - - [02/May/2025:08:30:21 -0500] "GET /profile HTTP/1.1" 200 2347
192.168.1.101 - - [02/May/2025:09:10:45 -0500] "POST /login HTTP/1.1" 200 544
192.168.1.110 - - [02/May/2025:09:25:17 -0500] "GET /products HTTP/1.1" 200 4323
192.168.1.100 - - [02/May/2025:10:05:19 -0500] "GET /search HTTP/1.1" 200 988
192.168.1.102 - - [02/May/2025:10:30:21 -0500] "GET /unknown HTTP/1.1" 404 235
192.168.1.100 - - [02/May/2025:11:15:22 -0500] "POST /comment HTTP/1.1" 201 124
192.168.1.111 - - [02/May/2025:11:45:33 -0500] "GET /contact HTTP/1.1" 200 655
192.168.1.101 - - [02/May/2025:12:10:45 -0500] "GET /about HTTP/1.1" 200 878
192.168.1.100 - - [02/May/2025:12:35:19 -0500] "GET /home HTTP/1.1" 200 1238
```

## Running the Script with Sample Data

1. Save the sample log data above to a file named `sample.log`
2. Run the script on the sample data:

```bash
./log_analyzer.sh sample.log
```

## Expected Results

When run on the sample log file, the script should produce a report showing:

- Total requests: 30
- GET requests: ~22
- POST requests: ~8
- Unique IP addresses: ~12
- Failed requests: ~4
- Most active IP: 192.168.1.100
- Daily average: ~15 requests per day
- Peak hours: Varies, but probably around 8-12

## Generating a Larger Test File

For more comprehensive testing, you can generate a larger log file with this command:

```bash
#!/bin/bash
# Save this as generate_test_log.sh and make it executable

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
    echo "$ip - - [$day/May/2025:$hour_fmt:$minute_fmt:$second_fmt -0500] \"$method $path HTTP/1.1\" $status $bytes" >> "$output_file"
done

echo "Generated $entries log entries in $output_file"
```

Run this script to generate a larger test file with 1000 random entries:

```bash
chmod +x generate_test_log.sh
./generate_test_log.sh
```

Then analyze the larger file:

```bash
./log_analyzer.sh large_sample.log
```

This will provide a more comprehensive test of the script's capabilities with a dataset that better represents real-world usage patterns.
