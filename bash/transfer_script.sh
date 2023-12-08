#!/bin/bash


# Author: Aaron M. Allen
# Date: 2021.12.14

# Description:
# This script transfers the users videos to the Synologys for tracking.



printf "$(date)\n\n"
today=$(date +%Y-%m-%d)

user_name="${1}"
vid_dir="${2}"
settings_file="${3}"

printf "Username = ${user_name}\n"
printf "Recording directory = ${vid_dir}\n"
printf "Settings file = ${settings_file}\n\n\n"

user_dir="/mnt/data/videos/${user_name}"
full_path="/mnt/data/videos/${user_name}/${vid_dir}"

tobetracked_vid_dir="/mnt/synology/ToBeTracked/VideosFromStations/videos"
tobetracked_list_file="/mnt/synology/ToBeTracked/VideosFromStations/list_of_videos.csv"

tracking_duration=15    # in minutes
ff_t_stop=$(( ${tracking_duration} * 60 ))   # convert to seconds for ffmpeg


# Define the transfer function
function transfer_function () {
    video="${1}"
    in_dir="${2}"
    to_dir="${3}"
    mkdir -p "${to_dir}/"
    printf "\tCopying ${video} ...\n"
    cp "${in_dir}/${video}" "${to_dir}/"
    local_size=$(wc -c "${in_dir}/${video}" | awk '{print $1}')
    remote_size=$(wc -c "${to_dir}/${video}" | awk '{print $1}')
    printf "\tLocal file size = ${local_size}\n"
    printf "\tRemote file size = ${remote_size}\n"
    if [[ ${local_size} == ${remote_size} ]]; then
        printf "\tLocal and remote file sizes are equal. Copying was successfull.\n"
    else
        printf "\tLocal and remote file sizes are NOT equal. Something has gone wrong ...\n"
    fi
    printf "\n\n"
}




