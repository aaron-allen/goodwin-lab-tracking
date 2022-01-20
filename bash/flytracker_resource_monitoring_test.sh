#!/bin/bash


printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"


printf "$(date)\n"
printf "Start tracking video ...\n\n\n\n"




function system_usage_logger {
    printf "Timestamp\tCPU_percent\tLoad_average_15min\tRAM_MB\n" >> "${curr_log_file}"
    while [ $(pgrep -fc "_video_tracking") -gt 0 ]
    do
        timestamp=$(date +%s)
        curr_cpu=$(top -bn 2 -d 0.01 | grep '^%Cpu' | tail -n 1 | awk '{print $2+$4+$6}')
        curr_load=$(uptime | awk '{print $12}') #| cut -d "," -f 1
        curr_ram=$(free -m | grep '^Mem:' | awk '{ print $3 }')
        printf "${timestamp}\t${curr_cpu}\t${curr_load}\t${curr_ram}\n" >> "${curr_log_file}"
        sleep 1m
    done
}

printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"


# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# Inherit/import/accept variables:
today=$(date +%Y%m%d-%H%M%S)
CodeDirectory="/home/aaron/Documents/GitHub"
ToBeTrackedDirectory="not needed"
WorkingDirectory="not needed"
InputDirectory="/mnt/localdata/behaviour/..."
OutputDirectory="/mnt/localdata/behaviour/..."
user="aaron"
video_name="mp4_test_20arena_2fly.mp4"
video_type="mp4"
fps="25"
track_start="30"
flies_per_arena="2"
sex_ratio="0.5"
number_of_arenas="20"
arena_shape="circle"
assay_type="courtship"
optogenetics_light="false"


printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"

mkdir -p "${OutputDirectory}/_tracking_logs"





curr_log_file="system_usage--14core_28chunk.log"
touch "${curr_log_file}"

today=$(date +%Y%m%d-%H%M%S)
printf "\tNow tracking ${user}'s video ${video_name}\n"
bash single_video_tracking.sh "${today}" \
                              "${CodeDirectory}" \
                              "${ToBeTrackedDirectory}" \
                              "${WorkingDirectory}" \
                              "${InputDirectory}" \
                              "${OutputDirectory}" \
                              "${user}" \
                              "${video_name}" \
                              "${video_type}" \
                              "${fps}" \
                              "${track_start}" \
                              "${flies_per_arena}" \
                              "${sex_ratio}" \
                              "${number_of_arenas}" \
                              "${arena_shape}" \
                              "${assay_type}" \
                              "${optogenetics_light}" >> \
    "${OutputDirectory}/_tracking_logs/${today}_${user_name}_${video_name}_tracking.log" 2>&1 \
    &

sleep 5s

system_usage_logger

while [ $(pgrep -fc "_video_tracking") -gt 0 ]
do
    sleep 10m
done


sed -i 's/options.num_cores   = maxNumCompThreads;/options.num_cores   = 10;/g' /home/aaron/Documents/GitHub/goodwin-lab-tracking/MATLAB/AutoTracking.m





printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"







curr_log_file="system_usage--10core_20chunk.log"
touch "${curr_log_file}"

today=$(date +%Y%m%d-%H%M%S)
printf "\tNow tracking ${user}'s video ${video_name}\n"
bash single_video_tracking.sh "${today}" \
                              "${CodeDirectory}" \
                              "${ToBeTrackedDirectory}" \
                              "${WorkingDirectory}" \
                              "${InputDirectory}" \
                              "${OutputDirectory}" \
                              "${user}" \
                              "${video_name}" \
                              "${video_type}" \
                              "${fps}" \
                              "${track_start}" \
                              "${flies_per_arena}" \
                              "${sex_ratio}" \
                              "${number_of_arenas}" \
                              "${arena_shape}" \
                              "${assay_type}" \
                              "${optogenetics_light}" >> \
    "${OutputDirectory}/_tracking_logs/${today}_${user_name}_${video_name}_tracking.log" 2>&1 \
    &

sleep 5s

system_usage_logger

while [ $(pgrep -fc "_video_tracking") -gt 0 ]
do
    sleep 10m
