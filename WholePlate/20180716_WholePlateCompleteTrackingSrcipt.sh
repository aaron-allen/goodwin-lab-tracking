# Aaron M Allen, 2018.06.20
#
# This script does the following;
#		1. Pulls videos off the Synology,
#		2. Crops out the individual arenas,
#		3. Converts them to ufmf,
#		4. Tracks the videos with FlyTracker, in MatLab
#		5. Generates diagnostic plot to evaluate the efficacy of tracking
#		6. Applies the 'classifiers' with JAABADetect in MatLab, for behaviours that have already been trained
#		7. Extracts the data from the 'classifiers' and tabulates them into one csv file per plate
#
#
# Don't forget to;
#		1.  
#		2. 
#		3. Update the file paths for 'FlyTracker', 'JAABA', and the 'JAB' files in the start of the 'TrackDiagnosticClassifiers.m' script.
#		4. Update the file paths for the individual 'JAB' files in the 'JABfilelist.txt' file.
#		5. Double check the coordinates for the spatial video cropping in lines 95-114 or 135-154.
#		6. Double check the times for temporal video cropping in line 81.
#
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------------------------------

#!/bin/bash

echo $(date)

MasterDirectory=$(pwd)
echo $MasterDirectory
# setting up a variable with todays date and making a folder for the modified courtship videos
today=$(date +%Y-%m-%d)
echo $today

read -p "Enter the directory you with the files you wish to track:  " InputDirectory
read -p "Enter the directory where you wish results to go:  " OutputDirectory
echo "This is the input directory: $InputDirectory"
echo "This is the ouptut directory: $OutputDirectory"

pwd
cd $OutputDirectory/
pwd

mkdir $today/
cd $today





# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Track all video files with FlyTracker
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo FILE TRANSFER AND TRACKING SUB-ROUTINE

for Z in "$InputDirectory/*.ufmf"
do
	FileName=$(basename -a --suffix=.ufmf "$Z")
	mkdir $FileName
	echo COPYING FILES FROM SYNOLOGY
	cp "$InputDirectory/$Z" "$OutputDirectory/$today/$FileName/$Z"
	cd $FileName
	for A in *.ufmf
	do
		echo Copying Matlab files to ufmf folder
		cp -r $MasterDirectory/TrackDiagnosticClassifiers.m $OutputDirectory/$today/$FileName/TrackDiagnosticClassifiers.m
		cp -r $MasterDirectory/WholePlateCalibration.mat $OutputDirectory/$today/$FileName/calibration.mat
		echo Now tracking: $A
		xterm $MasterDirectory/TrackDiagnosticClassifiers.sh &
	done
	
	# Check if matlab is running
	NumberOfMatlabs=$(pgrep -c "xterm")
	if [ "$NumberOfMatlabs" -gt 5 ]
	then
		echo "Too many MATLABs running, be patient..."
		sleep 5m
	else
		echo "A space is available, ADDING NEXT VIDEO!"
	fi
	cd ..
done

# Wait for the tracking to finish before going on to next section
while pgrep -x "xterm" > /dev/null
do
	echo "Just waiting for the tracking to finish."
	sleep 5m
done



# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Apply Classifiers
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo JAABA CLASSIFIER SUB-ROUTINE











# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Rearrange ouptut data
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo DATA REARRANGEMENT SUB-ROUTINE












# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Generate Diagnostic Plots
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo DIAGNOSTIC PLOT SUB-ROUTINE














## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Extracting Data for Each Plate
## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#for X in *.ufmf
#do
#	echo Copy ExtractDataAndPDFs.m into: $X
#	cp -r $MasterDirectory/WholePlateExtractDataAndPDFs.m $OutputDirectory/$today/ufmf/${Z%.*}/
#	echo Now entering: $Z
#	cd $Z/Videos/
#	echo Extracting Data For: $Z
#	gnome-terminal -x  matlab -nodisplay -nosplash -r "ExtractDataAndPDFs"
#	sleep 120
#	cd ..
#	cd ..
#done




## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Clean up of matlab files
## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#for /d X in [*]; do
#	cd $X/Videos/
#	rm ExtractDataAndPDFs.m
#	for /d B in [*]; do
#		cd B
#		rm TrackDiagnosticClassifiers.m
#		rm WholePlateCalibration.mat
#		cd ..
#	done
#	cd ..
#	cd ..
#done


echo All Done.
date /T
time /T

sleep

