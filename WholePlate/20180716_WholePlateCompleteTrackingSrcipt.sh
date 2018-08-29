#!/bin/bash


# Aaron M Allen, 2018.06.20
#
# This script does the following;
#		1. Pulls videos off the Synology,
#		2. 
#		3. 
#		4. Tracks the videos with FlyTracker, in MatLab
#		5. Generates diagnostic plot to evaluate the efficacy of tracking
#		6. Applies the 'classifiers' with JAABADetect in MatLab, for behaviours that have already been trained
#		7. Extracts the data from the 'classifiers' and tabulates them into one csv file per plate
#
#
# Don't forget to;
#		1.  
#		2. 
#		3. 
#		4. 
#		5. 
#		6. 
#
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------------------

echo $(date)

MasterDirectory=$(pwd)
echo $MasterDirectory
# setting up a variable with todays date and making a folder for the modified courtship videos
today=$(date +%Y%m%d)
echo $today
today=${today}Tracked

WorkingDirectory=/home/aaron/Desktop/WorkingDirectory
mkdir $WorkingDirectory/$today/



# --------------------------------------------------------------------------------------
# Track all video files with FlyTracker, and apply classifiers with JAABA
# --------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------
echo FILE TRANSFER AND TRACKING




for U in /mnt/Synology/ToBeTracked/Test/*/
do
    CompressionDate=$(basename -a  "$U")
    pwd
    echo CHANGING INTO USER DIRECTORY: "$CompressionDate"
	cd $U
	pwd
	
	for Z in *.ufmf
	do
		FileName=$(basename -a --suffix=.ufmf "$Z")
		mkdir $WorkingDirectory/$today/"$FileName"
		echo COPYING VIDEO FILES FROM SYNOLOGY
		cp "$Z" $WorkingDirectory/$today/"$FileName"
		cd $WorkingDirectory/$today/"$FileName"
		
		echo COPYING MATLAB FILES INTO TRACKING DIRECTORY
		cp -r $MasterDirectory/AutoTracking.sh $WorkingDirectory/$today/"$FileName"/AutoTracking.sh
		cp -r $MasterDirectory/AutoTracking.m $WorkingDirectory/$today/"$FileName"/AutoTracking.m
		cp -r $MasterDirectory/ApplyClassifiers.m $WorkingDirectory/$today/"$FileName"/ApplyClassifiers.m
		cp -r $MasterDirectory/script_reassign_identities.m $WorkingDirectory/$today/"$FileName"/script_reassign_identities.m
		cp -r $MasterDirectory/run_calibrator_non_interactive.m $WorkingDirectory/$today/"$FileName"/run_calibrator_non_interactive.m
		/usr/local/bin/matlab  -r "run_calibrator_non_interactive" 
		cp -r  $WorkingDirectory/$today/"$FileName"/*_calibration.mat  $WorkingDirectory/$today/"$FileName"/calibration.mat
		

		echo STARTING AUTOTRACKING SCRIPT
		gnome-terminal -e ./AutoTracking.sh &
		echo CHANGING DIRECTORY BACK TO SYNOLOGY
		cd $U

		sleep 5s
		while [ $(pgrep -c "MATLAB") -gt 3 ]
		do
			sleep 2m
		done
	done

	# Wait for the tracking to finish before going on to next section
	echo JUST WAITNING FOR TRACKING TO FINISH
	while pgrep -x "MATLAB" > /dev/null
	do
		sleep 2m
	done

	cd $WorkingDirectory/$today/
	# Generate Diagnostic Plots
	echo DIAGNOSTIC PLOT
	cp -r $MasterDirectory/DiagnosticPlots.m $WorkingDirectory/$today/DiagnosticPlots.m
	matlab -nodisplay -nosplash -r "DiagnosticPlots"

	## Extracting Data for Each Plate
	echo EXTRACT DATA AND PDFs
	cp -r $MasterDirectory/ExtractDataAndPDFs.m $WorkingDirectory/$today/ExtractDataAndPDFs.m
	matlab -nodisplay -nosplash -r "ExtractDataAndPDFs"

	## Calculate indices with R
	echo CALCULATE INDICES
	cp -r $MasterDirectory/CalculateIndices.R $WorkingDirectory/$today/CalculateIndices.R
	Rscript CalculateIndices.R

	# Clean up of matlab files
	echo REMOVING MATLAB SCRIPTS
	CurrentDirectory=$(pwd)

	rm DiagnosticPlots.m
	rm ExtractDataAndPDFs.m
	rm CalculateIndices.R
	for X in */
	do
		cd "$X"/
		rm AutoTracking.sh
		rm AutoTracking.m
		rm ApplyClassifiers.m
		rm script_reassign_identities.m
		
		cd $CurrentDirectory
	done
	
	# Moving any error log files for the Diagnostic... and Extract...
	for L in *DiagnosticPlot_errors.log
	do
		LogFile=$L
		Directory=${LogFile%%DiagnosticPlot_errors.log}
		mv $LogFile $Directory/
	done
	for L in *ExtractDataAndPDFs_errors.log
	do
		LogFile=$L
		Directory=${LogFile%%ExtractDataAndPDFs_errors.log}
		mv $LogFile $Directory/
	done



	echo MOVING TRACKING RESULTS TO SYNOLOGY
	cd $WorkingDirectory/
	for D in */
	do
		Directory=$D
		User=${Directory%%_*}
		RecordingDate=${Directory#*_}
		VideoName=${RecordingDate#*_}
		RecordingDate=${RecordingDate%%_*}

		mkdir /mnt/Synology/Tracked/$User
		mkdir /mnt/Synology/Tracked/$User/$RecordingDate
	
		mv $today /mnt/Synology/Tracked/$User/$RecordingDate
	done
	cd /mnt/Synology/ToBeTracked/
done


echo All Done.
echo $(date)

sleep infinity