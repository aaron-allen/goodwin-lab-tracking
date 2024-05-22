#!/bin/bash

# Array of parent directories to search
grandparent_dir=(/mnt/synology/Tracked/Cato)


### Set-Up Variables ###
CodeDirectory=""

flies_per_arena=1
assay_type="optomotor"
optogenetics_light="true"








# If redoing someing on the Tracked Synology directory, then look for "-Recorded" directories in the 
# grandparent directory.
parent_dirs=("$grandparent_dir"/*-Recorded)

# Iterate over each parent directory
for parent_dir in "${grandparent_dir}"/*; do
    echo "Checking parent directory: $parent_dir"

    # Find all child directories matching the "YYYY-MM-DD-Tracked" format
    child_dirs=("$parent_dir"/*-Tracked)

    # Initialize variables to keep track of the most recent date and directory
    most_recent_date=""
    most_recent_dir=""

    # Iterate over each child directory
    for dir in "${child_dirs[@]}"; do
        # Extract the date part from the directory name
        dir_name=$(basename "$dir")
        date_part="${dir_name%-Tracked}"

        # Check if the date part is valid (matches YYYY-MM-DD format)
        if [[ $date_part =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            # Compare dates to find the most recent one
            if [[ -z $most_recent_date || $date_part > $most_recent_date ]]; then
                most_recent_date="$date_part"
                most_recent_dir="$dir"
            fi
        fi
    done

    # Output the most recent directory for the current parent directory
    if [[ -n $most_recent_dir ]]; then
        echo "Most recent directory in $parent_dir is: $most_recent_dir"


        OutputDirectory="${most_recent_dir}"
        for FileName in "${OutputDirectory}"/*; do
            printf "\tApplying optomotor classifiers for:  ${FileName}\n"
            
            # printf "\n\n\nApplying optomotor classifiers ...\n"
            # matlab -nodisplay -nosplash -r "try; \
            #                                 FileName='${FileName}'; \
            #                                 OutputDirectory='${OutputDirectory}'; \
            #                                 CodeDirectory='${CodeDirectory}'; \
            #                                 JABFileList='JABfilelist__optomotor.txt'; \
            #                                 addpath(genpath('${CodeDirectory}')); \
            #                                 ApplyClassifiers; \
            #                                 catch err; disp(getReport(err,'extended')); end; quit"


            # printf "\n\n\nExtracting tracking data and plotting diagnotic plots ...\n"
            # Rscript ../R/Extract_and_Plot_Tracking_Data.R \
            #     --args "${OutputDirectory}" \
            #         "${FileName}" \
            #         "${flies_per_arena}" \
            #         "${assay_type}" \
            #         "${optogenetics_light}"


        
        done
    else
        echo "No valid 'YYYY-MM-DD-Tracked' directories found in $parent_dir"
    fi
done
