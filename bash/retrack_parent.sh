
printf "$(date)\n"
today=$(date +%Y%m%d-%H%M%S)

# setting up a variable with todays date and making a folder for the modified courtship videos
CodeDirectory=$( dirname "$PWD" )
cd "${CodeDirectory}/bash"

current_machine=$(hostname)
if [[ "${current_machine}" == "goodwintracking" ]]; then
	printf "\n\n\n######################\n"
	printf "Running on the Tracker\n"
	printf "######################\n\n\n"
	ToBeTrackedDirectory="/mnt/Synology/ToBeTracked/VideosFromStations"
	WorkingDirectory="/mnt/LocalData/Tracking"
	ArchiveDirectory="/mnt/Synology/Archive/Tracked"
	LogDirectory="/home/goodwintracking/Documents/TrackingLogs/tracking_history.log"
elif [[ "${current_machine}" == "mentok" ]]; then
	printf "\n\n\n##########################\n"
	printf "Running on Aaron's Desktop\n"
	printf "##########################\n\n\n"
	ToBeTrackedDirectory="/mnt/synology/ToBeTracked/VideosFromStations"
	WorkingDirectory="/mnt/data/Tracking"
	ArchiveDirectory="/mnt/synology/Archive/Tracked"
	LogDirectory="/mnt/data/Tracking/_logs/tracking_logs/${today}_tracking_history.log"
	sys_use_log_file="/mnt/data/Tracking/_logs/system_usage/${today}_system_usage.log"
else
	printf "\n\n\n##########################\n"
	printf "I don't know this computer ... \n"
	printf "##########################\n\n\n"
	exit 1
fi


InputDirectory="${ToBeTrackedDirectory}/../NowTracking/videos"
OutputDirectory="/mnt/data/Tracking/retrack"
new_settings_file="/mnt/data/Tracking/retrack/new_settings.txt"
mkdir -p "${OutputDirectory}/_tracking_logs"

while IFS=',' read -r recording_date \
						user \
						video_name \
						video_type \
						fps \
						start_time \
						flies_per_arena \
						sex_ratio \
						number_of_arenas \
						arena_shape \
						assay_type \
						optogenetics_light \
						station;
do
	# Force variables to be lowercase
	video_type=$(printf "${video_type}" | tr '[:upper:]' '[:lower:]')
	arena_shape=$(printf "${arena_shape}" | tr '[:upper:]' '[:lower:]')
	assay_type=$(printf "${assay_type}" | tr '[:upper:]' '[:lower:]')
	optogenetics_light=$(printf "${optogenetics_light}" | tr '[:upper:]' '[:lower:]')
	station=$(printf "${station}" | tr '[:upper:]' '[:lower:]')

	printf "\tNow tracking ${user}'s video ${video_name}\n"

	if [[ ${assay_type} == "courtship" ]] || [[ ${assay_type} == "oviposition" ]]; then
		# run single_video_tracking.sh
		bash retrack_child.sh "${today}" \
									  "${CodeDirectory}" \
									  "${ToBeTrackedDirectory}" \
									  "${WorkingDirectory}" \
									  "${InputDirectory}" \
									  "${OutputDirectory}" \
									  "${recording_date}" \
									  "${user}" \
									  "${video_name}" \
									  "${video_type}" \
									  "${fps}" \
									  "${start_time}" \
									  "${flies_per_arena}" \
									  "${sex_ratio}" \
									  "${number_of_arenas}" \
									  "${arena_shape}" \
									  "${assay_type}" \
									  "${optogenetics_light}" \
									  "${station}">> \
			"${OutputDirectory}/_tracking_logs/${today}_${user_name}_${video_name}_tracking.log" 2>&1 \
			&
	fi


	sleep 2s    # 2 second lag to allow single_video_tracking to start

	# Set a different cut off depending on which computer is running the pipeline
	if [[ "${current_machine}" == "goodwintracking" ]]; then
		#printf "current machine is ${current_machine}\n"
		#printf "num_parallel_less_one = ${num_parallel_less_one}\n"
		num_parallel_less_one=1
	elif [[ "${current_machine}" == "mentok" ]]; then
		#printf "current machine is ${current_machine}\n"
		#printf "num_parallel_less_one = ${num_parallel_less_one}\n"
		num_parallel_less_one=9
	else
		#printf "current machine is ${current_machine}\n"
		#printf "num_parallel_less_one = ${num_parallel_less_one}\n"
		num_parallel_less_one=0
	fi

	# Check to make sure no more than 'num_parallel_less_one' *_video_tracking scripts are running.
	while [[ $(pgrep -fc "retrack_child") -gt "${num_parallel_less_one}" ]]
	do
		sleep 10m
	done
done < "${new_settings_file}"

# Add wait for all scripts to finish
while [ $(pgrep -fc "retrack_child") -gt 0 ]
do
	printf 'Waiting for tracking to finish ...\n'
	sleep 10m
done



# If running on my desktop, move the tracking results to the Tracker
if [[ "${current_machine}" == "mentok" ]]; then
	printf "\n\n\n\n\n\n\n\n"
	printf "####################################################\n"
	printf "####################################################\n"
	printf "####################################################\n\n"
	printf 'Transfering results to Tracker ...\n\n\n'

	# ssh goodwintracking@goodwintracking.local "mkdir -p /mnt/LocalData/Tracking/${today}-Tracked"
	# scp -r "${OutputDirectory}/" "goodwintracking@goodwintracking.local:/mnt/LocalData/Tracking/${today}-Tracked"

	# printf "not moving right now ...\n"
	cp -rv "${OutputDirectory}/" "/mnt/tracker/Tracking/${today}-Tracked"

	printf "\n\n####################################################\n"
	printf "####################################################\n"
	printf "####################################################\n"
	printf "\n\n\n\n\n\n\n\n"
fi
