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
read -p "Is the courtship plate upside down? (y/n)  " PlateOrientation
read -p "Do you want the whole plate tracked as one video? (y/n) " WholePate 

read -p "At what time point are the dividers retracted (in seconds): " StartTime
read -p "How long do you want to track for (in seconds):  " Duration 

echo "This is the input directory: $InputDirectory"
echo "This is the ouptut directory: $OutputDirectory"


pwd
cd $OutputDirectory/
pwd
#sleep 5

mkdir $today/
mkdir $today/ufmf/
#mkdir $today/IndividualVideos/
#mkdir $today/Temp/

#sleep 5
#cp -r $MasterDirectory/ufmfCompressionParams.txt $today/ufmfCompressionParams.txt

cd $today/








## -----------------------------------------------------------------------------------------------------
## Cropping a short segment of the length videos.
## ------------------------------------------------------------------------------------------
## -------------------------------------------------------------------------------------------------------------
echo TEMPORAL CROP SUB-ROUTINE
#sleep 5
#mkdir Cut/
for A in "$InputDirectory/*.ufmf"
do
	echo Copying files from Synology
	cp -r $A ufmf/
#	for B in Temp/*.avi; do
#		ffmpeg -i $B -c copy -ss $StartTime -t $Duration Cut/~nB_10min.avi
#	done
#	rm Temp/*.avi
done




sleep 2

