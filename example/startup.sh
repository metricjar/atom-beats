#!/usr/bin/env bash
# note: make sure you have logstash and filebeat installed and in added to PATH env var.
STREAM=$STREAM AUTH=$AUTH logstash --allow-env -f logstash.conf &
`sleep 15` ./filebeat -e -d "*" -c filebeat.yml