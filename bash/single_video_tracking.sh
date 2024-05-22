#!/bin/bash


# Author: Aaron M. Allen
# Date: 2018.10.09
#     updated: 2021.12.02
#
#
#
#
# This script does the following;
#		1. Pulls videos off the Synology,
#		2. Tracks the videos with FlyTracker, in MatLab
#		3. Applies the 'classifiers' with JAABADetect in MatLab, for behaviours that have already been trained
#		4. Correct the Ids for flies in multi-arena video, in Matlab
#		5. Extracts the track.mat and feat.mat data and saves a .csv file, in R
#       6. Generates diagnostic plot to evaluate the efficacy of tracking, in R
#		7. Calculates indices and plots ethograms, in R
#
#
#
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------


# I removed my non conda, local install of R, so have to use one of the conda versions for now.
printf "Loading conda environment ...\n"
source /home/aaron/miniforge3/etc/profile.d/conda.sh
conda activate base
conda activate R4_cbrg





# Define function to print a bunch of space to make the log files easier for me to parse
function print_heading () {
    printf "\n\n\n\n\n\n\n\n"
    printf "####################################################\n"
    printf "####################################################\n"
    printf "####################################################\n\n"
}



print_heading

printf "$(date)\n"
printf "Start tracking video ...\n\n\n\n"


print_heading

# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# Inherit/import/accept variables:
today="${1}"
CodeDirectory="${2}"
ToBeTrackedDirectory="${3}"
WorkingDirectory="${4}"
InputDirectory="${5}"
OutputDirectory="${6}"
recording_date="${7}"
user="${8}"
video_name="${9}"
video_type="${10}"
fps="${11}"
track_start="${12}"
flies_per_arena="${13}"
sex_ratio="${14}"
number_of_arenas="${15}"
arena_shape="${16}"
assay_type="${17}"
optogenetics_light="${18}"
station="${19}"

# Force variables to be lowercase
video_type=$(printf "${video_type}" | tr '[:upper:]' '[:lower:]')
arena_shape=$(printf "${arena_shape}" | tr '[:upper:]' '[:lower:]')
assay_type=$(printf "${assay_type}" | tr '[:upper:]' '[:lower:]')
optogenetics_light=$(printf "${optogenetics_light}" | tr '[:upper:]' '[:lower:]')


tracking_duration=15    # in minutes

# --------------------------------------------------------------------------------------------------------------------------------------------------------------

if [[ -f "${InputDirectory}/${video_name}" ]]; then
    FileName=$(basename -a --suffix=."${video_type}" "${video_name}")
    mkdir "${OutputDirectory}/${FileName}"
    printf "Copying video files from Synology\n"
    cp "${InputDirectory}/${video_name}" "${OutputDirectory}/${FileName}/"


    # Before doing anything else, let's set up the directory structure in bash and not in the individual
    # other scripts.
    mkdir "${OutputDirectory}/${FileName}/Results"
    mkdir "${OutputDirectory}/${FileName}/Logs"
    mkdir -p "${OutputDirectory}/${FileName}/Backups/${FileName}_JAABA/perframe/"
else
    printf "${video_name} does not exist ...\n"
    printf "now exiting tracking ...\n"
    exit 1
fi

# --------------------------------------------------------------------------------------------------------------------------------------------------------------

printf "\n\n\n\n\n"
printf "today=${today}\n"
printf "CodeDirectory=${CodeDirectory}\n"
printf "ToBeTrackedDirectory=${ToBeTrackedDirectory}\n"
printf "WorkingDirectory=${WorkingDirectory}\n"
printf "InputDirectory=${InputDirectory}\n"
printf "OutputDirectory=${OutputDirectory}\n"
printf "recording_date=${recording_date}\n"
printf "user=${user}\n"
printf "video_name=${video_name}\n"
printf "video_type=${video_type}\n"
printf "fps=${fps}\n"
printf "track_start=${track_start}\n"
printf "flies_per_arena=${flies_per_arena}\n"
printf "sex_ratio=${sex_ratio}\n"
printf "number_of_arenas=${number_of_arenas}\n"
printf "arena_shape=${arena_shape}\n"
printf "assay_type=${assay_type}\n"
printf "optogenetics_light=${optogenetics_light}\n"
printf "tracking_duration=${tracking_duration}\n"
printf "FileName=${FileName}\n"

