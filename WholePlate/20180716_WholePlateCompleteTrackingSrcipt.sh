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

#!/bin/bash

echo $(date)

MasterDirectory=$(pwd)
echo $MasterDirectory
# setting up a variable with todays date and making a folder for the modified courtship videos
today=$(date +%Y-%m-%d)
echo $today

read -p "Enter the directory you with the files you wish to track:  " InputDirectory
read -p "Enter the directory where you wish results to go:  " WorkingDirectory
echo "This is the input directory: $InputDirectory"
echo "This is the ouptut directory: $WorkingDirectory"

pwd
cd $WorkingDirectory/
pwd

mkdir $today/
cd $today





# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Track all video files with FlyTracker, and apply classifiers with JAABA
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
		cp -r $MasterDirectory/ApplyClassifiers.m $WorkingDirectory/$today/"$FileName"/ApplyClassifiers.m
		cp -r $MasterDirectory/script_reassign_identities.m $WorkingDirectory/$today/"$FileName"/script_reassign_identities.m
		cp -r $MasterDirectory/WholePlateCalibration.mat $WorkingDirectory/$today/"$FileName"/calibration.mat
		echo Now tracking: "$A"
		bash AutoTracking.sh &
	done

	sleep 5s
	
	# Check if matlab is running
	while [ $(pgrep -c "MATLAB") -gt 2 ]
	do
		sleep 2m
	done
	cd ..
done

# Wait for the tracking to finish before going on to next section
echo "Just waiting for the tracking to finish."
while pgrep -x "MATLAB" > /dev/null
do
	sleep 2m
done



# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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





## Clean up of matlab files
CurrentDirectory=$(pwd)

rm DiagnosticPlots.m
rm ExtractDataAndPDFs.m
rm CalculateIndices.R

for X in */
do
	cd "$X"/
	rm ApplyClassifiers.m
	rm AutoTracking.m
	rm script_reassign_identities.m
	
	cd $CurrentDirectory
done



echo All Done.
echo $(date)

sleep infinity

