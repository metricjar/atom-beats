#!/usr/bin/env bash -x
logstash --allow-env -f logstash.conf &
sleep 10
filebeat -e -d "*" -c filebeat.yml