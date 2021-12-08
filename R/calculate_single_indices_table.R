#!/usr/bin/env Rscript


# Author: Aaron M Allen
# Date: 2020.04.08
#     updated: 2021.12.02
#
#

# Description:

## This function calculates summary indices for tracking data out of our pipeline
## based on the JAABA annotations. It assumes the normal directory structure that
## is generated with the tracking pipeline. It reads in the '*ALLDATA.csv' files
## from the 'Results' directories for each video. It outputs a '*_Indices.csv'
## file.


## Input Arguments:
##   input_dir: string, the full file path to the directory to be analysed (of the form "path/to/my_video/Results/")
##   inc_cop: boolean, whether to include the copulatory frames in the indices (default FALSE)
##   cop_wind: integer, the length of time in seconds that the JAABA copulation score must be at least 50% to count as copulation (default 50)
##   court_init: boolean, whether to impose a threshold for courtship initiation (default FALSE)
##   court_wind: integer, the length of time in seconds that the fly must be exibiting at least 50% courtship behaviour (defualt 6)
##   max_court: boolean, whether to impose a maximum length of time to over which to calculate the indices (defualt FALSE)
##   max_court_dur: integer, the maximum length of time in seconds over which to calculate the indices (defualt 600 seconds, only used it 'max_court' is set to TRUE)
##   frame_rate: integer, the number of frames per second of the video that was tracked (defualt 25 frames per second)
##   return_obj: boolean, whether or not to return the tibble of indices


## Output variables in '*_Indices.csv' file:
##   FileName: name of the video file
##   ArenaNumber: the arena number for the fly
##   FlyId: the id number for the fly
##   CI: the courtship index in percent
##   CIwF: the courtship index including facing in percent
##   approaching: the approaching index in percent
##   contact: the contact index in percent
##   circling: the circling index in percent
##   facing: the facing index in percent
##   turning: the turning index in percent
##   wing: the wing index in percent
##   denominator: the duration of time used to normalize the indices in seconds



## Dependencies:
##     'tidyverse' package
##         install.packages("tidyverse")
##     'data.table' package
##         install.packages("data.table")
##     'zoo' package
##         install.packages("zoo")

## This function was written using R 3.5.3, tidyverse 1.2.1, and data.table 1.12.2
## This function has been tested using R 4.x.x, tidyverse 1.x.x, and data.table 1.x.x





## Example usage:

## This example should recapitulate what is automatically generated from the pipeline

# calculate_single_indices_table(input_dir = "path/to/my_video/Results/",
#                         court_init = TRUE,
#                         max_court = TRUE
#                         )


## This example doesn't include copulation frames, doesn't have a 10min max courtship time, and doesn't have the initiation 'trigger'

# calculate_single_indices_table(input_dir = "path/to/my_video/Results/")




calculate_single_indices_table <- function(input_dir,
                                        inc_cop = FALSE,
                                        cop_wind = 50,
                                        court_init = FALSE,
                                        court_wind = 6,
                                        max_court = FALSE,
                                        max_court_dur = 600,
                                        frame_rate = 25,
                                        return_obj = FALSE){

    library("data.table")
    library("dtplyr")
    library("tidyverse")
    library("zoo")

    setwd(input_dir)


    message(paste0("Loading ",list.files(pattern=glob2rx('*ALLDATA.csv'))))
    raw_data <- fread(list.files(pattern=glob2rx('*ALLDATA.csv')),sep = ",", showProgress = FALSE)
    message("Calculating Indices")
    indices <- raw_data %>%
        select(FileName,
             Arena,
             Id,
             Frame,
             Approaching,
             Contact,
             Copulation,
             Encircling,
             Facing,
             Turning,
             WingGesture) %>%
        drop_na() %>%
        group_by(Id) %>%
        mutate(
        Multitasking = (Approaching + Encircling + Contact + Turning + WingGesture),
        MultitaskingWithFacing = (Approaching + Encircling + Facing + Contact + Turning + WingGesture),
        Courtship = if_else(Multitasking>=1, 1, 0),
        CourtshipWithFacing = if_else(MultitaskingWithFacing>=1, 1, 0),
        MultitaskingWithCopulation = (Approaching + Encircling + Contact + Turning + WingGesture + Copulation),
        MultitaskingWithCopulationWithFacing = (Approaching + Encircling + Facing + Contact + Turning + WingGesture + Copulation),
        CourtshipAndCopulation = if_else(MultitaskingWithCopulation>=1, 1, 0),
        CourtshipAndCopulationWthFacing = ifelse(MultitaskingWithCopulationWithFacing>=1, 1, 0),
        SmoothedCourtship = if_else((rollmean(Courtship, court_wind*frame_rate, fill = c(0,0,0), align = c("left")))>0.5, 1, 0),
        SmoothedCopulation = if_else((rollmean(Copulation, cop_wind*frame_rate, fill = c(0,0,0), align = c("center")))>0.5, 1, 0)
        ) %>%
        do(
        if(inc_cop)
          .
        else
          slice(., 1:if_else(sum(SmoothedCopulation)==0, n(), which.max(SmoothedCopulation)))
        ) %>%
        do(
        if(court_init)
          slice(., which.max(SmoothedCourtship):n())
        else
          .
        ) %>%
        do(
        if(max_court)
          slice(., 1:min(n(),max_court_dur*frame_rate))
        else
          .
        ) %>%
        summarise(FileName = unique(FileName),
                ArenaNumber = unique(Arena),
                FlyId = unique(Id),
                CI = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Courtship)),
                CIwF = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(CourtshipWithFacing)),
                approaching = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Approaching)),
                contact = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Contact)),
                circling = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Encircling)),
                facing = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Facing)),
                turning = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Turning)),
                wing = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(WingGesture)),
                denominator = length(Frame)/frame_rate
        ) %>%
        select(-Id)
    message("Saving Indices Table")
    SaveName <- paste0(unique(raw_data$FileName),'_Indices.csv')
    fwrite(indices, SaveName)
    if (return_obj) {
        return(indices)
    }
}
