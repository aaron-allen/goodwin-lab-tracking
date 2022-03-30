#!/usr/bin/env Rscript


# Author: Aaron M Allen
# Date: 2021.12.03
#
#

# Description:

##


## Input Arguments:
##


## Output
##



## Dependencies:
##     'tidyverse' package
##         install.packages("tidyverse")

## This function was written using R 4.x.x, and tidyverse 1.x.x





## Example usage:

##






suppressMessages(library("data.table"))
suppressMessages(library("tidyverse"))
suppressMessages(library("zoo"))



OutputDirectory <- commandArgs(trailingOnly=T)[2]
FileName <- commandArgs(trailingOnly=T)[3]
FliesPerArena <- as.numeric(commandArgs(trailingOnly=T)[4])

message(paste0("OutputDirectory = ",OutputDirectory))
message(paste0("FileName = ",FileName))
message(paste0("FliesPerArena = ",FliesPerArena))



LogFile <-file(paste0(OutputDirectory,"/",FileName,"/Logs/ExtractDataR_Error.log"))
# tryCatch({


    source("../R/extract_matlab_tracking_data.R")
    source("../R/diagnostic_plots.R")

    message(paste0("Reading the Data..."))
    alldata <- extract_all_data(tracking_dir_path = paste0(OutputDirectory,"/",FileName,"/"),flies_per_arena=FliesPerArena,save_data = TRUE)

    message(paste0("Wrangling the Data..."))
    alldata_plotting <- alldata %>%
        select(-Units, -Data_Source) %>%
        spread("Feature","Value") %>%
        # select(Video_name, Frame, Fly_Id, Arena,
        #        major_axis_len,minor_axis_len,dist_to_other,ori,facing_angle,vel,pos_x,pos_y,axis_ratio) %>%
        mutate(Fly_Id = as.factor(Fly_Id))

    message(paste0("Plotting the Data..."))
    diagnostic_plots(input_data_table = alldata_plotting,flies_per_arena=FliesPerArena,save_path = paste0(OutputDirectory,"/",FileName,"/"))


#     },
#     error=function(e) {
#     writeLines(paste0("at index/step ", i, " occurred following error ", as.character(e) ), LogFile)
#     }
# )

sessionInfo()
