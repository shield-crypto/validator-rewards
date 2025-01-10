#!/bin/sh

# Query whether the validator has signed the last 100 blocks and publish the result


TIMESTAMP=`date "+%Y-%m-%d %H:%M:%S %Z"`
UPTIME_FILE=metrics/uptime_status.txt

echo checking Validator status at $TIMESTAMP > $UPTIME_FILE

CURL_CMD='curl -s  https://undexer.namada.coverlet.io/v4/validator?publicKey=5399BC0F27BB74E104A74C4123AEA8CC90FF9A1EC66AA988D17CE11B835CAAAE&uptime'

VALIDATOR_STATUS=`$CURL_CMD`

echo $VALIDATOR_STATUS >> $UPTIME_FILE


COUNTED_BLOCKS=$(echo $VALIDATOR_STATUS | jq -r .countedBlocks )

if [ "$COUNTED_BLOCKS" = "100" ]; then
   echo "OK_ALL_BLOCK_SIGNED" >> $UPTIME_FILE
else
  echo "WARN_MISSING_BLOCKS" >> $UPTIME_FILE
fi

