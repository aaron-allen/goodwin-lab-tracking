#!/bin/bash

# Aaron M. Allen, 2018.11.05
#
# This script is used to delete old raw video files in the event that the Synology get too full.
# If the Synology disk usage ('CAPACITY') is more than the set limit ('CAPACITY_LIMIT'), then
# the script starts to delete raw avi files. The script finds all 'settings.txt' files in the
# /lossless/ directory and ranks by modification date (oldest to newest). By using the 'settings.txt'
# files, we'll only be deleting videos that have been losslessly compressed and converted to uFMF. The
# video names are read in from the 'settings.txt' file, and the corresponding name in the /raw/
# directory is deleted. The script then checks to see if it is now below the capacity limit; if it is,
# then the sript stops, otherwise it continues to the next video.
#
# 


DIR=/mnt/Synology/Archive/lossless
CAPACITY_LIMIT=80
echo "DIR = $DIR"
echo "CAPACITY_LIMIT = $CAPACITY_LIMIT"
echo $(pwd)
cd $DIR
echo $(pwd)
CAPACITY=$(df -k . | awk '{gsub("%",""); capacity=$5}; END {print capacity}')
if [ $CAPACITY -gt $CAPACITY_LIMIT ]
then
    find . -type f -name 'settings.txt' -printf "%T@ %Tc %p\n" | sort -n | cut -f 2- -d '/' > ListOfSettingsListFilesByDate.txt
    while read line
    do
        SettingsFile=${line#* }
        echo -e "\n\nSettingsFile = $SettingsFile"
        MovieDir="${SettingsFile::-13}"
        dos2unix $SettingsFile
        while read -r line
        do
            Movie="${line%%,*}"
            echo "Movie = $Movie"
            # rm -f "/mnt/Synology/Archive/raw/$MovieDir/$Movie"
            echo "Deleted $Movie in /mnt/Synology/Archive/raw/$MovieDir"
        done < $SettingsFile
        # mv "/mnt/Synology/Archive/lossless/$SettingsFile" "/mnt/Synology/Archive/lossless/$MovieDir/settingsBackup.txt"
        CAPACITY=$(df -k . | awk '{gsub("%",""); capacity=$5}; END {print capacity}')
        echo "Current capacity is $CAPACITY"
        if [ $CAPACITY -le $CAPACITY_LIMIT ]
        then
           # we're below the limit, so stop deleting
           echo All done.
           exit
        fi
    done < ListOfSettingsListFilesByDate.txt
fi
exit