print_heading
# --------------------------------------------------------------------------------------------------------------------------------------------------------------




# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# For some reason the autochamber detection witht the optomotor videos always detects a chamber that is much larger
# than the actuall arena. While playing around it seems that when setting it to 2 arenas if finds the one correct
# arena and no others - no clue why this is the case. But for now we'll have the users enter "2 arenas" and I'll add
# a bit of code here that increments by one if they forget and left it set to "1 arena".
if [[ ${assay_type} == "optomotor" ]]; then
    if [[ ${number_of_arenas} == "1" ]]; then
        number_of_arenas=2
    fi
fi
# --------------------------------------------------------------------------------------------------------------------------------------------------------------





# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# add some code logic to sort out the optimal "template" calibration files
# based on the imported variables.

# The recalculating of the parent calibration file doesn't seem to adjust
# pixel dimension of the masks. Since Station A camera is a different
# resolution this was leading to errors with videos recorded on Station A,
# but attempting tracking with parent calibration files made for Stations
# B and C.
# if [[ ${station} == "a" ]]; then
#     station_mod="stata"
# else
#     station_mod="statbc"
# fi


# We are updating the Station A camera to match B and C, so I'm now going to use ffprobe
# to get the resolution of the video and use that to find the best calibration file.
video_resolution=$( ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "${OutputDirectory}/${FileName}/${video_name}" )

if [[ ${assay_type} == "courtship" ]] || [[ ${assay_type} == "optomotor" ]] ; then
    best_calib_file=$(ls ../MATLAB/parent_calib_files/ \
        | grep "${video_type}" \
        | grep "${flies_per_arena}fly" \
        | grep "${number_of_arenas}arena" \
        | grep "${arena_shape}" \
        | grep "${video_resolution}" \
        | grep "${assay_type}")
fi



## Don't think I need this anymore
# if [[ ${assay_type} == "oviposition" ]]; then
#     best_calib_file=$(ls ../MATLAB/parent_calib_files/ \
#         | grep "${video_type}" \
#         | grep "${number_of_arenas}arena" \
#         | grep "${arena_shape}" \
#         | grep "${assay_type}")
# fi


if [ -z "${best_calib_file}" ]; then
    printf "\n\n\n"
    printf "No matching calib file.\n"
    exit 1
else
    printf "\n\n\n"
    printf "There is a matching calib file.\n"
    printf "\tbest_calib_file=${best_calib_file}\n\n"
fi
# --------------------------------------------------------------------------------------------------------------------------------------------------------------







# --------------------------------------------------------------------------------------------------------------------------------------------------------------
print_heading
printf "\n\n\nNow tracking: ${video_name} ...\n"
matlab -nodisplay -nosplash -r "try; \
                                FileName='${FileName}'; \
                                OutputDirectory='${OutputDirectory}'; \
                                video_type='${video_type}'; \
                                track_start=${track_start}; \
                                FPS=${fps}; \
                                tracking_duration=${tracking_duration}; \
                                best_calib_file='${best_calib_file}'; \
                                flies_per_arena=${flies_per_arena}; \
                                sex_ratio=${sex_ratio}; \
                                assay_type='${assay_type}'; \
                                addpath(genpath('${CodeDirectory}')); \
                                AutoTracking; \
                                catch err; disp(getReport(err,'extended')); end; quit"

