#!/bin/bash


# Author: Aaron M Allen
# Date: 2018.10.09
#     updated: 2021.12.02
#
#
#
#
# This script does the following;
#		1.
#		2.
#		3.
#		4.
#		5.
#		6.
#		7. 
#
#
#
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------------------


echo $(date)
today=$(date +%Y%m%d)

# setting up a variable with todays date and making a folder for the modified courtship videos
CodeDirectory=$(pwd)
ToBeTrackedDirectory=/mnt/Synology/ToBeTracked/VideosFromStaions
WorkingDirectory=/mnt/LocalData/Tracking

# echo The Code Directory is: $CodeDirectory
# echo This is the input directory: $ToBeTrackedDirectory
# echo This is the ouptut directory: $WorkingDirectory



# Check to see if there are any videos to be tracked
csv_file="$ToBeTrackedDirectory/video_list.csv"
if [ -s $csv_file ]; then
	echo "There are videos to be tracked"
	InputDirectory="${ToBeTrackedDirectory}/../NowTracking/videos"
	OutputDirectory="$WorkingDirectory/${today}Tracked"
	mkdir $OutputDirectory


	#---------------------------------------------------------------------------
	# Setup freeze of videos that need to be tracked
	mv synology/ToBeTracked/video_list.csv synology/NowTracking/video_list.csv
	ls synology/ToBeTracked/videos > synology/NowTracking/videos_in_ToBeTracked.txt
	echo -n "" > synology/ToBeTracked/video_list.csv


	csv_file='synology/NowTracking/video_list.csv'
	while IFS=',' read -r user video_name video_type tracking_start_time_in_seconds flies_per_arena sex_ratio number_of_arenas arena_shape assay_type; do
	    echo -e "Video Name:\t $video_name"
	    if [ -f "synology/ToBeTracked/videos/$video_name" ]; then
	      echo -e '\tMoving video to NowTracking'
	      mv synology/ToBeTracked/videos/$video_name synology/NowTracking/videos/
	    fi
	done < $csv_file

	# any video that's not in the to be tracked settings file will be moved to the non-tracked directory
	echo -e "\n\n"
	csv_file='synology/NowTracking/videos_in_ToBeTracked.txt'
	while IFS=',' read -r video_name; do
	    #echo -e "Video Name\t:\t $video_name"
	    if [ -f "synology/ToBeTracked/videos/$video_name" ]; then
	      echo -e "Video Name:\t $video_name"
	      echo -e '\tMoving video to NonTrackedVideos'
	      mv "synology/ToBeTracked/videos/$video_name" synology/NonTrackedVideos/videos/
	    fi
	done < $csv_file
	#---------------------------------------------------------------------------




	# --------------------------------------------------------------------------
	# Track all video files with FlyTracker, and apply classifiers with JAABA
	echo FILE TRANSFER AND TRACKING
	csv_file="${InputDirectory}/../video_list.csv"
	while IFS=',' read -r user video_name video_type tracking_start_time_in_seconds flies_per_arena sex_ratio number_of_arenas arena_shape assay_type; do

		# run single_video_tracking.sh
		bash single_video_tracking.sh ${today} \
									  ${CodeDirectory} \
									  ${ToBeTrackedDirectory} \
									  ${WorkingDirectory} \
									  ${InputDirectory} \
									  ${user} \
									  ${video_name} \
									  ${video_type} \
									  ${tracking_start_time_in_seconds} \
									  ${flies_per_arena} \
									  ${sex_ratio} \
									  ${number_of_arenas} \
									  ${arena_shape} \
									  ${assay_type}

	done


	# --------------------------------------------------------------------------
	# Move the input direstory to the archive synology for backup
	echo MOVING INPUT DIRECTORY TO ARCHIVE SYNOLOGY
	mv $InputDirectory/ /mnt/Synology/Archive/uFMF/${today}

	echo All Done.
	echo $(date)



else
  echo "No videos to be tracked."
fi


echo $(date)