if $WholePate == "n"
# line 91 gives the following response, not sure if it is an error exactly, but: './20180711_CompleteTrackingSrcipt.sh: 91: ./20180711_CompleteTrackingSrcipt.sh: y: not found'
then
	if $PlateOrientation == "y" 
	then
		echo SPATIAL CROP SUB-ROUTINE		
		#UpsideDown
		echo Cutting upside DOWN video.
		for C in Cut/*.avi
		do
			mkdir IndividualVideos/~nC_IndividualVideos/
			echo Cutting out individual arenas from: $C
			ffmpeg -i $C -vf crop=480:480:195:50 IndividualVideos/~nC_IndividualVideos/~nC_vid01.avi
			ffmpeg -i $C -vf crop=480:480:630:50 IndividualVideos/~nC_IndividualVideos/~nC_vid02.avi
			ffmpeg -i $C -vf crop=480:480:1060:50 IndividualVideos/~nC_IndividualVideos/~nC_vid03.avi
			ffmpeg -i $C -vf crop=480:480:1500:50 IndividualVideos/~nC_IndividualVideos/~nC_vid04.avi
			ffmpeg -i $C -vf crop=480:480:1915:50 IndividualVideos/~nC_IndividualVideos/~nC_vid05.avi
			ffmpeg -i $C -vf crop=480:480:1:350 IndividualVideos/~nC_IndividualVideos/~nC_vid06.avi
			ffmpeg -i $C -vf crop=480:480:415:350 IndividualVideos/~nC_IndividualVideos/~nC_vid07.avi
			ffmpeg -i $C -vf crop=480:480:850:350 IndividualVideos/~nC_IndividualVideos/~nC_vid08.avi
			ffmpeg -i $C -vf crop=480:480:1285:350 IndividualVideos/~nC_IndividualVideos/~nC_vid09.avi
			ffmpeg -i $C -vf crop=480:480:1710:350 IndividualVideos/~nC_IndividualVideos/~nC_vid10.avi
			ffmpeg -i $C -vf crop=480:480:195:775 IndividualVideos/~nC_IndividualVideos/~nC_vid11.avi
			ffmpeg -i $C -vf crop=480:480:630:775 IndividualVideos/~nC_IndividualVideos/~nC_vid12.avi
			ffmpeg -i $C -vf crop=480:480:1060:775 IndividualVideos/~nC_IndividualVideos/~nC_vid13.avi
			ffmpeg -i $C -vf crop=480:480:1500:775 IndividualVideos/~nC_IndividualVideos/~nC_vid14.avi
			ffmpeg -i $C -vf crop=480:480:1915:775 IndividualVideos/~nC_IndividualVideos/~nC_vid15.avi
			ffmpeg -i $C -vf crop=480:480:1:1065 IndividualVideos/~nC_IndividualVideos/~nC_vid16.avi
			ffmpeg -i $C -vf crop=480:480:415:1065 IndividualVideos/~nC_IndividualVideos/~nC_vid17.avi
			ffmpeg -i $C -vf crop=480:480:850:1065 IndividualVideos/~nC_IndividualVideos/~nC_vid18.avi
			ffmpeg -i $C -vf crop=480:480:1285:1065 IndividualVideos/~nC_IndividualVideos/~nC_vid19.avi
			ffmpeg -i $C -vf crop=480:480:1710:1065 IndividualVideos/~nC_IndividualVideos/~nC_vid20.avi
			echo Converting to ufmf
#  need to figure out how to change to ufmf on linux ... or just track .avi files
#			for D in IndividualVideos/~nC_IndividualVideos/*.avi
#			do
#				mkdir ufmf/~nC/Videos/~nD/
#				any2ufmf $D ufmf/~nC/Videos/~nD/~nD.ufmf ufmfCompressionParams.txt
#			done
		done
#		rmdir /Q /S IndividualVideos/
#		rmdir /Q /S Temp/
#		rmdir /Q /S Cut/
#		rmdir /Q /S Crop/
	else
		#UpsideUp
		echo Cutting upside UP video.	
		for C in Cut/*.avi
		do
			mkdir IndividualVideos/~nC_IndividualVideos/
			echo Cutting out individual arenas from: $C
			ffmpeg -i $C -vf crop=480:480:1:50 IndividualVideos/~nC_IndividualVideos/~nC_vid01.avi
			ffmpeg -i $C -vf crop=480:480:415:50 IndividualVideos/~nC_IndividualVideos/~nC_vid02.avi
			ffmpeg -i $C -vf crop=480:480:850:50 IndividualVideos/~nC_IndividualVideos/~nC_vid03.avi
			ffmpeg -i $C -vf crop=480:480:1285:50 IndividualVideos/~nC_IndividualVideos/~nC_vid04.avi
			ffmpeg -i $C -vf crop=480:480:1710:50 IndividualVideos/~nC_IndividualVideos/~nC_vid05.avi
			ffmpeg -i $C -vf crop=480:480:195:350 IndividualVideos/~nC_IndividualVideos/~nC_vid06.avi
			ffmpeg -i $C -vf crop=480:480:630:350 IndividualVideos/~nC_IndividualVideos/~nC_vid07.avi
			ffmpeg -i $C -vf crop=480:480:1060:350 IndividualVideos/~nC_IndividualVideos/~nC_vid08.avi
			ffmpeg -i $C -vf crop=480:480:1500:350 IndividualVideos/~nC_IndividualVideos/~nC_vid09.avi
			ffmpeg -i $C -vf crop=480:480:1915:350 IndividualVideos/~nC_IndividualVideos/~nC_vid10.avi
			ffmpeg -i $C -vf crop=480:480:1:775 IndividualVideos/~nC_IndividualVideos/~nC_vid11.avi
			ffmpeg -i $C -vf crop=480:480:415:775 IndividualVideos/~nC_IndividualVideos/~nC_vid12.avi
			ffmpeg -i $C -vf crop=480:480:850:775 IndividualVideos/~nC_IndividualVideos/~nC_vid13.avi
			ffmpeg -i $C -vf crop=480:480:1285:775 IndividualVideos/~nC_IndividualVideos/~nC_vid14.avi
			ffmpeg -i $C -vf crop=480:480:1710:775 IndividualVideos/~nC_IndividualVideos/~nC_vid15.avi
			ffmpeg -i $C -vf crop=480:480:195:1065 IndividualVideos/~nC_IndividualVideos/~nC_vid16.avi
			ffmpeg -i $C -vf crop=480:480:630:1065 IndividualVideos/~nC_IndividualVideos/~nC_vid17.avi
			ffmpeg -i $C -vf crop=480:480:1060:1065 IndividualVideos/~nC_IndividualVideos/~nC_vid18.avi
			ffmpeg -i $C -vf crop=480:480:1500:1065 IndividualVideos/~nC_IndividualVideos/~nC_vid19.avi
			ffmpeg -i $C -vf crop=480:480:1915:1065 IndividualVideos/~nC_IndividualVideos/~nC_vid20.avi
			echo Converting to ufmf
#  need to figure out how to change to ufmf on linux ... or just track .avi files
#			for D in IndividualVideos/~nC_IndividualVideos/*.avi; do
#				mkdir ufmf/~nC/Videos/~nD/
#				any2ufmf D ufmf/~nC/Videos/~nD/~nD.ufmf ufmfCompressionParams.txt
#			done
		done
#		rmdir /Q /S IndividualVideos/
#		rmdir /Q /S Temp/
#		rmdir /Q /S Cut/
#		rmdir /Q /S Crop/
	fi
fi






# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Track all video files with FlyTracker
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
cd ufmf/


for Z in *.ufmf
do
	FileName=$(basename -a --suffix=.ufmf "$Z")
	#FileName="${FileName%.*}"
	mkdir $FileName
	cp $OutputDirectory/$today/ufmf/$Z $OutputDirectory/$today/ufmf/$FileName/$Z
	cd $FileName
	for A in *.ufmf
	do
		echo Copying Matlab files to ufmf folder
		cp -r $MasterDirectory/TrackDiagnosticClassifiers.m $OutputDirectory/$today/ufmf/${Z%.*}/TrackDiagnosticClassifiers.m
		cp -r $MasterDirectory/WholePlateCalibration.mat $OutputDirectory/$today/ufmf/${Z%.*}/calibration.mat
		echo Now tracking: $A
		xterm $MasterDirectory/TrackDiagnosticClassifiers.sh &
	done
	
	# Check if matlab is running
	# -x flag only match processes whose name (or command line if -f is specified) exactly match the pattern. 
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

while pgrep -x "xterm" > /dev/null
do
	echo "Just waiting for the tracking to finish."
	sleep 5m
done



## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Extracting Data for Each Plate
## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#for X in *.ufmf
#do
#	echo Copy ExtractDataAndPDFs.m into: $X
#	cp -r $MasterDirectory/ExtractDataAndPDFs.m $OutputDirectory/$today/ufmf/${Z%.*}/
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

