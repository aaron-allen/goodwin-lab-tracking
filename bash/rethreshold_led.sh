#!/bin/bash

# This script is used to run the MATLAB code to detect the LED indicator light in the videos

number_of_pixels=800
useGPU="true"

CodeDirectory="/home/aaron/Documents/GitHub/goodwin-lab-tracking"
cd "${CodeDirectory}/bash"






synologyDirectory="/mnt/synology/Tracked/Cato"

# Use find command to search for sub-subdirectories matching the pattern
find "$synologyDirectory" -mindepth 2 -maxdepth 3 -type d -name "20240515-182455-Tracked" |
while IFS= read -r OutputDirectory; do
    # Process each matching "Tracked" directory
    printf "\n\n"
    printf "Processing Tracked directory:\t\t$OutputDirectory\n\n"
        

    # Iterate over the subfolders within the "Tracked" directory
    for dir in "$OutputDirectory"/*/; do
        # Process each subfolder

        FileName=$(basename "$dir")
        # Check if folder_name equals "_tracking_logs"
        if [ "$FileName" = "_tracking_logs" ]; then
            echo "Skipping folder $FileName"
            continue  # Skip to the next iteration of the loop
        fi
        printf "\tVideo Name is:\t\t\t$FileName\n"
        printf "\tOutput directory is:\t\t$OutputDirectory\n"
        
        matlab -nodisplay -nosplash -r "try; \
                                        FileName='${FileName}'; \
                                        OutputDirectory='${OutputDirectory}'; \
                                        NumberOfPixels='${number_of_pixels}'; \
                                        useGPU = ${useGPU}; \
                                        addpath(genpath('${CodeDirectory}')); \
                                        alt_detect_led_indicator_light; \
                                        catch err; disp(getReport(err,'extended')); end; quit" \
            &
        sleep 2s  
        while [[ $(pgrep -fc "MATLAB") -gt 5 ]]
        do
            sleep 10s
        done
        

            # Your processing code here for each subfolder
    done
done







# OutputDirectory="/mnt/data/Tracking/20240515-182455-Tracked"

# for dir in $OutputDirectory/*/
# do

#     FileName=$(basename "$dir")
#     # Check if folder_name equals "_tracking_logs"
#     if [ "$FileName" = "_tracking_logs" ]; then
#         echo "Skipping folder $FileName"
#         continue  # Skip to the next iteration of the loop
#     fi
#     # OutputDirectory=$dir
#     printf "Video Name is:\t\t\t$FileName\n"
#     printf "Output directory is:\t\t$OutputDirectory\n"
#     printf "\n\n"
    
#     # matlab -nodisplay -nosplash -r "try; \
#     #                                 FileName='${FileName}'; \
#     #                                 OutputDirectory='${OutputDirectory}'; \
#     #                                 NumberOfPixels='${number_of_pixels}'; \
#     #                                 useGPU = ${useGPU}; \
#     #                                 addpath(genpath('${CodeDirectory}')); \
#     #                                 alt_detect_led_indicator_light; \
#     #                                 catch err; disp(getReport(err,'extended')); end; quit" \
#     #     &
#     # sleep 2s  
#     # while [[ $(pgrep -fc "MATLAB") -gt 10 ]]
#     # do
#     #     sleep 10s
#     # done

# done
