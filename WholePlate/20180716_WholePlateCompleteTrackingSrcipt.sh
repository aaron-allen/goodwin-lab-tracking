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
today=$(date +%Y%m%d)
echo $today
today=${today}Tracked
echo  "$today"

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
		cp -r $MasterDirectory/run_calibrator_non_interactive.m $WorkingDirectory/$today/"$FileName"/run_calibrator_non_interactive.m
		cp -r $MasterDirectory/ApplyClassifiers.m $WorkingDirectory/$today/"$FileName"/ApplyClassifiers.m
		cp -r $MasterDirectory/script_reassign_identities.m $WorkingDirectory/$today/"$FileName"/script_reassign_identities.m
        /usr/local/bin/matlab  -r "run_calibrator_non_interactive"
		cp -r  $WorkingDirectory/$today/"$FileName"/*_calibration.mat  $WorkingDirectory/$today/"$FileName"/calibration.mat
		echo Now tracking: "$A"
		bash AutoTracking.sh &
	done

	sleep 5s
	
	# Check if matlab is running
	while [ $(pgrep -c "MATLAB") -gt 3 ]
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
/usr/local/bin/matlab -nodisplay -nosplash -r "DiagnosticPlots"

## Extracting Data for Each Plate
echo EXTRACT DATA AND PDFs
cp -r $MasterDirectory/ExtractDataAndPDFs.m $WorkingDirectory/$today/ExtractDataAndPDFs.m
/usr/local/bin/matlab -nodisplay -nosplash -r "ExtractDataAndPDFs"

## Calculate indices with R
echo CALCULATE INDICES
cp -r $MasterDirectory/CalculateIndices.R $WorkingDirectory/$today/CalculateIndices.R
Rscript CalculateIndices.R

# Take all the individual pdfs of the Diagnotic plots and merge them into one pdf per video
CurrentDirectory=$(pwd)
for P in */
do
	cd $P/Results
	echo MERGING DIAGNOSTIC PLOTS INTO ONE PDF FOR $P
	pdftk *.pdf cat output ${P%%/*}_DiagnosticPlots.pdf
	rm *[0-9].pdf
	cd $CurrentDirectory
done


## Clean up of matlab files

rm DiagnosticPlots.m
rm ExtractDataAndPDFs.m
rm CalculateIndices.R

for X in */
do
	cd "$X"/
	rm ApplyClassifiers.m
	rm AutoTracking.sh
	rm AutoTracking.m
	rm script_reassign_identities.m
	rm run_calibrator_non_interactive.m

	cd $CurrentDirectory
done

# Moving any error log files for the Diagnostic... and Extract...
echo "Now moving log files"
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
for D in */
do
	Directory=$D
	User=${Directory%%-*}
	RecordingDate=${Directory#*-}
	VideoName=${RecordingDate#*-}
	RecordingDate=${RecordingDate%%-*}

	mkdir -p /mnt/Synology/Tracked/$User/$RecordingDate

	mv $D /mnt/Synology/Tracked/$User/$RecordingDate/
done

echo MOVING INPUT DIRECTORY TO ARCHIVE SYNOLOGY
mv $InputDirectory /mnt/Synology/Archive/uFMF



echo All Done.
echo $(date)

sleep infinity

