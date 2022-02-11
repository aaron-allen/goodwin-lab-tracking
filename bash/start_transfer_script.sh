#!/bin/bash


# Author: Aaron M. Allen
# Date: 2021.12.14

# Description:
# This script starts the transfer script.



printf "$(date)\n\n"
today=$(date +%Y-%m-%d)
code_path="/home/aaron/Documents/GitHub/goodwin-lab-tracking"

printf "
Good [morning/afternoon/eveing],
This script will start transfering your videos to the Synology in order
to be tracked in our lab's pipline. Please enter the following information...\n\n
"

printf "Please enter your Username. This should be the\nsame spelling as seen in the videos folder.\n"
read -p 'Username: ' user_name
printf "\nPlease enter the name of the current recording\nfolder. This should be of the form <YYYY-MM-DD>.\n"
read -p 'Your recording folder: ' vid_dir
printf "\nPlease enter the name of your settings file. \nDon't forget the '.txt' file extenstion.\n"
read -p 'Settings File: ' settings_file

full_path="/mnt/data/videos/${user_name}/${vid_dir}"

# Double check that the user supplied settings file exists and is where it should be
while [[ ! -f "${full_path}/${settings_file}" ]]; do
    printf "\n\n\n\n\n\n"
    printf "\e[1;31mERROR! - Can't find the video path or settings file.\e[0m\n"
    printf "\t1. Double check your spelling.\n"
    printf "\t2. Make sure your recording folder is in your named folder.\n"
    printf "\t3. Only use the recording folder name, and not the full path.\n"
    printf "\t4. Make sure to include the '.txt' file extension when entering the settings file name.\n"
    printf "\nNow let's try entering the variables again.\n\n"
    read -p 'Username: ' user_name
    read -p 'Your recording folder: ' vid_dir
    read -p 'Settings File: ' settings_file
    full_path="/mnt/data/videos/${user_name}/${vid_dir}"
done

# Count the number of columns in the example_settings_file and the min and max columns in the user supplied file
target_col=$(awk -F ',' '{print NF}' "${code_path}/example_settings_file.txt" | sort -nu | tail -n 1)
min_col=$(awk -F ',' '{print NF}' "${full_path}/${settings_file}" | sort -nu | head -n 1)
max_col=$(awk -F ',' '{print NF}' "${full_path}/${settings_file}" | sort -nu | tail -n 1)

# Double check that the number of columns is constant in the user supplied settings file
if [[ ${min_col} != ${max_col} ]]; then
    printf "\nWARNING! your settings file has a different number of columns across the rows.\n\n"
    printf "\t1. Double check that there are no commas in your video names.\n"
    printf "\t2. Make sure there isn't a empty line at the START of the file.\n"
    printf "\t3. Make sure there isn't a empty line at the END of the file.\n"
    printf "\nDouble check the above is correct, then close this window and start again ...\n\n"
    sleep infinity
    return
fi

# Double check that the maximum number of columns in the settings file matches the example_settings_file
if [[ ${target_col} != ${max_col} ]]; then
    printf "\n\nWARNING! Your settings file has a different number of columns then expected.\n"
    printf "Open the user guide on GitHub and check that you are not missing anything.\n\n"
    printf "\t(Ctrl-Click the link below ...)\n"
    printf "\t(https://github.com/aaron-allen/goodwin-lab-tracking/blob/main/docs/goodwin_lab_user_guide.md#video-transfer)\n"
    printf "Double check the above is correct, then close this window and start again ...\n\n"
    sleep infinity
    return
fi

# Double check that every video name in the supplied setting file can be found in the supplied directory
while IFS=',' read -r user video_name video_type otherstuff; do
    if [[ ! -f "${full_path}/${video_name}" ]]; then
        printf '\n\nWARNING! At least one of the video names in your settings file does not exist.\n'
        printf "${video_name} is wrong, but others might be as well ...\n"
        printf "\t1. Make sure your spelling is correct. The video names are case-sensitive.\n"
        printf "\t2. Then close this window and start again ...\n\n"
        sleep infinity
        return
    fi
done < "${full_path}/${settings_file}"



# I don't think we need this if statement with the above while statement, but oh well... I'll leave it for now.
if [[ -d "${full_path}" ]] && [[ ${min_col} == ${max_col} ]] && [[ ${target_col} == ${max_col} ]]; then
    printf "\nWe will now start transfering your videos ...\n\n"
    bash ${code_path}/bash/transfer_script.sh "${user_name}" "${vid_dir}" "${settings_file}" 2>&1 | \
        tee -a "/mnt/data/_logs/transfer_logs/${today}_${user_name}_transfer.log"
else
    printf "\nStill can't find the directory ...\n"
    printf "\t(or there is something wrong with your settings file ... )\n"
    printf "Probably best to find Aaron or Annika ...\n\n"
    sleep infinity
    return
fi

exit
