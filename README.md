# Log File Analyzer

This project includes a Bash script for analyzing log files and generating comprehensive statistics and insights based on the data. The script fulfills the requirements specified in the log file analysis task.

## Features

The script analyzes a log file and generates the following statistics and insights:

1. **Request Counts**:
   - Total number of requests
   - Count of GET requests
   - Count of POST requests

2. **Unique IP Addresses**:
   - Count of unique IP addresses
   - For each unique IP, shows GET and POST request counts

3. **Failure Requests**:
   - Count of failed requests (4xx or 5xx status codes)
   - Percentage of failed requests relative to total requests

4. **Top User**:
   - The most active IP address (made the most requests)

5. **Daily Request Averages**:
   - Average number of requests per day
   - Breakdown of requests by day

6. **Failure Analysis**:
   - Days with highest number of failure requests

7. **Additional Insights**:
   - Request distribution by hour
   - Status code breakdown
   - Most active users by method (GET/POST)
   - Request trends
   - Patterns in failure requests

8. **Suggestions for Improvement**:
   - Recommendations based on the analysis findings

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yousefabdelmohymen/log-analyzer.git
   cd log-analyzer
   ```

2. Make the script executable:
   ```bash
   chmod +x log_analyzer.sh
   ```

## Usage

Run the script with a log file as an argument:

```bash
./log_analyzer.sh /path/to/your/logfile.log
```

### Example

```bash
./log_analyzer.sh access.log
```

## Expected Log Format

The script expects log files in the Common Log Format (CLF) or Extended Log Format (ELF) similar to:

```
192.168.1.1 - - [10/Oct/2023:13:55:36 -0700] "GET /index.html HTTP/1.1" 200 2326
```

If your log format differs, you may need to adjust the field indices in the script.

## Sample Output

The script generates a comprehensive report that includes:

```
===================== Log Analysis Report =====================
1. Request Counts:
   - Total Requests: 12345
   - GET Requests: 9876
   - POST Requests: 2469
...
```

## Requirements

- Bash shell (version 4.0 or later recommended)
- Basic Unix utilities: awk, grep, sort, uniq, wc

## License

This project is released under the MIT License.

## Author

Your Name