tracking_worked="${OutputDirectory}/${FileName}/${FileName}/${FileName}-track.mat"
if [[ -f "${tracking_worked}" ]]; then

    # Plot mask from calib file
    matlab -nodisplay -nosplash -r "try; \
                                    FileName='${FileName}'; \
                                    OutputDirectory='${OutputDirectory}'; \
                                    addpath(genpath('${CodeDirectory}')); \
                                    plot_mask; \
                                    catch err; disp(getReport(err,'extended')); end; quit"



    # Only run the optogenetic/indicator light detector if the video has and indicator LED
    if [[ ${optogenetics_light} == "true" ]]; then

        if [[ ${assay_type} == "optomotor" ]]; then
            print_heading
            printf "\n\n\nDetecting optomotor indicator light ...\n"


            # Run nvidia-smi (and capture its output) to check to see if the GPU is available
            output=$(nvidia-smi)
            exit_code=$?
            if [ $exit_code -eq 0 ]; then
                printf "GPU driver detected.\n"
                useGPU="true"
            fi

            # Cut the top left corner of the video to a m x m pixel square
            # to speed up the optomotor indicator light detection
            number_of_pixels=800
            if [[ ${useGPU} == "true" ]]; then
                ffmpeg \
                    -hide_banner \
                    -nostdin \
                    -i "${OutputDirectory}/${FileName}/${video_name}" \
                    -vf "crop=${number_of_pixels}:${number_of_pixels}:0:0" \
                    -c:v h264_nvenc \
                    "${OutputDirectory}/${FileName}/${video_name:: -4}--indicator_led.mp4"
            else
                ffmpeg \
                    -hide_banner \
                    -nostdin \
                    -i "${OutputDirectory}/${FileName}/${video_name}" \
                    -vf "crop=${number_of_pixels}:${number_of_pixels}:0:0" \
                    -c:v copy \
                    "${OutputDirectory}/${FileName}/${video_name:: -4}--indicator_led.mp4"
            fi

            matlab -nodisplay -nosplash -r "try; \
                                            FileName='${FileName}'; \
                                            OutputDirectory='${OutputDirectory}'; \
                                            NumberOfPixels='${number_of_pixels}'; \
                                            useGPU = ${useGPU}; \
                                            addpath(genpath('${CodeDirectory}')); \
                                            alt_detect_led_indicator_light; \
                                            catch err; disp(getReport(err,'extended')); end; quit"

            mv "${video_name:: -4}--indicator_led.mp4" "${OutputDirectory}/${FileName}/Backups/"
        fi

        # Run old indicator light script for courtship videos
        if [[ ${assay_type} == "courtship" ]]; then
            print_heading
            printf "\n\n\nDetecting optogenetic light ...\n"
            matlab -nodisplay -nosplash -r "try; \
                                            FileName='${FileName}'; \
                                            OutputDirectory='${OutputDirectory}'; \
                                            videoname='${video_name}'; \
                                            FPS=${fps}; \
                                            tracking_duration=${tracking_duration}; \
                                            addpath(genpath('${CodeDirectory}')); \
                                            script_detect_optogenetic_light; \
                                            catch err; disp(getReport(err,'extended')); end; quit"
        fi

    fi

    # Apply Optomotor specific classifiers
    if [[ ${assay_type} == "optomotor" ]]; then
        print_heading
        printf "\n\n\nApplying optomotor classifiers ...\n"
        matlab -nodisplay -nosplash -r "try; \
                                        FileName='${FileName}'; \
                                        OutputDirectory='${OutputDirectory}'; \
                                        CodeDirectory='${CodeDirectory}'; \
                                        JABFileList='JABfilelist__optomotor.txt'; \
                                        addpath(genpath('${CodeDirectory}')); \
                                        ApplyClassifiers; \
                                        catch err; disp(getReport(err,'extended')); end; quit"
    fi


    # Only run ApplyClassifiers if there are 2 flies per arena, as that is what the jab files
    # were trained with.
    if [[ ${flies_per_arena} == 2 ]]; then
        print_heading
        printf "\n\n\nDetecting singleton flies ...\n"
        # Before attempting to run ApplyClassifiers, check for any rogue singletons
        matlab -nodisplay -nosplash -r "try; \
                                        FileName='${FileName}'; \
                                        OutputDirectory='${OutputDirectory}'; \
                                        FliesPerArena="${flies_per_arena}"; \
                                        addpath(genpath('${CodeDirectory}')); \
                                        DeleteSingletonFlies; \
                                        catch err; disp(getReport(err,'extended')); end; quit"

        print_heading
        printf "\n\n\nApplying classifiers ...\n"
        # if [[ ! -f "${CodeDirectory}/MATLAB/JABsFromFlyTracker/JABfilelist.txt" ]]; then
        #     ls -d -1 ${CodeDirectory}/MATLAB/JABsFromFlyTracker/*.jab > ${CodeDirectory}/MATLAB/JABsFromFlyTracker/JABfilelist.txt
        # fi
        matlab -nodisplay -nosplash -r "try; \
                                        FileName='${FileName}'; \
                                        OutputDirectory='${OutputDirectory}'; \
                                        CodeDirectory='${CodeDirectory}'; \
                                        JABFileList='JABfilelist.txt'; \
                                        addpath(genpath('${CodeDirectory}')); \
                                        ApplyClassifiers; \
                                        catch err; disp(getReport(err,'extended')); end; quit"
    fi

    # Since the auto chamber detection is not working for the optomotor videos, but there is actually only one
    # chamber, we'll skip the re-assigning of identities for the optomotor videos.
    if [[ ${number_of_arenas} > 1 ]] && [[ ${assay_type} != "optomotor" ]] ; then
        # Re-assign the identities of the flies such that fly 1 and 2 are in arena 1, fly 3 and 4
        # are in arena 2, etc...
        print_heading
        printf "\n\n\nRe-assigning identities ...\n"
        matlab -nodisplay -nosplash -r "try; \
                                        FileName='${FileName}'; \
                                        OutputDirectory='${OutputDirectory}'; \
                                        addpath(genpath('${CodeDirectory}')); \
                                        script_reassign_identities; \
                                        catch err; disp(getReport(err,'extended')); end; quit"
    fi


    # if [[ ${flies_per_arena} == 2 ]] && [[ ${number_of_arenas} == 20 ]]; then
        print_heading
        printf "\n\n\nExtracting tracking data and plotting diagnotic plots ...\n"
        Rscript ../R/Extract_and_Plot_Tracking_Data.R --args "${OutputDirectory}" "${FileName}" "${flies_per_arena}" "${assay_type}" "${optogenetics_light}"
    # fi



    # Only calculate indices if there are 2 flies per arena
    extracted_data="${OutputDirectory}/${FileName}/Results/${FileName}_ALLDATA_R.csv.gz"
    if [[ ${flies_per_arena} == 2 ]] && [[ -f "${extracted_data}" ]]; then
        print_heading
        printf "\n\n\nCalculating indices and plotting ethograms ...\n"
        Rscript ../R/CalculateIndices_PlotEthograms.R --args "${OutputDirectory}" "${FileName}" "${fps}" "${sex_ratio}" "${optogenetics_light}"
    fi



    # --------------------------------------------------------------------------------------------------------------------------------------------------------------
    # Move the resulting tracking results to the Synology in each users folder
    print_heading
    printf "\n\n\nMoving tracking results to the Synology\n"
    current_machine=$(hostname)
    if [[ "${current_machine}" == "goodwintracking" ]]; then
        remote_path="/mnt/Synology"
    elif [[ "${current_machine}" == "mentok" ]]; then
        remote_path="/mnt/synology"
    fi

    # printf "not moving right now ...\n"
    mkdir -p "${remote_path}/Tracked/${user}/${recording_date}-Recorded/${today}-Tracked"
    cp -Rav "${OutputDirectory}/${FileName}" "${remote_path}/Tracked/${user}/${recording_date}-Recorded/${today}-Tracked/"
    # --------------------------------------------------------------------------------------------------------------------------------------------------------------
else
    printf "\n\n\n\n\n\n\n\n"
    printf "Tracking failed ...\n"
    failed_tracking_list="/mnt/data/Tracking/_logs/failed_tracking/${today}-failed_tracking.log"
    touch "${failed_tracking_list}"
    printf "${recording_date},${user},${video_name},mp4,${fps},0,${flies_per_arena},${sex_ratio},${number_of_arenas},${arena_shape},${assay_type},${optogenetics_light},${station}\n" \
        >> "${failed_tracking_list}"
fi



print_heading


printf "\n\n\nDone tracking video.\n"
printf "$(date)\n\n\n"
