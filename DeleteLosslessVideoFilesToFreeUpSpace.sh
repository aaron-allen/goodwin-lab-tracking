#!/bin/bash

# Aaron M. Allen, 2019.02.26
#
# This script is used to delete old lossless video files in the event that the Synology gets too full.
# If the Synology disk usage ('CAPACITY') is more than the set limit ('CAPACITY_LIMIT'), then
# the script starts to delete lossless avi files. The script finds all '.avi' files in the
# /lossless/ directory and ranks by modification date (oldest to newest). The script then checks to 
# see if it is now below the capacity limit; if it is, then the sript stops, otherwise it continues to the next video.
#
# 

today=$(date)
echo -e "\n\n\n\n$today"

LossDIR=/mnt/Synology/Archive/lossless
CAPACITY_LIMIT=80
echo "Lossless DIR = $LossDIR"
echo "CAPACITY_LIMIT = $CAPACITY_LIMIT"
echo $(pwd)
cd $LossDIR
echo $(pwd)
CAPACITY=$(df -k . | awk '{gsub("%",""); capacity=$5}; END {print capacity}')
echo "CAPACITY = $CAPACITY"
if [ $CAPACITY -gt $CAPACITY_LIMIT ]
then
    cd $LossDIR
    find . -type f -name '*.avi' -printf "%T@ %Tc %p\n" | sort -n | cut -f 2- -d '/' > ListOfAVIFilesByDate.txt
    while read line
    do
        #echo "removing /mnt/Synology/Archive/lossless/${line}"
        rm -f "/mnt/Synology/Archive/lossless/${line}"
        #echo "removing /mnt/Synology/Archive/#recycle/lossless/${line}"
        rm -f "/mnt/Synology/Archive/#recycle/lossless/${line}"
        cd ~/.local/share/Trash/files/
        rm -rf "*.avi"
        cd $LossDIR
        sleep 30
        echo "Deleted ${line} in /mnt/Synology/Archive/lossless/"
        CAPACITY=$(df -k . | awk '{gsub("%",""); capacity=$5}; END {print capacity}')
        echo "Current capacity is $CAPACITY"
        if [ $CAPACITY -le $CAPACITY_LIMIT ]
        then
           # we're below the limit, so stop deleting
           echo All done.
           exit
        fi
    done < ListOfAVIFilesByDate.txt
fi

exit
