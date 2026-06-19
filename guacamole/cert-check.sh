#!/bin/bash
OUTPUT="/var/lib/prometheus/node-exporter/cert.prom"
EXPIRY=$(openssl x509 -in /etc/letsencrypt/live/bastion.talan.cloud/fullchain.pem -noout -enddate 2>/dev/null | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW=$(date +%s)
DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW) / 86400 ))

echo "# HELP cert_expiry_days_left Days until SSL certificate expires" > $OUTPUT
echo "# TYPE cert_expiry_days_left gauge" >> $OUTPUT
echo "cert_expiry_days_left{domain=\"bastion.talan.cloud\"} $DAYS_LEFT" >> $OUTPUT
