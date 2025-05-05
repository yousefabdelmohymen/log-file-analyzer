#!/bin/bash

# Log File Analyzer
# This script analyzes log files and generates statistics and insights
# Usage: ./log_analyzer.sh <logfile>

# Check if log file is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <logfile>"
    exit 1
fi

logfile="$1"

# Check if file exists and is readable
if [[ ! -f "$logfile" || ! -r "$logfile" ]]; then
    echo "Error: Cannot read file '$logfile'"
    exit 1
fi

echo "Analyzing log file: $logfile"
echo "This may take a moment for large files..."

# Initialize variables
total_requests=$(wc -l < "$logfile")
get_requests=$(grep -c '"GET' "$logfile")
post_requests=$(grep -c '"POST' "$logfile")
unique_ips=$(awk '{print $1}' "$logfile" | sort -u | wc -l)
failed_requests=$(awk '$9 ~ /^[45]/ {count++} END {print count}' "$logfile")

# Calculate failure percentage
if [[ $total_requests -gt 0 ]]; then
    failed_percent=$(awk "BEGIN {printf \"%.2f\", ($failed_requests/$total_requests)*100}")
else
    failed_percent="0.00"
fi

# Top User (most active IP)
top_user=$(awk '{print $1}' "$logfile" | sort | uniq -c | sort -nr | head -1)
top_user_ip=$(echo "$top_user" | awk '{print $2}')
top_user_count=$(echo "$top_user" | awk '{print $1}')

# Daily request averages
daily_requests=$(awk -F'[ /:]' '{date=$4"-"$5"-"$6; counts[date]++} END {for (d in counts) print d, counts[d]}' "$logfile")
total_days=$(echo "$daily_requests" | wc -l)
daily_avg=$(echo "$daily_requests" | awk '{sum+=$2} END {printf "%.2f", sum/NR}')

# Day with most failures
worst_day=$(awk -F'[ /:]' '$9 ~ /^[45]/ {date=$4"-"$5"-"$6; counts[date]++} END {for (d in counts) print d, counts[d]}' "$logfile" | sort -k2 -nr | head -1)
worst_day_date=$(echo "$worst_day" | awk '{print $1}')
worst_day_count=$(echo "$worst_day" | awk '{print $2}')

# Requests by hour
echo "Calculating hourly requests..." >&2
hourly_requests=$(awk -F'[: ]' '{hour=$4; counts[hour]++} END {for (h=0; h<24; h++) printf "%02d:00 - %02d:59: %d\n", h, h, (h in counts) ? counts[h] : 0}' "$logfile" | sort)

# Status codes breakdown
status_codes=$(awk '{print $9}' "$logfile" | sort | uniq -c | sort -nr)

# Most active user by method
most_get=$(awk '/GET/ {print $1}' "$logfile" | sort | uniq -c | sort -nr | head -1)
most_get_ip=$(echo "$most_get" | awk '{print $2}')
most_get_count=$(echo "$most_get" | awk '{print $1}')

most_post=$(awk '/POST/ {print $1}' "$logfile" | sort | uniq -c | sort -nr | head -1)
most_post_ip=$(echo "$most_post" | awk '{print $2}')
most_post_count=$(echo "$most_post" | awk '{print $1}')

# Get requests per day for trend analysis
requests_per_day=$(awk -F'[ /:]' '{date=$4"-"$5"-"$6; counts[date]++} END {for (d in counts) print d, counts[d]}' "$logfile" | sort)

