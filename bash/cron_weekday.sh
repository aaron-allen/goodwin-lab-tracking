#!/bin/bash

printf "\n\n\n######################\nWeekday Run\n"

today=$(date +%Y%m%d-%H%M%S)
num_vid=$( wc -l < "/mnt/synology/ToBeTracked/VideosFromStations/list_of_videos.csv" )
used_mem=$( free --giga | awk '0 == NR % 2' | awk '{print $3}' )

printf "today=$today\n"
printf "num_vid=$num_vid\n"
printf "used_mem=$used_mem\n\n"

if [[ "${num_vid}" -ge 0 ]]; then
	# if [[ "${num_vid}" -le 10 && "${used_mem}" -le 70 ]]; then
		printf "good to go!\n"
		cd /home/aaron/Documents/GitHub/goodwin-lab-tracking/bash/
		# bash GoodwinLab_Tracking.sh
		bash GoodwinLab_Tracking.sh >> "/mnt/data/Tracking/_logs/cron_logs/${today}_tracking_pipeline_cron.log" 2>&1
	# else
		# printf "NOT good to go ...\n"
	# fi
else
	printf "No videos to track ...\n"
fi

printf "######################\n\n\n"
