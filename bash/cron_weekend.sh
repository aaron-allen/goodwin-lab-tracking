#!/bin/bash

printf "\n\n\n######################\n\n\n"

today=$(date +%Y%m%d-%H%M%S)
printf "today=$today\n"

cd /home/aaron/Documents/GitHub/goodwin-lab-tracking/bash/
bash GoodwinLab_Tracking.sh
# bash GoodwinLab_Tracking.sh >> "/mnt/data/Tracking/_logs/cron_logs/${today}_tracking_pipeline_cron.log" 2>&1

printf "\n\n\n######################\n\n\n"
