#!/bin/sh

echo Running bash script in github


METRIC_FILE=metrics/metrics.txt
WEBSITE_APY=metrics/last_delegator_apy.txt

echo "# HELP shield_delegators_apy APY generated for delegators by the validator" >> $METRIC_FILE
echo "# TYPE shield_delegators_apy gauge" >> $METRIC_FILE
echo "shield_delegators_apy .12" >> $METRIC_FILE
echo ".12" >> $WEBSITE_APY