done


sed -i 's/options.num_cores   = 10;/options.num_cores   = 8;/g' /home/aaron/Documents/GitHub/goodwin-lab-tracking/MATLAB/AutoTracking.m








printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"







curr_log_file="system_usage--8core_16chunk.log"
touch "${curr_log_file}"

today=$(date +%Y%m%d-%H%M%S)
printf "\tNow tracking ${user}'s video ${video_name}\n"
bash single_video_tracking.sh "${today}" \
                              "${CodeDirectory}" \
                              "${ToBeTrackedDirectory}" \
                              "${WorkingDirectory}" \
                              "${InputDirectory}" \
                              "${OutputDirectory}" \
                              "${user}" \
                              "${video_name}" \
                              "${video_type}" \
                              "${fps}" \
                              "${track_start}" \
                              "${flies_per_arena}" \
                              "${sex_ratio}" \
                              "${number_of_arenas}" \
                              "${arena_shape}" \
                              "${assay_type}" \
                              "${optogenetics_light}" >> \
    "${OutputDirectory}/_tracking_logs/${today}_${user_name}_${video_name}_tracking.log" 2>&1 \
    &

sleep 5s

system_usage_logger

while [ $(pgrep -fc "_video_tracking") -gt 0 ]
do
    sleep 10m
done


sed -i 's/options.num_cores   = 8;/options.num_cores   = 6;/g' /home/aaron/Documents/GitHub/goodwin-lab-tracking/MATLAB/AutoTracking.m








printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"







curr_log_file="system_usage--6core_12chunk.log"
touch "${curr_log_file}"

today=$(date +%Y%m%d-%H%M%S)
printf "\tNow tracking ${user}'s video ${video_name}\n"
bash single_video_tracking.sh "${today}" \
                              "${CodeDirectory}" \
                              "${ToBeTrackedDirectory}" \
                              "${WorkingDirectory}" \
                              "${InputDirectory}" \
                              "${OutputDirectory}" \
                              "${user}" \
                              "${video_name}" \
                              "${video_type}" \
                              "${fps}" \
                              "${track_start}" \
                              "${flies_per_arena}" \
                              "${sex_ratio}" \
                              "${number_of_arenas}" \
                              "${arena_shape}" \
                              "${assay_type}" \
                              "${optogenetics_light}" >> \
    "${OutputDirectory}/_tracking_logs/${today}_${user_name}_${video_name}_tracking.log" 2>&1 \
    &

sleep 5s

system_usage_logger

while [ $(pgrep -fc "_video_tracking") -gt 0 ]
do
    sleep 10m
done


sed -i 's/options.num_cores   = 6;/options.num_cores   = 4;/g' /home/aaron/Documents/GitHub/goodwin-lab-tracking/MATLAB/AutoTracking.m








printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"







curr_log_file="system_usage--4core_8chunk.log"
touch "${curr_log_file}"

today=$(date +%Y%m%d-%H%M%S)
printf "\tNow tracking ${user}'s video ${video_name}\n"
bash single_video_tracking.sh "${today}" \
                              "${CodeDirectory}" \
                              "${ToBeTrackedDirectory}" \
                              "${WorkingDirectory}" \
                              "${InputDirectory}" \
                              "${OutputDirectory}" \
                              "${user}" \
                              "${video_name}" \
                              "${video_type}" \
                              "${fps}" \
                              "${track_start}" \
                              "${flies_per_arena}" \
                              "${sex_ratio}" \
                              "${number_of_arenas}" \
                              "${arena_shape}" \
                              "${assay_type}" \
                              "${optogenetics_light}" >> \
    "${OutputDirectory}/_tracking_logs/${today}_${user_name}_${video_name}_tracking.log" 2>&1 \
    &

sleep 5s

system_usage_logger

while [ $(pgrep -fc "_video_tracking") -gt 0 ]
do
    sleep 10m
done


sed -i 's/options.num_cores   = 4;/options.num_cores   = 2;/g' /home/aaron/Documents/GitHub/goodwin-lab-tracking/MATLAB/AutoTracking.m








printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"







curr_log_file="system_usage--2core_4chunk.log"
touch "${curr_log_file}"

