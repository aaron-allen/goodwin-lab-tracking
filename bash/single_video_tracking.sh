#!/bin/bash


# Author: Aaron M Allen
# Date: 2018.10.09
#     updated: 2021.12.02
#
#
#
#
# This script does the following;
#		1. Pulls videos off the Synology,
#		2. Tracks the videos with FlyTracker, in MatLab
#		3. Applies the 'classifiers' with JAABADetect in MatLab, for behaviours that have already been trained
#		4. Correct the Ids for flies in multi-arena video, in Matlab
#		5. Extracts the track.mat and feat.mat data and saves a .csv file, in R
#       6. Generates diagnostic plot to evaluate the efficacy of tracking, in R
#		7. Calculates indices and plots ethograms, in R
#
#
#
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------







# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# Inherit/import/accept variables:
today="${1}"
CodeDirectory="${2}"
ToBeTrackedDirectory="${3}"
WorkingDirectory="${4}"
InputDirectory="${5}"
OutputDirectory="${6}"
user="${7}"
video_name="${8}"
video_type="${9}"
track_start="${10}"
flies_per_arena="${11}"
sex_ratio="${12}"
number_of_arenas="${13}"
arena_shape="${14}"
assay_type="${15}"
optogenetics_light="${16}"
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

printf "\n\n\n"
printf "\n\ntoday is : ${today}\n"
printf "code dir is : ${CodeDirectory}\n"
printf "tobetracked dir is : ${ToBeTrackedDirectory}\n"
printf "working dir is : ${WorkingDirectory}\n"
printf "input dir is : ${InputDirectory}\n"
printf "output dir is : ${OutputDirectory}\n"
printf "user is : ${user}\n"
printf "video name is  : ${video_name}\n"
printf "video type is : ${video_type}\n"
printf "start time is  : ${track_start}\n"
printf "n flies is : ${flies_per_arena}\n"
printf "sex ratio is : ${sex_ratio}\n"
printf "n arenas is : ${number_of_arenas}\n"
printf "arena shape is : ${arena_shape}\n"
printf "assay type is : ${assay_type}\n"
printf "opto light is : ${optogenetics_light}\n"
printf "\n\n\n"



FileName=$(basename -a --suffix=."${video_type}" "${video_name}")
mkdir "${OutputDirectory}/${FileName}"
printf "Copying video files from Synology\n"
cp "${InputDirectory}/${video_name}" "${OutputDirectory}/${FileName}/"


# Before doing anything else, let's set up the directory structure in bash and not in the individual
# other scripts.
mkdir -p "${OutputDirectory}/${FileName}/Backups/${FileName}_JAABA/perframe/"
mkdir "${OutputDirectory}/${FileName}/Logs"
mkdir "${OutputDirectory}/${FileName}/Results"


# --------------------------------------------------------------------------------------------------------------------------------------------------------------
### log file paths that need to be modified in scripts:

# optogenetic_light_detection_errors.log
# calibration_errors.log
# identity_assignment_errors.log
# --------------------------------------------------------------------------------------------------------------------------------------------------------------



# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# add some code logic to sort out the optimal "template" calibration files
# based on the imported variables.
#   "${video_type}"
#   "${arena_shape}"
#   "${flies_per_arena}"
#   "${number_of_arenas}"
#   "${assay_type}"
best_calib_file=$(ls ../MATLAB/parent_calib_files/ | grep "${video_type}" \
    | grep "${flies_per_arena}fly" \
    | grep "${number_of_arenas}arena" \
    | grep "${arena_shape}" \
    | grep "${assay_type}")

if [ -z "${best_calib_file}" ]; then
    printf "\n\n\n"
    printf "No matching calib file.\n"
    # ----------------------------------------------------------------------------------------------------------------------------------------------------------
	# CALIBRATION
	### Do we need this bit with Kristin Bransons 'force_calib' option for the tracker. We may be able to supply template
	### calibration files and then just force re-calibration to adjust the masks etc (need to test if this works). Also
	### need to compare Annika's other changes to the 'calibrator.m' to see what else we may need to patch.

	# printf Now calibrating: "$A"
	# /usr/local/bin/matlab  -r "FileName=${FileName}; OutputDirectory=${OutputDirectory}; video_type=${video_type}; run_calibrator_non_interactive_xflies"
	# # do we still need to have a copy of this file? could we just rename it, instead of copying it?
	# cp -r  $WorkingDirectory/$today/"${FileName}"/*_calibration.mat  $WorkingDirectory/$today/"${FileName}"/calibration.mat
    # ----------------------------------------------------------------------------------------------------------------------------------------------------------
