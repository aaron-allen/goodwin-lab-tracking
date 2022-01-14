#!/bin/bash


# Author: Aaron M Allen
# Date: 2018.10.09
#     updated: 2021.12.02
#
#
#
#
# This script does the following;
#		1. Checks to see if there are any videos in 'ToBeTracked' to be tracked.
#		2. Kills any CPU or RAM hungry applications that may have been left running.
#		3. Takes a 'snap shot' of the videos that need to be tracked in the 'video_list.csv' file,
#          and moves them to the 'NowTracking' directory on the Synology.
#		4. Read through the 'video_list.csv' file and start a sub-process tracking the
#          video. At this momonet it is just 'single_video_tracking.sh' for 'courtship' style videos.
#		5. Once the tracking is done, moves the 'NowTracking' directory to archive.
#
#
#
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------


printf "$(date)\n"
today=$(date +%Y%m%d-%H%M%S)

# setting up a variable with todays date and making a folder for the modified courtship videos
CodeDirectory=$( dirname "$PWD" )
ToBeTrackedDirectory="/mnt/Synology/ToBeTracked/VideosFromStations"
WorkingDirectory="/mnt/LocalData/Tracking"
ArchiveDirectory="/mnt/Synology/Archive/mkv"
LogDirectory="/home/goodwintracking/Documents/TrackingLogs/tracking_history.log"

# printf "The Code Directory is: $CodeDirectory\n"
# printf "This is the input directory: $ToBeTrackedDirectory\n"
# printf "This is the ouptut directory: $WorkingDirectory\n"



