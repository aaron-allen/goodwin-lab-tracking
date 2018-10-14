#!/bin/bash


# Aaron M Allen, 2018.10.12
#
# 

echo $(date)

# setting up a variable with todays date and making a folder for the modified courtship videos
MasterDirectory=$(pwd)
echo $MasterDirectory
today=$(date +%Y%m%d)
echo $today
today=${today}Tracked
echo  "$today"

read -p "Enter the directory you wish to be re-analysed:  " WorkingDirectory
#WorkingDirectory=/mnt/LocalData/WorkingDirectory

cd $WorkingDirectory/
pwd


# Track all video files with FlyTracker, and apply classifiers with JAABA
# -------------------------------------------------------------------------------------------------------------------------------------------------------------
echo REAPPLYING CLASSIFIERS
for Z in */
do
	cd $Z
	find . -name "scores*.mat" -type f -delete
	rm -rf Results/
	rm JAABA_logfile.log
	cp -r $MasterDirectory/ApplyClassifiers.m $WorkingDirectory/$Z/ApplyClassifiers.m
	cp -r $MasterDirectory/script_reassign_identities.m $WorkingDirectory/$Z/script_reassign_identities.m
	/usr/local/bin/matlab -nodisplay -nosplash -r "ApplyClassifiers"
	/usr/local/bin/matlab -nodisplay -nosplash -r "script_reassign_identities"
	cd $WorkingDirectory
done


# Generate Diagnostic Plots
# -------------------------------------------------------------------------------------------------------------------------------------------------------------
echo DIAGNOSTIC PLOT
cp -r $MasterDirectory/DiagnosticPlots.m $WorkingDirectory/DiagnosticPlots.m
/usr/local/bin/matlab -nodisplay -nosplash -r "DiagnosticPlots"
# Take all the individual pdfs of the Diagnotic plots and merge them into one pdf per video
for P in */
do
	cd $P/Results
	echo MERGING DIAGNOSTIC PLOTS INTO ONE PDF FOR $P
	pdftk *.pdf cat output ${P%%/*}_DiagnosticPlots.pdf
	rm *[0-9].pdf
	cd $WorkingDirectory
done

# Extracting Data for Each Plate
# -------------------------------------------------------------------------------------------------------------------------------------------------------------
echo EXTRACT DATA
cp -r $MasterDirectory/ExtractData.m $WorkingDirectory/ExtractData.m
/usr/local/bin/matlab -nodisplay -nosplash -r "ExtractData"

# Calculate indices with R
# -------------------------------------------------------------------------------------------------------------------------------------------------------------
echo CALCULATE INDICES
cp -r $MasterDirectory/CalculateIndices.R $WorkingDirectory/CalculateIndices.R
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
	rm ApplyClassifiers.m
	rm script_reassign_identities.m
	cd $WorkingDirectory
done


# Moving any error log files for the Diagnostic... and Extract...
echo "Now moving any error log files"
DiagnosticErrors=$(ls *DiagnosticPlot_errors.log 2> /dev/null | wc -l)
if [ "$DiagnosticErrors" != "0" ]
then
	echo Diagnostic Plot errors exist
	for L in *DiagnosticPlot_errors.log
	do
		LogFile=$L
		Directory=${LogFile%%DiagnosticPlot_errors.log}
	done
else
	echo No Diagnostic Plot errors
fi
ExtractError=$(ls *ExtractData_errors.log 2> /dev/null | wc -l)
if [ "$ExtractError" != "0" ]
then
	echo Extract Data errors exist
	for L in *ExtractDataAndPDFs_errors.log
	do
		LogFile=$L
		Directory=${LogFile%%ExtractData_errors.log}
		mv $LogFile $Directory/
	done
else
	echo No Extract Data Plot errors

fi

# # Move the resulting tracking results to the Synology in each users folder
# echo MOVING TRACKING RESULTS TO SYNOLOGY
# for D in */
# do
# 	Directory=$D
# 	User=${Directory%%-*}
# 	RecordingDate=${Directory#*-}
# 	VideoName=${RecordingDate#*-}
# 	RecordingDate=${RecordingDate%%-*}
# 	VideoName=${VideoName%%/}
# 	echo This is the Directory: $Directory
# 	echo This is the User: $User
# 	echo This is the Recording Date: $RecordingDate
# 	echo This is the Video Name: $VideoName
# 	mkdir -p /mnt/Synology/Tracked/$User/$RecordingDate
# 	cp -R $D /mnt/Synology/Tracked/$User/$RecordingDate/
# 	cd $WorkingDirectory
#  done


echo All Done.
echo $(date)
sleep infinity