# Check if the supplied local user directory exists
if [[ -d "${full_path}" ]]; then
    # first, copy a version to the archive directory
    # second, copy a version to the users directory on GoodwinGroup
    if [[ -f "/mnt/synology/Archive/mount_test.txt" ]] && \
        [[ -f "/mnt/synology/GoodwinGroup/mount_test.txt" ]]; then

        printf "Backup Synologys are mounted.\n"
        printf "\tWe will now start copying the original videos ...\n\n"
        shopt -s nullglob  # expands 'empty' match of '*.avi' to null so we don't try anything with a non-existant literal '*.avi' file
        for full_path_file in "${full_path}"/*.{avi,mp4,mkv,fmf,ufmf} ; do
            file=$(basename "${full_path_file}")
            if [[ ! -f "${full_path_file}" ]]; then
                printf "\tCan't find the video "${file}", so skipping it ...\n"
                continue
            fi
            printf "Copying ${file} to ...\n"
            printf "  Archive:\n"
            transfer_function "${file}" "${full_path}" "/mnt/synology/Archive/FromStations/${user_name}/${vid_dir}"
            printf "  GoodwinGroup:\n"
            transfer_function "${file}" "${full_path}" "/mnt/synology/GoodwinGroup/${user_name}/BehaviourVideos/${vid_dir}"
        done
    else
        printf "The Synology is not mounted.\n...\n\t... go find Aaron ...\n\n"
        sleep infinity
    fi

    # third and last, transfer videos in settings files to ToBeTracked directory
    if [[ -f "/mnt/synology/ToBeTracked/mount_test.txt" ]]; then
        printf "ToBeTracked Synology is mounted.\n"
        printf "\tWe will now start transcoding and copying the videos in settings file ...\n\n"

        ## Remove leading and tailing spaces around the commas
        awk -F '[[:blank:]]*,[[:blank:]]*' -v OFS=, \
                '{gsub(/^[[:blank:]]+|[[:blank:]]+$/, ""); $1=$1} 1' \
                "${full_path}/${settings_file}" > "${full_path}/${settings_file}.bak"

        while IFS=',' read -r user \
    							video_name \
    							video_type \
    							fps \
    							start_time \
    							flies_per_arena \
    							sex_ratio \
    							number_of_arenas \
    							arena_shape \
    							assay_type \
    							optogenetics_light \
    							station;
        do
            # Force variables to be lowercase
            video_type=$(printf "${video_type}" | tr '[:upper:]' '[:lower:]')
            arena_shape=$(printf "${arena_shape}" | tr '[:upper:]' '[:lower:]')
            assay_type=$(printf "${assay_type}" | tr '[:upper:]' '[:lower:]')
            optogenetics_light=$(printf "${optogenetics_light}" | tr '[:upper:]' '[:lower:]')
            station=$(printf "${station}" | tr '[:upper:]' '[:lower:]')


            printf "video is : ${video_name}\n"
            printf "video type is : ${video_type}\n"
            # Check if video type has a period
            if [[ "${video_type}" == *.* ]]; then
                video_type="${video_type:1}"
            fi
            # Check if file has extension
            if [[ "${video_name}" != *.* ]]; then
                video_name="${video_name}.${video_type}"
            fi

            printf "video is now : ${video_name}\n"
            printf "video type is now : ${video_type}\n"
            if [[ "${video_type}" == "mkv" ]]; then
                # --------------------------------------------------------------------------------------------------------------------------------------------------------------
                ### need to convert Strand-Camera mkv files to constant frame rate videos
                printf "\n\n\n################################################\n"

                # Get the codec of the video in case it's not h264
                my_codec=$( ffprobe "${full_path}/${video_name}" 2>&1 | grep "Video: " | cut -d ',' -f1 | awk '{ print $4 }' )


                printf "ffmpeg starting\n\n"
                ffmpeg \
                    -hide_banner \
                    -nostdin \
                    -hwaccel cuvid \
                    -c:v h264_cuvid \
                    -hwaccel_output_format cuda \
                    -extra_hw_frames 4 \
                    -ss "${start_time}.000" \
                    -i "${full_path}/${video_name}" \
                    -t "${ff_t_stop}.000" \
                    -filter:v fps="${fps}" \
                    -c:v h264_nvenc \
                    -tune ull \
                    -rc cbr \
                    -preset p7 \
                    -multipass 1 \
                    -y \
                    "${full_path}/${video_name:: -4}.mp4"
                printf "\n\nffmpeg done\n"
                printf "################################################\n\n\n"
                # --------------------------------------------------------------------------------------------------------------------------------------------------------------

                # Check that destination directory and video list file exits
                if [[ ! -d "${tobetracked_vid_dir}" ]]; then
                    mkdir -p "${tobetracked_vid_dir}"
                fi
                if [[ ! -f "${tobetracked_list_file}" ]]; then
                    touch "${tobetracked_list_file}"
                fi

                # Transfer video and append info to list file
                printf "Copying ${video_name:: -4}.mp4 to ...\n"
                printf "  ToBeTracked:\n"
                transfer_function "${video_name:: -4}.mp4" ${full_path} "${tobetracked_vid_dir}"
                printf "${vid_dir},${user},${video_name:: -4}.mp4,mp4,${fps},0,${flies_per_arena},${sex_ratio},${number_of_arenas},${arena_shape},${assay_type},${optogenetics_light},${station}\n" \
                    >> "${tobetracked_list_file}"
                rm "${full_path}/${video_name:: -4}.mp4"


                # If optomotor assay, then also transfer the batch run directory to the GoodwinGroup Synology.
                if [[ "${assay_type}" == "optomotor" ]]; then
                    # Check if the batch run directory exists
                    opto_path="/mnt/data/videos/${user_name}/Optomotor/Batch_Runs"
                    if [[ -d "${opto_path}/${video_name:: -4}" ]]; then
                        # Check that destination directory exists
                        destination_dir="/mnt/synology/GoodwinGroup/${user_name}/BehaviourVideos/Optomotor/Batch_Runs/${video_name:: -4}"
                        if [[ ! -d "${destination_dir}/" ]]; then
                            mkdir -p "${destination_dir}/"
                        fi
                        # Transfer batch run directory
                        printf "Copying ${video_name:: -4} to ...\n"
                        printf "    GoodwinGroup:\n"
                        cp -r "${opto_path}/${video_name:: -4}/" "${destination_dir}/"
                    else
                        printf "Can't find the batch run directory for ${video_name:: -4}.\n"
                    fi
                fi

            fi
        done < "${full_path}/${settings_file}.bak"
        rm "${full_path}/${settings_file}.bak"
    else
        printf "The Synology is not mounted.\n...\n\t... go find Aaron ...\n\n"
        sleep infinity
    fi
else
    printf "\nStill can't find your local recording folder ...\n"
    printf "Probably best to find Aaron ...\n\n"
    sleep infinity
fi
