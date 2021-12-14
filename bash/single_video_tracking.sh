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
#		4. Correct the Ids for flies in multi-arena video
#		5. Generates diagnostic plot to evaluate the efficacy of tracking
#		6. Extracts the data tracking data and tabulates them into one csv file per video
#		7. Calculates indices and plots ethograms in R
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
# --------------------------------------------------------------------------------------------------------------------------------------------------------------




FileName=$(basename -a --suffix=."${video_type}" "${video_name}")
mkdir "${OutputDirectory}/${FileName}"
printf Copying video files from Synology
cp "${video_name}" "${OutputDirectory}/${FileName}/"


# Before doing anything else, let's set up the directory structure in bash and not in the individual
# other scripts.
mkdir "${OutputDirectory}/${FileName}/Backups"
mkdir "${OutputDirectory}/${FileName}/Logs"
mkdir "${OutputDirectory}/${FileName}/Results"


# --------------------------------------------------------------------------------------------------------------------------------------------------------------
### log file paths that need to be modified in scripts:

# optogenetic_light_detection_errors.log
# calibration_errors.log
# identity_assignment_errors.log

# --------------------------------------------------------------------------------------------------------------------------------------------------------------





# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# add some code logic to sort out the optimat "template" calibration files
# based on the imported variables.
# "${video_type}"
# "${arena_shape}"
# "${flies_per_arena}"
# "${number_of_arenas}"
# "${assay_type}"
best_calib_file=$(ls ../MATLAB/calib_files/ | grep "${video_type}" \
    | grep "${flies_per_arena}fly" \
    | grep "${number_of_arenas}arenas" \
    | grep "${arena_shape}" \
    | grep "${courtship}")

if [ -z "${best_calib_file}" ]; then
    printf No matching calib file.
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
    printf There is a matching calib file.
fi
# --------------------------------------------------------------------------------------------------------------------------------------------------------------






printf Now tracking: "${FileName}"
/usr/local/bin/matlab -nodisplay -nosplash -r "FileName=${FileName}; OutputDirectory=${OutputDirectory}; video_type=${video_type}; track_start=${track_start}; best_calib_file=${best_calib_file}; flies_per_arena=${flies_per_arena}; ../MATLAB/AutoTracking"
/usr/local/bin/matlab -nodisplay -nosplash -r "FileName=${FileName}; OutputDirectory=${OutputDirectory}; video_type=${video_type}; ../MATLAB/script_detect_optogenetic_light"
/usr/local/bin/matlab -nodisplay -nosplash -r "FileName=${FileName}; OutputDirectory=${OutputDirectory}; flies_per_arena=${flies_per_arena}; ../MATLAB/DeleteSingletonFlies"
/usr/local/bin/matlab -nodisplay -nosplash -r "FileName=${FileName}; OutputDirectory=${OutputDirectory}; ../MATLAB/ApplyClassifiers"
# add detect sex, modify Kristin Branson's "FlyTracker/tracking/CtraxJAABA/FlyTrackerClassifySex.m"
/usr/local/bin/matlab -nodisplay -nosplash -r "FileName=${FileName}; OutputDirectory=${OutputDirectory}; ../MATLAB/script_reassign_identities"
/usr/local/bin/matlab -nodisplay -nosplash -r "FileName=${FileName}; OutputDirectory=${OutputDirectory}; ../MATLAB/DiagnosticPlots"
/usr/local/bin/matlab -nodisplay -nosplash -r "FileName=${FileName}; OutputDirectory=${OutputDirectory}; ../MATLAB/ExtractData"
Rscript ../R/CalculateIndices_PlotEthograms.R --args "${OutputDirectory}" "${FileName}"






# --------------------------------------------------------------------------------------------------------------------------------------------------------------
	# save paths of backup files that need to change in each script. also should name these
	# backups more clearly ...

	# for X in */
	# do
	# 	cd "$X"/
	# 	cd "$X"/
	#
	# 	if [ -f ${X%/}-track_old.mat ]; then mv ${X%/}-track_old.mat ../Backups/; fi
	# 	if [ -f ${X%/}-track_id_corrected.mat ]; then mv ${X%/}-track_id_corrected.mat ../Backups/; fi
	#
	# 	if [ -f ${X%/}-feat_old.mat ]; then mv ${X%/}-feat_old.mat ../Backups/; fi
	# 	if [ -f ${X%/}-feat_id_corrected.mat ]; then mv ${X%/}-feat_id_corrected.mat ../Backups/; fi
	#
	# 	if [ -f ${X%/}-trackBackup.mat ]; then mv ${X%/}-trackBackup.mat ../Backups/; fi
	# 	if [ -f ${X%/}-featBackup.mat ]; then mv ${X%/}-featBackup.mat ../Backups/; fi
	# 	if [ -d ${X%/}_JAABA/trxBackup.mat ]; then mv ${X%/}_JAABA/trxBackup.mat ../Backups/; fi
	# 	if [ -d ${X%/}_JAABA/perframe/BackupPerframe ]; then mv ${X%/}_JAABA/perframe/BackupPerframe ../Backups/; fi
	#
	# 	cd $CurrentDirectory
	# done
# --------------------------------------------------------------------------------------------------------------------------------------------------------------





# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# Move the resulting tracking results to the Synology in each users folder
printf MOVING TRACKING RESULTS TO SYNOLOGY
for D in */
do
	Directory=$D
	User=${Directory%%-*}
	RecordingDate=${Directory#*-}
	VideoName=${RecordingDate#*-}
	RecordingDate=${RecordingDate%%-*}
	VideoName=${VideoName%%/}
	printf This is the Directory: $Directory
	printf This is the User: $User
	printf This is the Recording Date: $RecordingDate
	printf This is the Video Name: $VideoName
	mkdir -p /mnt/Synology/Tracked/$User/$RecordingDate
	cp -R $D /mnt/Synology/Tracked/$User/$RecordingDate/

done
# --------------------------------------------------------------------------------------------------------------------------------------------------------------


printf Done tracking video.
printf $(date)