# Check to see if there are any videos to be tracked
csv_file="${ToBeTrackedDirectory}/video_list.csv"
if [ -s ${csv_file} ]; then
	printf "There are videos to be tracked\n"

	# ----------------------------------------------------------------------------------------------------------------------------------------------------------
	# add bit to kill any processes that might interfer with tracking, like
	# matlab, geneious, python, R, etc.
	printf "\n\nKilling all MATLAB processes...\n"
	pkill MATLAB
	printf "Killing all R processes...\n"
	pkill R
	printf "Killing all ipython processes...\n"
	pkill ipython
	printf "Killing all Geneious processes...\n"
	# Geneious doesn't show up as Geneious in top/pgrep/etc, it shows up as java, but killing anything java seems a bit poor form...
	# So we'll feed the pid into a ps call with a more detailed output and grep for Geneious.
	pgrep java | while read -r java_pid ; do
    	printf "\tChecking if java pid = ${java_pid} is a Geneious instance.\n"
		if ps -Flww -p ${java_pid} | grep -q "Geneious"; then
		    printf "\tIt is! Kill it!\n"
			pkill ${java_pid}
		else
		    printf "\tMust be some other java application, so let it be.\n"
		fi
    done
	# ----------------------------------------------------------------------------------------------------------------------------------------------------------


	InputDirectory="${ToBeTrackedDirectory}/../NowTracking/videos"
	OutputDirectory="$WorkingDirectory/${today}Tracked"
	if [[ ! -d ${InputDirectory} ]]; then
		mkdir -p "${InputDirectory}/"
	fi
	mkdir -p "${OutputDirectory}/_tracking_logs"

	if [[ ! -f "${InputDirectory}/../video_list.csv" ]]; then
		touch "${InputDirectory}/../video_list.csv"
	fi
	if [[ ! -f "${InputDirectory}/../videos_in_ToBeTracked.txt" ]]; then
		touch "${InputDirectory}/../videos_in_ToBeTracked.txt"
	fi

	# ----------------------------------------------------------------------------------------------------------------------------------------------------------
	# Setup freeze of videos that need to be tracked
	mv "${ToBeTrackedDirectory}/video_list.csv" "${InputDirectory}/../video_list.csv"
	ls "${ToBeTrackedDirectory}/videos/" > "${InputDirectory}/../videos_in_ToBeTracked.txt"
	printf "" > "${ToBeTrackedDirectory}/video_list.csv"


	csv_file="${InputDirectory}/../video_list.csv"
	while IFS=',' read -r user \
							video_name \
							video_type \
							tracking_start_time_in_seconds \
							flies_per_arena \
							sex_ratio \
							number_of_arenas \
							arena_shape \
							assay_type \
							optogenetics_light \
							station; do
	    printf "\n\nVideo Name:\t ${video_name}\n"
	    if [ -f "${ToBeTrackedDirectory}/videos/${video_name}" ]; then
	      printf '\tMoving video to NowTracking\n'
	      mv "${ToBeTrackedDirectory}/videos/${video_name}" "${InputDirectory}"
	    fi
	done < ${csv_file}

	# any video that's not in the to be tracked settings file will be moved to the non-tracked directory
	printf "\n\n"
	csv_file="${InputDirectory}/../videos_in_ToBeTracked.txt"
	while IFS=',' read -r video_name; do
	    #printf "Video Name\t:\t ${video_name}\n"
	    if [ -f "${ToBeTrackedDirectory}/videos/${video_name}" ]; then
	      printf "Video Name:\t ${video_name}\n"
	      printf '\tMoving video to NonTrackedVideos\n'
	      mv "${ToBeTrackedDirectory}/videos/${video_name}" "${ToBeTrackedDirectory}/../NonTrackedVideos/videos/"
	    fi
	done < ${csv_file}
	# ----------------------------------------------------------------------------------------------------------------------------------------------------------




	# ----------------------------------------------------------------------------------------------------------------------------------------------------------
	# Track all video files with FlyTracker, and apply classifiers with JAABA
	printf "\n\nFILE TRANSFER AND TRACKING\n"
	csv_file="${InputDirectory}/../video_list.csv"

	printf "\n\n\n\n\n\n$(date)\n\n" >> "${LogDirectory}"
	cat "${csv_file}" >> "${LogDirectory}"

	while IFS=',' read -r user \
							video_name \
							video_type \
							tracking_start_time_in_seconds \
							flies_per_arena \
							sex_ratio \
							number_of_arenas \
							arena_shape \
							assay_type \
							optogenetics_light \
							station; do

		printf "\tNow tracking ${user}'s video ${video_name}\n"

		if [[ ${assay_type} == "courtship" ]]; then
			# run single_video_tracking.sh
			bash single_video_tracking.sh ${today} \
										  ${CodeDirectory} \
										  ${ToBeTrackedDirectory} \
										  ${WorkingDirectory} \
										  ${InputDirectory} \
										  ${OutputDirectory} \
										  ${user} \
										  ${video_name} \
										  ${video_type} \
										  ${tracking_start_time_in_seconds} \
										  ${flies_per_arena} \
										  ${sex_ratio} \
										  ${number_of_arenas} \
										  ${arena_shape} \
										  ${assay_type} \
										  ${optogenetics_light} >> \
				"${OutputDirectory}/_tracking_logs/${today}_${user_name}_${video_name}_tracking.log" 2>&1 \
				&
		fi


		# If Olivia ends up going with Ctrax for the oviposition assay (which might work nicely due to the non fixed number of flies..?..), It might be good
		# to add an if statement here and run a different shell script to start Ctrax.
		if [[ ${assay_type} == "oviposition" ]]; then
			# run Ctrax_tracking.sh
			printf "\n\n ... haven't coded this yet ... \n"
		# 	bash ctrax_video_tracking.sh ${today} \
		# 						   ${CodeDirectory} \
		# 						   ${ToBeTrackedDirectory} \
		# 						   ${WorkingDirectory} \
		# 						   ${InputDirectory} \
		# 						   ${user} \
		# 						   ${video_name} \
		# 						   ${video_type} \
		# 						   ${tracking_start_time_in_seconds} \
		# 						   ${flies_per_arena} \
		# 						   ${sex_ratio} \
		# 						   ${number_of_arenas} \
		# 						   ${arena_shape} \
		# 						   ${assay_type} &
		fi

		# add some code for DLC?
		if [[ ${assay_type} == "DLC" ]]; then
			# run Ctrax_tracking.sh
			printf "\n\n ... haven't coded this yet ... \n"
		# 	bash DLC_video_tracking.sh ${today} \
		# 						   ${CodeDirectory} \
		# 						   ${ToBeTrackedDirectory} \
		# 						   ${WorkingDirectory} \
		# 						   ${InputDirectory} \
		# 						   ${user} \
		# 						   ${video_name} \
		# 						   ${video_type} \
		# 						   ${tracking_start_time_in_seconds} \
		# 						   ${flies_per_arena} \
		# 						   ${sex_ratio} \
		# 						   ${number_of_arenas} \
		# 						   ${arena_shape} \
		# 						   ${assay_type} &
		fi

		sleep 5s    # 5 second lag to allow single_video_tracking to start
		# Check to make sure no more than 2 *_video_tracking scripts are running.
		while [ $(pgrep -fc "_video_tracking") -gt 1 ]
		do
			sleep 10m
		done
	done < ${csv_file}

	# ----------------------------------------------------------------------------------------------------------------------------------------------------------
	# Move the input direstory to the archive synology for backup
	printf "MOVING INPUT DIRECTORY TO ARCHIVE SYNOLOGY\n"
	mv "${InputDirectory}/" "${ArchiveDirectory}/${today}/"

	printf "All Done.\n"



else
  printf "No videos to be tracked.\n"
fi


printf "$(date)\n"