# Calculate IP-specific statistics
echo "Calculating IP-specific statistics..." >&2
ip_stats=$(awk '{
    ip=$1;
    if ($0 ~ /"GET/) get_count[ip]++;
    if ($0 ~ /"POST/) post_count[ip]++;
    total_count[ip]++;
}
END {
    for (ip in total_count) {
        printf "%s\t%d\t%d\t%d\n", ip, total_count[ip], get_count[ip] ? get_count[ip] : 0, post_count[ip] ? post_count[ip] : 0;
    }
}' "$logfile" | sort -k2 -nr)

# Generate Report
echo ""
echo "===================== Log Analysis Report ====================="
echo "1. Request Counts:"
echo "   - Total Requests: $total_requests"
echo "   - GET Requests: $get_requests"
echo "   - POST Requests: $post_requests"
echo ""
echo "2. Unique IP Addresses:"
echo "   - Unique IPs: $unique_ips"
echo "   - Top 5 IPs by request count:"
echo "$ip_stats" | head -5 | awk '{printf "     %s: %d requests (%d GET, %d POST)\n", $1, $2, $3, $4}'
echo ""
echo "3. Failure Requests:"
echo "   - Failed Requests (4xx/5xx): $failed_requests"
echo "   - Failure Percentage: ${failed_percent}%"
echo ""
echo "4. Top User:"
echo "   - Most Active IP: $top_user_ip ($top_user_count requests)"
echo ""
echo "5. Daily Request Averages:"
echo "   - Average Requests/Day: $daily_avg"
echo "   - Requests per day:"
echo "$requests_per_day" | awk '{printf "     %s: %d requests\n", $1, $2}' | head -10
if [[ $(echo "$requests_per_day" | wc -l) -gt 10 ]]; then
    echo "     (showing first 10 days only)"
fi
echo ""
echo "6. Failure Analysis:"
echo "   - Day with Most Failures: $worst_day_date ($worst_day_count failures)"
echo ""
echo "Additional Insights:"
echo "-------------------------------------------------------------"
echo "Hourly Request Distribution:"
echo "$hourly_requests"
echo ""
echo "Status Code Breakdown:"
echo "$status_codes" | head -10 | awk '{printf "   %s: %d occurrences\n", $2, $1}'
if [[ $(echo "$status_codes" | wc -l) -gt 10 ]]; then
    echo "   (showing top 10 status codes only)"
fi
echo ""
echo "Most Active Users by Method:"
echo "   - Most GETs: $most_get_ip ($most_get_count GET requests)"
echo "   - Most POSTs: $most_post_ip ($most_post_count POST requests)"
echo ""

# Identify patterns in request trends
peak_hour=$(echo "$hourly_requests" | sort -k3 -nr | head -1 | awk -F'[ :]' '{print $1}')
low_hour=$(echo "$hourly_requests" | sort -k3 -n | head -1 | awk -F'[ :]' '{print $1}')

# Identify patterns in failures
failure_by_hour=$(awk -F'[: ]' '$9 ~ /^[45]/ {hour=$4; counts[hour]++} END {for (h=0; h<24; h++) printf "%02d:00 - %02d:59: %d\n", h, h, (h in counts) ? counts[h] : 0}' "$logfile" | sort)
peak_failure_hour=$(echo "$failure_by_hour" | sort -k3 -nr | head -1 | awk -F'[ :]' '{print $1}')

echo "Patterns and Insights:"
echo "-------------------------------------------------------------"
echo "- Peak traffic hour: $peak_hour:00 - $peak_hour:59"
echo "- Lowest traffic hour: $low_hour:00 - $low_hour:59"
echo "- Hour with most failures: $peak_failure_hour:00 - $peak_failure_hour:59"

# Generate trend analysis
first_day=$(echo "$requests_per_day" | head -1 | awk '{print $1}')
last_day=$(echo "$requests_per_day" | tail -1 | awk '{print $1}')
first_day_count=$(echo "$requests_per_day" | head -1 | awk '{print $2}')
last_day_count=$(echo "$requests_per_day" | tail -1 | awk '{print $2}')

if [[ $first_day_count -lt $last_day_count ]]; then
    echo "- Request trend: Increasing over time"
elif [[ $first_day_count -gt $last_day_count ]]; then
    echo "- Request trend: Decreasing over time"
else
    echo "- Request trend: Stable"
fi

echo ""
echo "Suggestions for Improvement:"
echo "-------------------------------------------------------------"
if (( $(echo "$failed_percent > 5" | bc -l) )); then
    echo "- The failure rate of ${failed_percent}% is concerning. Investigate server errors."
fi

if [[ -n "$worst_day_date" ]]; then
    echo "- Check system logs for $worst_day_date to identify issues that caused $worst_day_count failures."
fi

echo "- Consider scaling resources during peak hours (especially around $peak_hour:00) to handle increased traffic."

if [[ $(echo "$status_codes" | grep -c "404") -gt 0 ]]; then
    echo "- Fix broken links to reduce 404 errors."
fi

if [[ $(echo "$top_user_count/$total_requests > 0.3" | bc -l) -eq 1 ]]; then
    echo "- Investigate IP $top_user_ip as it accounts for a significant portion of requests."
    echo "  This could indicate a potential security concern or a need for caching."
fi

echo "- Implement rate limiting if certain IPs are generating excessive requests."

if [[ "$peak_hour" -eq "$peak_failure_hour" ]]; then
    echo "- The peak traffic hour ($peak_hour:00) also has the most failures. This suggests"
    echo "  the system may be overloaded during this period. Consider optimizing or scaling."
fi

echo ""
echo "This report was generated on $(date) by log_analyzer.sh"
echo "================================================================="
