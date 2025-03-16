#!/bin/sh

echo Running bash script in github

#export CHAIN_ID=namada.5f5de2dd1b88cba30586420
#export NAMADA_NETWORK_CONFIGS_SERVER="https://github.com/anoma/namada-mainnet-genesis/releases/download/mainnet-genesis"
#namada --version
#echo "Joining Namada Network"
#namadac utils join-network --chain-id $CHAIN_ID

export VALIDATOR_ADDRESS=tnam1qyvc8n7ufmpan4yy3nemm3td2c6uff4m6s72g3eg

# Update it when commission are claimed by the validator
CLAIMED=2226.35
TOTAL_STAKE_AVERAGE=1200000
#16.12.2024 23.00
TOTAL_START_TIME=1734390000

echo "fetching the validator commission"
COMMISSION=$(curl -s https://api.namada.valopers.com/account/$VALIDATOR_ADDRESS/commission | jq -r .amount)

TOTAL_COMMISSION=$(echo "scale=6;$COMMISSION + $CLAIMED" | bc)
TOTAL_COMMISSION_RATE=0.1

DETAILS=$(curl -s https://api.namada.valopers.com/validators/details/$VALIDATOR_ADDRESS)
STAKEM=$(echo $DETAILS | jq -r .stake)
STAKE=$(echo "scale=2;$STAKEM / 1000000" | bc)
COMMISSION_RATE=$(echo $DETAILS | jq -r .commission.commission_rate)

METRIC_FILE=metrics/metrics.txt

start_time=$(date +%s)

last_run=$(curl -s https://shield-crypto.github.io/validator-rewards/last_run.txt)
elapsed=$((start_time - $last_run))
total_elapsed=$((start_time - $TOTAL_START_TIME))

fraction_yearnf=$(echo "scale=8;$elapsed / 31536000"  | bc)
fraction_year=$(printf "%.10f" "$fraction_yearnf")

total_fraction_yearnf=$(echo "scale=8;$total_elapsed / 31536000"  | bc)
total_fraction_year=$(printf "%.10f" "$total_fraction_yearnf")

echo "# HELP shield_time_period Fraction of the year represented by this calculation " > $METRIC_FILE
echo "# TYPE shield_time_period gauge" >> $METRIC_FILE
echo "shield_time_period $fraction_year" >> $METRIC_FILE



echo "# HELP shield_validator_commission_rate Commission Rate for the validator" >> $METRIC_FILE
echo "# TYPE shield_validator_commission_rate gauge" >> $METRIC_FILE
echo "shield_validator_commission_rate $COMMISSION_RATE" >> $METRIC_FILE

echo "# HELP shield_validator_stake Stake on the validator" >> $METRIC_FILE
echo "# TYPE shield_validator_stake gauge" >> $METRIC_FILE
echo "shield_validator_stake $STAKE" >> $METRIC_FILE

echo "# HELP shield_validator_rewards rewards generated by the validator (commission)" >> $METRIC_FILE
echo "# TYPE shield_validator_rewards gauge" >> $METRIC_FILE
echo "shield_validator_rewards $COMMISSION" >> $METRIC_FILE

rewards_delegators=$(echo "scale=2; $COMMISSION / $COMMISSION_RATE" | bc)
total_rewards_delegators=$(echo "scale=2; $TOTAL_COMMISSION / $TOTAL_COMMISSION_RATE" | bc)

last_rewards_delegators=$(curl -s https://shield-crypto.github.io/validator-rewards/last_rewards_delegators.txt)
echo "$rewards_delegators" > metrics/last_rewards_delegators.txt


echo "# HELP shield_delegators_rewards rewards distributed to delegators since last claim" >> $METRIC_FILE
echo "# TYPE shield_delegators_rewards gauge" >> $METRIC_FILE
echo "shield_delegators_rewards $rewards_delegators" >> $METRIC_FILE

echo "# HELP shield_delegators_rewards_total rewards distributed to delegators since genesis" >> $METRIC_FILE
echo "# TYPE shield_delegators_rewards_total gauge" >> $METRIC_FILE
echo "shield_delegators_rewards_total $total_rewards_delegators" >> $METRIC_FILE

echo "# HELP shield_delegators_rewards_last rewards The amount of distributed to delegators that was seen at previous run" >> $METRIC_FILE
echo "# TYPE shield_delegators_rewards_last gauge" >> $METRIC_FILE
echo "shield_delegators_rewards_last $last_rewards_delegators" >> $METRIC_FILE


delegator_rewards_delta=$(echo "scale=4; $rewards_delegators -  $last_rewards_delegators" | bc)

echo "# HELP shield_delegators_rewards_last_epoch rewards distributed to delegators in the last epoch " >> $METRIC_FILE
echo "# TYPE shield_delegators_rewards_last_epoch gauge" >> $METRIC_FILE
echo "shield_delegators_rewards_last_epoch $delegator_rewards_delta" >> $METRIC_FILE

rewards_percentage_delegatorsnf=$(echo "scale=10; $rewards_delegators / $STAKE" | bc)
rewards_percentage_delegators=$(printf "%.10f" "$rewards_percentage_delegatorsnf")


echo "# HELP shield_delegators_rewards_percentage Percentage of rewards vs staked amount on the validator" >> $METRIC_FILE
echo "# TYPE shield_delegators_rewards_percentage gauge" >> $METRIC_FILE
echo "shield_delegators_rewards_percentage $rewards_percentage_delegators" >> $METRIC_FILE

rewards_percentage_delegators_delta=$(echo "scale=10; $delegator_rewards_delta / $STAKE" | bc)
total_rewards_percentage_delegators=$(echo "scale=10; $total_rewards_delegators / $TOTAL_STAKE_AVERAGE" | bc)


echo "# HELP shield_delegators_rewards_percentage_delta Delta Percentage of rewards vs staked amount on the validator" >> $METRIC_FILE
echo "# TYPE shield_delegators_rewards_percentage_delta gauge" >> $METRIC_FILE
echo "shield_delegators_rewards_percentage_delta $delegator_rewards_delta" >> $METRIC_FILE

# APY = (1 + rewards_percentage_delegators)^(1/fraction_year)-1
# APY = (1 + rewards_percentage_delegators)
BASE=$(echo "scale=10; 1 + $rewards_percentage_delegators_delta" | bc);
EXPONENT=$(echo "scale=10; 1 / $fraction_year" | bc);

BASE_TOTAL=$(echo "scale=10; 1 + $total_rewards_percentage_delegators" | bc);
EXPONENT_TOTAL=$(echo "scale=10; 1 / $total_fraction_year" | bc);

APY=$(echo "scale=10; e($EXPONENT * l($BASE)) - 1 " | bc -l);
TOTAL_APYNF=$(echo "scale=10; e($EXPONENT_TOTAL * l($BASE_TOTAL)) - 1 " | bc -l);
TOTAL_APY=$(printf "%.10f" "$TOTAL_APYNF")

echo $start_time > metrics/last_run.txt

echo "# HELP shield_delegators_apy APY generated for delegators by the validator. Re-calculated every 6 hours" >> $METRIC_FILE
echo "# TYPE shield_delegators_apyv gauge" >> $METRIC_FILE
echo "shield_delegators_apy $APY" >> $METRIC_FILE

echo $APY > metrics/last_delegator_apy.txt

echo "# HELP shield_delegators_apy_total Average APY generated for delegators by the validator since validator genesis" >> $METRIC_FILE
echo "# TYPE shield_delegators_apy_total gauge" >> $METRIC_FILE
echo "shield_delegators_apy_total $TOTAL_APY" >> $METRIC_FILE

