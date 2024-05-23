#!/bin/bash

# Author: Aaron M. Allen
# Date: 2024.05.22
#
#
#
#
# This script does the following;
#   1. Searches for the most recent tracking data in the Tracked directory on the Synology
#   2. Applies the optomotor classifiers to the tracking data
#   3. Extracts the tracking data and plots diagnostic plots
#


############################################################################################################
# I removed my non conda, local install of R, so have to use one of the conda versions for now.
printf "Loading conda environment ...\n"
source /home/aaron/miniforge3/etc/profile.d/conda.sh
conda activate base
conda activate R4_cbrg
############################################################################################################




# Array of parent directories to search
grandparent_dir=(/mnt/synology/Tracked/Cato)


### Set-Up Variables ###
CodeDirectory="/home/aaron/Documents/GitHub/goodwin-lab-tracking/"

flies_per_arena=1
assay_type="optomotor"
optogenetics_light="true"







############################################################################################################
############################################################################################################
############################################################################################################


# If redoing someing on the Tracked Synology directory, then look for "-Recorded" directories in the 
# grandparent directory.
parent_dirs=("$grandparent_dir"/*-Recorded)

# Iterate over each parent directory
for parent_dir in "${grandparent_dir}"/*; do
    echo "Checking parent directory: $parent_dir"


    # Extract the date and time part from the directory name
    parent_dir_name=$(basename "$parent_dir")
    date_part="${parent_dir_name%-Recorded}"
    # Check if the date part is valid (matches YYYY-MM-DD format)
    if [[ $date_part =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # printf "\tValid date part\n"

        # Find all child directories matching the "YYYY-MM-DD-Tracked" format
        child_dirs=("$parent_dir"/*-Tracked)

        # Initialize variables to keep track of the most recent date and directory
        most_recent_datetime=""
        most_recent_dir=""

        # Iterate over each child directory
        for dir in "${child_dirs[@]}"; do
            # Extract the date and time part from the directory name
            dir_name=$(basename "$dir")
            datetime_part="${dir_name%-Tracked}"

            # Check if the date part is valid (matches YYYYMMDD-HHMMSS format)
            if [[ $datetime_part =~ ^[0-9]{8}-[0-9]{6}$ ]]; then
                # Compare dates to find the most recent one
                if [[ -z $most_recent_datetime || $datetime_part > $most_recent_datetime ]]; then
                    most_recent_datetime="$datetime_part"
                    most_recent_dir="$dir"
                fi
            fi
        done

        # Output the most recent directory for the current parent directory
        if [[ -n $most_recent_dir ]]; then
            printf "\tMost recent directory in $parent_dir is: $most_recent_dir\n"

            OutputDirectory="${most_recent_dir}"
            for FolderName in "${OutputDirectory}"/*; do
                FileName=$(basename "$FolderName")

                printf "\t\tApplying optomotor classifiers for:  ${FileName}\n"
                matlab -nodisplay -nosplash -r "try; \
                                                FileName='${FileName}'; \
                                                OutputDirectory='${OutputDirectory}'; \
                                                CodeDirectory='${CodeDirectory}'; \
                                                JABFileList='JABfilelist__optomotor.txt'; \
                                                addpath(genpath('${CodeDirectory}')); \
                                                ApplyClassifiers; \
                                                catch err; disp(getReport(err,'extended')); end; quit"


                printf "\n\n\nExtracting tracking data and plotting diagnotic plots ...\n"
                Rscript ../R/Extract_and_Plot_Tracking_Data.R \
                    --args "${OutputDirectory}" \
                        "${FileName}" \
                        "${flies_per_arena}" \
                        "${assay_type}" \
                        "${optogenetics_light}"
            done

        else
            echo "No valid 'YYYYMMDD-HHMMSS-Tracked' directories found in $parent_dir"
        fi
    fi
done
