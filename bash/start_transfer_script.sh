#!/bin/bash


# Author: Aaron M. Allen
# Date: 2021.12.14

# Description:
# This script starts the transfer script.



printf "$(date)\n\n"
today=$(date +%Y-%m-%d)

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

full_path="/mnt/local_data/videos/${user_name}/${vid_dir}"

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
done

# I don't think we need this if statement with the above while statement, but oh well... I'll leave it for now.
if [[ -d "${full_path}" ]]; then
    printf "\nWe will now start transfering your videos ...\n\n"
    bash transfer_script.sh "${user_name}" "${vid_dir}" "${settings_file}" 2>&1 | tee -a "/mnt/local_data/videos/transfer_logs/${today}_${user_name}_transfer.log"
else
    printf "\nStill can't find the directory ...\n"
    printf "Probably best to find Aaron or Annika ...\n\n"
    sleep infinity
fi

exit
