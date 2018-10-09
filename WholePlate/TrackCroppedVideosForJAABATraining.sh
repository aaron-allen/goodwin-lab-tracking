#!/bin/bash

# Aaron M. Allen, 2018.10.09
# This script is used to autotrack single arena videos, with the intent to be used for JAABA classifier training.
# Currently you need to supply a calibration file, as the run_calibrator_non_interactive.m assumes 20 chambers.


# setting up a variable with todays date and making a folder for the modified courtship videos
echo $(date)
MasterDirectory=$(pwd)
echo $MasterDirectory
today=$(date +%Y%m%d)
echo $today
today=${today}Tracked
echo  "$today"

#read -p "Enter the directory you with the files you wish to track:  " InputDirectory
#read -p "Enter the directory where you wish results to go:  " WorkingDirectory
InputDirectory=/mnt/Synology/ToBeTracked/*JAABATraining
WorkingDirectory=/mnt/LocalData/WorkingDirectory
echo This is the input directory: $InputDirectory
echo This is the ouptut directory: $WorkingDirectory

pwd
cd $WorkingDirectory/
pwd
mkdir $today/
cd $today


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
		cp -r $MasterDirectory/AutoTracking.m $WorkingDirectory/$today/"$FileName"/AutoTracking.m
		cp -r  $MasterDirectory/SingleChamberCalibration.mat  $WorkingDirectory/$today/"$FileName"/calibration.mat
		#cp -r $MasterDirectory/run_calibrator_non_interactive.m $WorkingDirectory/$today/"$FileName"/run_calibrator_non_interactive.m
        #/usr/local/bin/matlab  -r "run_calibrator_non_interactive"
		#cp -r  $WorkingDirectory/$today/"$FileName"/*_calibration.mat  $WorkingDirectory/$today/"$FileName"/calibration.mat
		echo Now tracking: "$A"
		/usr/local/bin/matlab -nodisplay -nosplash -r "AutoTracking" &
	done

	sleep 5s # allow previous matlab to open before counting number of matlabs open
	# Check if matlab is running
	while [ $(pgrep -c "MATLAB") -gt 9 ]
	do
		sleep 2m
	done
	cd ..
done

## Clean up of matlab files
CurrentDirectory=$(pwd)
for X in */
do
	cd "$X"/
	rm AutoTracking.m
	# rm run_calibrator_non_interactive.m
	cd $CurrentDirectory
done

echo All Done.
echo $(date)
sleep infinity

