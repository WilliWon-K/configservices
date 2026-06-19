#!/bin/bash
OUTPUT="/var/lib/prometheus/node-exporter/fail2ban.prom"
TMP="${OUTPUT}.tmp"

echo "# HELP fail2ban_banned_current Currently banned IPs per jail" > $TMP
echo "# TYPE fail2ban_banned_current gauge" >> $TMP
echo "# HELP fail2ban_banned_total Total bans since start per jail" >> $TMP
echo "# TYPE fail2ban_banned_total counter" >> $TMP
echo "# HELP fail2ban_failed_current Current failed attempts per jail" >> $TMP
echo "# TYPE fail2ban_failed_current gauge" >> $TMP

for jail in $(fail2ban-client status 2>/dev/null | grep "Jail list" | sed 's/.*://;s/,//g'); do
    status=$(fail2ban-client status "$jail" 2>/dev/null)
    banned=$(echo "$status" | grep "Currently banned" | awk '{print $NF}')
    total=$(echo "$status" | grep "Total banned" | awk '{print $NF}')
    failed=$(echo "$status" | grep "Currently failed" | awk '{print $NF}')
    echo "fail2ban_banned_current{jail=\"$jail\"} ${banned:-0}" >> $TMP
    echo "fail2ban_banned_total{jail=\"$jail\"} ${total:-0}" >> $TMP
    echo "fail2ban_failed_current{jail=\"$jail\"} ${failed:-0}" >> $TMP
done

mv $TMP $OUTPUT
