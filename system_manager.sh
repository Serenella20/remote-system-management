#!/bin/bash

# Define SSH login details (Codespace as the "remote" server)
HOST="127.0.0.1"
PORT="2222"
USER="codespace"
PASSWORD="your-password"  # For security, use an SSH key instead.

# Create a log file with timestamp
LOG_FILE="logs/system_health_$(date +%F_%T).log"
mkdir -p logs

# Run the Expect script to SSH and execute remote commands
./ssh_auto.exp $HOST $USER $PASSWORD | tee -a $LOG_FILE

# Extract key system stats from log
CPU_LOAD=$(grep "load average" $LOG_FILE | awk '{print $10}')
MEM_AVAILABLE=$(grep "Mem:" $LOG_FILE | awk '{print $7}')

echo "✅ System Health Summary:"
echo "🔹 CPU Load: $CPU_LOAD"
echo "🔹 Memory Available: $MEM_AVAILABLE MB"

# Alert if system is overloaded
if (( $(echo "$CPU_LOAD > 1.5" | bc -l) )); then
  echo "⚠️ High CPU Usage: $CPU_LOAD" | tee -a logs/alerts.log
fi

if (( $(echo "$MEM_AVAILABLE < 500" | bc -l) )); then
  echo "⚠️ Low Memory: $MEM_AVAILABLE MB available" | tee -a logs/alerts.log
fi

echo "✅ System Health Check Completed."