else
    printf "\n\n\n"
    printf "There is a matching calib file.\n"
    printf "\tThe best match is: ${best_calib_file}\n\n"
fi
# --------------------------------------------------------------------------------------------------------------------------------------------------------------



printf "\n\n\n"



# --------------------------------------------------------------------------------------------------------------------------------------------------------------
printf "\n\n\nNow tracking: ${video_name} ...\n"
/usr/local/bin/matlab -nodisplay -nosplash -r "FileName='${FileName}'; \
                                                OutputDirectory='${OutputDirectory}'; \
                                                video_type='${video_type}'; \
                                                track_start=${track_start}; \
                                                best_calib_file='${best_calib_file}'; \
                                                flies_per_arena=${flies_per_arena}; \
                                                sex_ratio=${sex_ratio}; \
                                                addpath(genpath('${CodeDirectory}')); \
                                                AutoTracking"

# Only run the optogenetic light detector if the video is an optogenetics experiment
if [[ ${optogenetics_light} ]]; then
    printf "\n\n\n\tDetecting optogenetic light ...\n"
    /usr/local/bin/matlab -nodisplay -nosplash -r "FileName='${FileName}'; \
                                                    OutputDirectory='${OutputDirectory}'; \
                                                    video_type='${video_type}'; \
                                                    addpath(genpath('${CodeDirectory}')); \
                                                    script_detect_optogenetic_light"
fi

# Only run ApplyClassifiers if there are 2 flies per arena, as that is what the jab files
# were trained with.
if [[ ${flies_per_arena} == 2 ]]; then
    printf "\n\n\n\tDetecting singleton flies ...\n"# Before attempting to run ApplyClassifiers, check for any rogue singletons
    /usr/local/bin/matlab -nodisplay -nosplash -r "FileName='${FileName}'; \
                                                    OutputDirectory='${OutputDirectory}'; \
                                                    addpath(genpath('${CodeDirectory}')); \
                                                    DeleteSingletonFlies"
    printf "\n\n\n\tApplying classifiers ...\n"
    /usr/local/bin/matlab -nodisplay -nosplash -r "FileName='${FileName}'; \
                                                    OutputDirectory='${OutputDirectory}'; \
                                                    addpath(genpath('${CodeDirectory}')); \
                                                    ApplyClassifiers"
fi

if [[ ${flies_per_arena} == 2 ]] && [[ ${number_of_arenas} == 20 ]]; then
    # Re-assign the identities of the flies such that fly 1 and 2 are in arena 1, fly 3 and 4
    # are in arena 2, etc...
    printf "\n\n\n\tRe-assigning identities ...\n"
    /usr/local/bin/matlab -nodisplay -nosplash -r "FileName='${FileName}'; \
                                                    OutputDirectory='${OutputDirectory}'; \
                                                    addpath(genpath('${CodeDirectory}')); \
                                                    script_reassign_identities"
fi

printf "\n\n\n\tExtracting tracking data and plotting diagnotic plots ...\n"
/usr/bin/Rscript ../R/Extact_and_Plot_Tracking_Data.R --args "${OutputDirectory}" "${FileName}" "${flies_per_arena}"

# Only calculate indices if there are 2 flies per arena
if [[ ${flies_per_arena} == 2 ]]; then
    printf "\n\n\n\tCalculating indices and plotting ethograms ...\n"
    /usr/bin/Rscript ../R/CalculateIndices_PlotEthograms.R --args "${OutputDirectory}" "${FileName}"
fi



# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# Move the resulting tracking results to the Synology in each users folder
printf "\n\n\nMoving tracking results to the Synology\n"
mkdir -p "/mnt/Synology/Tracked/${user}/${today}"
cp -R "${OutputDirectory}/${video_name}" "/mnt/Synology/Tracked/${user}/${today}/"
# --------------------------------------------------------------------------------------------------------------------------------------------------------------


printf "\n\n\nDone tracking video.\n"
printf "$(date)\n\n\n"
