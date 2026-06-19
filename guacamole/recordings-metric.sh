#!/bin/bash
OUTPUT="/var/lib/prometheus/node-exporter/recordings.prom"
SIZE=$(du -sb /opt/guacamole/recordings/ 2>/dev/null | awk '{print $1}')
COUNT=$(find /opt/guacamole/recordings/ -type f 2>/dev/null | wc -l)

echo "# HELP recordings_disk_usage_bytes Disk usage of recordings" > $OUTPUT
echo "# TYPE recordings_disk_usage_bytes gauge" >> $OUTPUT
echo "recordings_disk_usage_bytes $SIZE" >> $OUTPUT
echo "# HELP recordings_file_count Number of recording files" >> $OUTPUT
echo "# TYPE recordings_file_count gauge" >> $OUTPUT
echo "recordings_file_count $COUNT" >> $OUTPUT
