#!/bin/bash

SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL}"

IFS=',' read -ra domains <<< "$DOMAINS"

for domain in "${domains[@]}"; do
    expiry_date=$(openssl s_client -connect "$domain":443 2>/dev/null | openssl x509 -noout -dates | grep 'notAfter' | cut -d '=' -f 2)
    expiry_timestamp=$(date -d "$expiry_date" +%s)
    current_timestamp=$(date +%s)
    days_left=$(( ($expiry_timestamp - $current_timestamp) / 86400 ))

    if [ "$days_left" -lt 365 ]; then
        alert="SSL Expiry Alert\n   * Domain : $domain\n   * Warning : The SSL certificate for $domain will expire in $days_left days."
        curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$alert\"}" "$SLACK_WEBHOOK_URL"
    fi
done

