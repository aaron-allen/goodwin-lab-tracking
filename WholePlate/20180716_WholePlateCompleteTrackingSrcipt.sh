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
    UserName=$(basename -a  "$U")
    pwd
    echo CHANGING INTO USER DIRECTORY: "$UserName"
	cd "$U"
	pwd

    for D in */
    do
    	RecordingDate=$(basename -a  "$D")
    	mkdir $WorkingDirectory/$today/$RecordingDate/
    	pwd
    	echo CHANGING INTO DATE DIRECTORY "$RecordingDate"
    	cd "$D"
		pwd
		
		
		for Z in *.ufmf
		do
			FileName=$(basename -a --suffix=.ufmf "$Z")
			mkdir $WorkingDirectory/$today/$RecordingDate/"$FileName"
			echo COPYING VIDEO FILES FROM SYNOLOGY
			cp "$Z" $WorkingDirectory/$today/$RecordingDate/"$FileName"
			cd $WorkingDirectory/$today/$RecordingDate/"$FileName"
			
			echo COPYING MATLAB FILES INTO TRACKING DIRECTORY
			mkdir $WorkingDirectory/$today/$RecordingDate
			cp -r $MasterDirectory/AutoTracking.sh $WorkingDirectory/$today/$RecordingDate/"$FileName"/AutoTracking.sh
			cp -r $MasterDirectory/AutoTracking.m $WorkingDirectory/$today/$RecordingDate/"$FileName"/AutoTracking.m
			cp -r $MasterDirectory/ApplyClassifiers.m $WorkingDirectory/$today/$RecordingDate/"$FileName"/ApplyClassifiers.m
			cp -r $MasterDirectory/script_reassign_identities.m $WorkingDirectory/$today/$RecordingDate/"$FileName"/script_reassign_identities.m
			cp -r $MasterDirectory/WholePlateCalibration.mat $WorkingDirectory/$today/$RecordingDate/"$FileName"/calibration.mat

			echo STARTING AUTOTRACKING SCRIPT
			gnome-terminal -e ./AutoTracking.sh &
			echo CHANGING DIRECTORY BACK TO SYNOLOGY
			cd /mnt/Synology/ToBeTracked/Test/$UserName/$RecordingDate
	
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

		cd $WorkingDirectory/$today/$RecordingDate/
		# Generate Diagnostic Plots
		echo DIAGNOSTIC PLOT
		cp -r $MasterDirectory/DiagnosticPlots.m $WorkingDirectory/$today/$RecordingDate/DiagnosticPlots.m
		matlab -nodisplay -nosplash -r "DiagnosticPlots"

		## Extracting Data for Each Plate
		echo EXTRACT DATA AND PDFs
		cp -r $MasterDirectory/ExtractDataAndPDFs.m $WorkingDirectory/$today/$RecordingDate/ExtractDataAndPDFs.m
		matlab -nodisplay -nosplash -r "ExtractDataAndPDFs"

		## Calculate indices with R
		echo CALCULATE INDICES
		cp -r $MasterDirectory/CalculateIndices.R $WorkingDirectory/$today/$RecordingDate/CalculateIndices.R
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
		

		echo MOVING TRACKING RESULTS TO SYNOLOGY
		cd $WorkingDirectory/
    	mkdir /mnt/Synology/Tracked/Test/
		mkdir /mnt/Synology/Tracked/Test/$UserName/
		
		mv $today /mnt/Synology/Tracked/Test/$UserName/

		cd /mnt/Synology/ToBeTracked/Test/$UserName/
	done
	cd /mnt/Synology/ToBeTracked/Test/
done

echo All Done.
echo $(date)

sleep infinity