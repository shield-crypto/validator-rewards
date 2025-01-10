#!/bin/sh

echo Running bash script in github

start_time=$(date +%s)
LAST_RUN_FILE=metrics/last_run.txt
LAST_REWARDS_FILE=metrics/last_rewards_delegators.txt

echo $start_time > $LAST_RUN_FILE
echo 0 > $LAST_REWARDS_FILE