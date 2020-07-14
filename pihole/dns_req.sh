#!/usr/bin/env bash
PIHOLE_ADDR=192.168.1.241
while true; do
  sleep 2
  echo "$(date): $(time dig +timeout=1 @$PIHOLE_ADDR google.com|grep real)"
done