today=$(date +%Y%m%d-%H%M%S)
printf "\tNow tracking ${user}'s video ${video_name}\n"
bash single_video_tracking.sh "${today}" \
                              "${CodeDirectory}" \
                              "${ToBeTrackedDirectory}" \
                              "${WorkingDirectory}" \
                              "${InputDirectory}" \
                              "${OutputDirectory}" \
                              "${user}" \
                              "${video_name}" \
                              "${video_type}" \
                              "${fps}" \
                              "${track_start}" \
                              "${flies_per_arena}" \
                              "${sex_ratio}" \
                              "${number_of_arenas}" \
                              "${arena_shape}" \
                              "${assay_type}" \
                              "${optogenetics_light}" >> \
    "${OutputDirectory}/_tracking_logs/${today}_${user_name}_${video_name}_tracking.log" 2>&1 \
    &

sleep 5s

system_usage_logger

while [ $(pgrep -fc "_video_tracking") -gt 0 ]
do
    sleep 10m
done


sed -i 's/options.num_cores   = 2;/options.num_cores   = 1;/g' /home/aaron/Documents/GitHub/goodwin-lab-tracking/MATLAB/AutoTracking.m








printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"







curr_log_file="system_usage--1core_2chunk.log"
touch "${curr_log_file}"

today=$(date +%Y%m%d-%H%M%S)
printf "\tNow tracking ${user}'s video ${video_name}\n"
bash single_video_tracking.sh "${today}" \
                              "${CodeDirectory}" \
                              "${ToBeTrackedDirectory}" \
                              "${WorkingDirectory}" \
                              "${InputDirectory}" \
                              "${OutputDirectory}" \
                              "${user}" \
                              "${video_name}" \
                              "${video_type}" \
                              "${fps}" \
                              "${track_start}" \
                              "${flies_per_arena}" \
                              "${sex_ratio}" \
                              "${number_of_arenas}" \
                              "${arena_shape}" \
                              "${assay_type}" \
                              "${optogenetics_light}" >> \
    "${OutputDirectory}/_tracking_logs/${today}_${user_name}_${video_name}_tracking.log" 2>&1 \
    &

sleep 5s

system_usage_logger

while [ $(pgrep -fc "_video_tracking") -gt 0 ]
do
    sleep 10m
done


sed -i 's/options.num_chunks   = options.num_cores*2;/options.num_chunks   = 1;/g' /home/aaron/Documents/GitHub/goodwin-lab-tracking/MATLAB/AutoTracking.m







printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"







curr_log_file="system_usage--1core_1chunk.log"
touch "${curr_log_file}"

today=$(date +%Y%m%d-%H%M%S)
printf "\tNow tracking ${user}'s video ${video_name}\n"
bash single_video_tracking.sh "${today}" \
                              "${CodeDirectory}" \
                              "${ToBeTrackedDirectory}" \
                              "${WorkingDirectory}" \
                              "${InputDirectory}" \
                              "${OutputDirectory}" \
                              "${user}" \
                              "${video_name}" \
                              "${video_type}" \
                              "${fps}" \
                              "${track_start}" \
                              "${flies_per_arena}" \
                              "${sex_ratio}" \
                              "${number_of_arenas}" \
                              "${arena_shape}" \
                              "${assay_type}" \
                              "${optogenetics_light}" >> \
    "${OutputDirectory}/_tracking_logs/${today}_${user_name}_${video_name}_tracking.log" 2>&1 \
    &

sleep 5s

system_usage_logger

while [ $(pgrep -fc "_video_tracking") -gt 0 ]
do
    sleep 10m
done

# reset AutoTracking
sed -i 's/options.num_cores   = 2;/options.num_cores    = maxNumCompThreads;/g' /home/aaron/Documents/GitHub/goodwin-lab-tracking/MATLAB/AutoTracking.m
sed -i 's/options.num_chunks   = 1;/options.num_chunks   = options.num_cores*2;/g' /home/aaron/Documents/GitHub/goodwin-lab-tracking/MATLAB/AutoTracking.m





printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"


printf "$(date)\n"
printf "All done.\n\n"
