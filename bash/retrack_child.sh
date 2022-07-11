

printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"


printf "$(date)\n"
printf "Start tracking video ...\n\n\n\n"

printf "\n\n\n\n\n\n\n\n"
printf "####################################################\n"
printf "####################################################\n"
printf "####################################################\n\n"

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


FileName=$(basename -a --suffix=."${video_type}" "${video_name}")
best_calib_file="${OutputDirectory}/${FileName}/calibration.mat"

mkdir "${OutputDirectory}/${FileName}/Results"
mkdir "${OutputDirectory}/${FileName}/Logs"
mkdir -p "${OutputDirectory}/${FileName}/Backups/${FileName}_JAABA/perframe/"



matlab -nodisplay -nosplash -r "try; FileName='${FileName}'; OutputDirectory='${OutputDirectory}'; video_type='${video_type}'; track_start=${track_start}; FPS=${fps}; tracking_duration=${tracking_duration};best_calib_file='${best_calib_file}'; flies_per_arena=${flies_per_arena}; sex_ratio=${sex_ratio}; assay_type='${assay_type}'; addpath(genpath('${CodeDirectory}')); AutoTracking; catch err; disp(getReport(err,'extended')); end; quit"
matlab -nodisplay -nosplash -r "try; FileName='${FileName}'; OutputDirectory='${OutputDirectory}'; CodeDirectory='${CodeDirectory}'; addpath(genpath('${CodeDirectory}')); ApplyClassifiers; catch; end; quit"
matlab -nodisplay -nosplash -r "try; FileName='${FileName}'; OutputDirectory='${OutputDirectory}'; addpath(genpath('${CodeDirectory}')); script_reassign_identities; catch; end; quit"
Rscript ../R/Extact_and_Plot_Tracking_Data.R --args "${OutputDirectory}" "${FileName}" "${flies_per_arena}"
Rscript ../R/CalculateIndices_PlotEthograms.R --args "${OutputDirectory}" "${FileName}" "${fps}" "${sex_ratio}" "${optogenetics_light}"

mkdir -p "/mnt/synology/Tracked/${user}/${recording_date}-Recorded/${today}-Tracked"
\cp -Rav "${OutputDirectory}/${FileName}" "/mnt/synology/Tracked/${user}/${recording_date}-Recorded/${today}-Tracked/"
