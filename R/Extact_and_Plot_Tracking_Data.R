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






library(data.table)
library(dtplyr)
library(tidyverse)

source("../R/extract_matlab_tracking_data.R")

message(paste0("Reading the Data..."))
alldata <- extract_all_data(tracking_dir_path = "~/Desktop/junk/aDN_dark_behaviour/good_data/2020_10_08_Courtship/Annika-2020_10_08_Courtship-2020_10_08_aDN_dark/",save_data = TRUE)

message(paste0("Wrangling the Data..."))
alldata_plotting <- alldata %>% 
    select(-Units, -Data_Source) %>% 
    spread("Feature","Value") %>% 
    select(Video_name, Frame, Fly_Id, Arena,
           major_axis_len,minor_axis_len,dist_to_other,ori,facing_angle,vel,pos_x,pos_y,axis_ratio) %>% 
    mutate(Fly_Id = as.factor(Fly_Id)) 

message(paste0("Plotting the Data..."))
diagnostic_plots(input_data_table = alldata_plotting,save_path = "~/Desktop/junk/aDN_dark_behaviour/good_data/2020_10_08_Courtship/Annika-2020_10_08_Courtship-2020_10_08_aDN_dark/")



