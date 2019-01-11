#!/bin/bash


# Aaron M Allen, 2018.10.09
#
# This script does the following;
#		1. Pulls videos off the Synology,
#		2. Tracks the videos with FlyTracker, in MatLab
#		3. Applies the 'classifiers' with JAABADetect in MatLab, for behaviours that have already been trained
#		4. Correct the Ids for flies in whole plate video
#		5. Generates diagnostic plot to evaluate the efficacy of tracking
#		6. Extracts the data from the 'classifiers' and tabulates them into one csv file per plate
#		7. Calculates indices and plots ethograms in R
#
#
# Don't forget to update paths in the following files;
#		1. AutoTracking.m
#		2. run_calibrator_non_interactive.m
#		3. ApplyClassifiers.m
#		4. script_reassign_identities.m
#
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------------------


echo $(date)

# setting up a variable with todays date and making a folder for the modified courtship videos
MasterDirectory=$(pwd)
echo The Master Directory is: $MasterDirectory
today=$(date +%Y%m%d)
# echo $today
today=${today}Tracked
# echo  "$today"

if [ -d /mnt/Synology/ToBeTracked/*Converted ]; then
	echo "Input directory to be tracked exists."
	#read -p "Enter the directory you with the files you wish to track:  " InputDirectory
	#read -p "Enter the directory where you wish results to go:  " WorkingDirectory
	InputDirectory=/mnt/Synology/ToBeTracked/*Converted
	WorkingDirectory=/mnt/LocalData/WorkingDirectory
	echo This is the input directory: $InputDirectory
	echo This is the ouptut directory: $WorkingDirectory

	pwd
	cd $WorkingDirectory/
	pwd
	mkdir $today/
	cd $today
	CurrentDirectory=$(pwd)


	# Track all video files with FlyTracker, and apply classifiers with JAABA
	# -------------------------------------------------------------------------------------------------------------------------------------------------------------
	echo FILE TRANSFER AND TRACKING
	for Z in $InputDirectory/*.ufmf
	do
		FileName=$(basename -a --suffix=.ufmf "$Z")
		mkdir "$FileName"
		echo Copying video files from Synology
		cp "$Z" $WorkingDirectory/$today/"$FileName"/
		cd "$FileName"
		for A in *.ufmf
		do
			echo Copying Matlab files into tracking directory
			cp -r $MasterDirectory/AutoTracking.sh $WorkingDirectory/$today/"$FileName"/AutoTracking.sh
			cp -r $MasterDirectory/AutoTracking.m $WorkingDirectory/$today/"$FileName"/AutoTracking.m
			cp -r $MasterDirectory/run_calibrator_non_interactive_xflies.m $WorkingDirectory/$today/"$FileName"/run_calibrator_non_interactive_xflies.m
			cp -r $MasterDirectory/DeleteSingletonFlies.m $WorkingDirectory/$today/"$FileName"/DeleteSingletonFlies.m
			cp -r $MasterDirectory/ApplyClassifiers.m $WorkingDirectory/$today/"$FileName"/ApplyClassifiers.m
			cp -r $MasterDirectory/script_reassign_identities.m $WorkingDirectory/$today/"$FileName"/script_reassign_identities.m
			/usr/local/bin/matlab  -r "run_calibrator_non_interactive_xflies"
			cp -r  $WorkingDirectory/$today/"$FileName"/*_calibration.mat  $WorkingDirectory/$today/"$FileName"/calibration.mat
			echo Now tracking: "$A"
			bash AutoTracking.sh &
			#gnome-terminal -- ./AutoTracking.sh &
		done
		cd $CurrentDirectory
		sleep 5s    # 5 second lag to allow MATLAB to open
		
		# Check if matlab is running
		while [ $(pgrep -c "MATLAB") -gt 3 ]
		do
			sleep 2m
		done
	done

	# Wait for the tracking to finish before going on to next section
	echo "Just waiting for the tracking to finish."
	while pgrep -x "MATLAB" > /dev/null
	do
		sleep 2m
	done


	# Generate Diagnostic Plots
	# -------------------------------------------------------------------------------------------------------------------------------------------------------------
	echo DIAGNOSTIC PLOT
	cp -r $MasterDirectory/DiagnosticPlots.m $WorkingDirectory/$today/DiagnosticPlots.m
	/usr/local/bin/matlab -nodisplay -nosplash -r "DiagnosticPlots"
	# Take all the individual pdfs of the Diagnotic plots and merge them into one pdf per video
	for P in */
	do
		cd $P/Results
		echo MERGING DIAGNOSTIC PLOTS INTO ONE PDF FOR $P
		pdftk *.pdf cat output ${P%%/*}_DiagnosticPlots.pdf
		rm *[0-9].pdf
		cd $CurrentDirectory
	done

	# Extracting Data for Each Plate
	# -------------------------------------------------------------------------------------------------------------------------------------------------------------
	echo EXTRACT DATA AND PDFs
	cp -r $MasterDirectory/ExtractData.m $WorkingDirectory/$today/ExtractData.m
	/usr/local/bin/matlab -nodisplay -nosplash -r "ExtractData"

	# Calculate indices with R
	# -------------------------------------------------------------------------------------------------------------------------------------------------------------
	echo CALCULATE INDICES
	cp -r $MasterDirectory/CalculateIndices.R $WorkingDirectory/$today/CalculateIndices.R
	Rscript CalculateIndices.R



	# Clean up ...
	# -------------------------------------------------------------------------------------------------------------------------------------------------------------

	# Clean up of matlab files
	rm DiagnosticPlots.m
	rm ExtractData.m
	rm CalculateIndices.R
	for X in */
	do
		cd "$X"/
		rm DeleteSingletonFlies.m
		rm ApplyClassifiers.m
		rm AutoTracking.sh
		rm AutoTracking.m
		rm script_reassign_identities.m
		rm run_calibrator_non_interactive_xflies.m
		

		mkdir Backups
		mkdir Logs

		if [ -f tracker_logfile.log ]; then mv tracker_logfile.log Logs/; fi
		if [ -f JAABA_logfile.log ]; then mv JAABA_logfile.log Logs/; fi
		if [ -f DeleteSingleFly_logfile.log ]; then mv DeleteSingleFly_logfile.log Logs/; fi

		cd "$X"/

		if [ -f ${X%/}-track_old.mat ]; then mv ${X%/}-track_old.mat ../Backups/; fi
		if [ -f ${X%/}-track_id_corrected.mat ]; then mv ${X%/}-track_id_corrected.mat ../Backups/; fi

		if [ -f ${X%/}-feat_old.mat ]; then mv ${X%/}-feat_old.mat ../Backups/; fi
		if [ -f ${X%/}-feat_id_corrected.mat.mat ]; then mv ${X%/}-feat_id_corrected.mat ../Backups/; fi

		if [ -f ${X%/}-trackBackup.mat ]; then mv ${X%/}-trackBackup.mat ../Backups/; fi
		if [ -f ${X%/}-featBackup.mat ]; then mv ${X%/}-featBackup.mat ../Backups/; fi
		if [ -d ${X%/}_JAABA/perframe/BackupPerframe ]; then mv ${X%/}_JAABA/perframe/BackupPerframe ../Backups/; fi

		cd $CurrentDirectory
	done


	# Moving any error log files for the Diagnostic... and Extract...
	echo "Now moving any error log files"
	DiagnosticErrors=$(ls *DiagnosticPlot_errors.log 2> /dev/null | wc -l)
	if [ "$DiagnosticErrors" != "0" ]
	then
		echo Diagnostic Plot errors exist
		for L in *DiagnosticPlot_errors.log
		do
			Directory=${L%%DiagnosticPlot_errors.log}
			mv $L $Directory/Logs/
		done
	else
		echo No Diagnostic Plot errors
	fi
	ExtractError=$(ls *ExtractData_errors.log 2> /dev/null | wc -l)
	if [ "$ExtractError" != "0" ]
	then
		echo Extract Data errors exist
		for L in *ExtractData_errors.log
		do
			Directory=${L%%ExtractData_errors.log}
			mv $L $Directory/Logs/
		done
	else
		echo No Extract Data Plot errors
	fi

	# Move the resulting tracking results to the Synology in each users folder
	echo MOVING TRACKING RESULTS TO SYNOLOGY
	for D in */
	do
		Directory=$D
		User=${Directory%%-*}
		RecordingDate=${Directory#*-}
		VideoName=${RecordingDate#*-}
		RecordingDate=${RecordingDate%%-*}
		VideoName=${VideoName%%/}
		echo This is the Directory: $Directory
		echo This is the User: $User
		echo This is the Recording Date: $RecordingDate
		echo This is the Video Name: $VideoName
		mkdir -p /mnt/Synology/Tracked/$User/$RecordingDate
		cp -R $D /mnt/Synology/Tracked/$User/$RecordingDate/
		cd $CurrentDirectory
	 done

	# Move the input direstory to the archive synology for backup
	echo MOVING INPUT DIRECTORY TO ARCHIVE SYNOLOGY
	mv $InputDirectory /mnt/Synology/Archive/uFMF

	echo All Done.
	echo $(date)
	sleep infinity
else
	echo "No input directory to be tracked."
fi
