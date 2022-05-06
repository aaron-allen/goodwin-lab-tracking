#!/usr/bin/env Rscript


# Author: Aaron M Allen
# Date: 2020.04.08
#     updated: 2021.12.02
#
#

# Description:

## This function calculates summary indices for tracking data out of our pipeline
## based on the JAABA annotations. It assumes the normal directory structure that
## is generated with the tracking pipeline. It reads in the '*ALLDATA_R.csv.gz' files
## from the 'Results' directories for each video. It outputs a '*_Indices.csv'
## file.


## Input Arguments:
##   input: string, the full file path to the directory to be analysed (of the form "path/to/my_video/Results/")
##   inc_cop: boolean, whether to include the copulatory frames in the indices (default FALSE)
##   cop_wind: integer, the length of time in seconds that the JAABA copulation score must be at least 50% to count as copulation (default 50)
##   court_init: boolean, whether to impose a threshold for courtship initiation (default FALSE)
##   court_wind: integer, the length of time in seconds that the fly must be exibiting at least 50% courtship behaviour (defualt 6)
##   max_court: boolean, whether to impose a maximum length of time to over which to calculate the indices (defualt FALSE)
##   max_court_dur: integer, the maximum length of time in seconds over which to calculate the indices (defualt 600 seconds, only used it 'max_court' is set to TRUE)
##   frame_rate: integer, the number of frames per second of the video that was tracked (defualt 25 frames per second)


##   opto_light: ...
##   lights_on: ...


##   return_obj: boolean, whether or not to return the tibble of indices
##   save_data: boolean, whether or not to write data to disk
##   save_path: string, full or relative file path to write data to disk (only used if save_data == TRUE)


## Output variables in '*_Indices.csv' file:
##   Video_name: name of the video file
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

# calculate_single_indices_table(input = "path/to/my_video/Results/",
#                         court_init = TRUE,
#                         max_court = TRUE
#                         )


## This example doesn't include copulation frames, doesn't have a 10min max courtship time, and doesn't have the initiation 'trigger'

# calculate_single_indices_table(input = "path/to/my_video/Results/")




calculate_single_indices_table <- function(input,
                                        inc_cop = FALSE,
                                        cop_wind = 50,
                                        court_init = FALSE,
                                        court_wind = 6,
                                        max_court = FALSE,
                                        max_court_dur = 600,
                                        frame_rate = 25,
                                        predict_sex = FALSE,
                                        prop_male = 0.5,
                                        opto_light = FALSE,
                                        lights_on = FALSE,
                                        return_obj = FALSE,
                                        save_data = TRUE,
                                        save_path = NULL){

    suppressMessages(library("data.table"))
    suppressMessages(library("tidyverse"))
    suppressMessages(library("zoo"))

    if ( is.character(input) ) {
        if ( .Platform$OS.type == "windows" ) {
            input <- input %>% stringr::str_replace_all(pattern = "\\\\", "/")
        }
        if ( !stringr::str_detect(input, "/$") ) {
            input <- paste0(input, "/")
        }
        my_data_file <- list.files(input) %>% str_subset("ALLDATA_R.csv.gz")
        message(paste0("Loading ",my_data_file))
        raw_data <- fread(paste0(input,my_data_file),sep = ",", showProgress = FALSE)
    }
    if ( is.data.frame(input) | is_tibble(input) ) {
        raw_data <- input
    }

    # if ( opto_light ) {
    #     # read in opto-lights matlab file and make a perframe arena, flyid, and lights-on tibble
    # }


    message("    Calculating Indices")
    indices <- raw_data %>%
        select(Video_name,
             Arena,
             Fly_Id,
             Frame,
             Approaching,
             Contact,
             Copulation,
             Encircling,
             Facing,
             Turning,
             WingGesture) %>%
        drop_na() %>%
        group_by(Fly_Id) %>%
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
            SmoothedCopulation = if_else((rollmean(Copulation, cop_wind*frame_rate, fill = c(0,0,0), align = c("center")))>0.5, 1, 0),
            CourtshipInitiation = which.max(SmoothedCourtship)/frame_rate
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
        # do(
        # if(opto_light)
        #   # filter
        # else
        #   .
        # ) %>%
        summarise(FileName = unique(Video_name),
                ArenaNumber = unique(Arena),
                FlyId = unique(Fly_Id),
                CI = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Courtship)),
                CIwF = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(CourtshipWithFacing)),
                approaching = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Approaching)),
                contact = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Contact)),
                circling = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Encircling)),
                facing = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Facing)),
                turning = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(Turning)),
                wing = if_else(court_init & sum(SmoothedCourtship) == 0, 0, 100*mean(WingGesture)),
                time_to_init = unique(CourtshipInitiation),
                denominator = length(Frame)/frame_rate
        ) %>%
        select(-Fly_Id)

    # Predict sex of flies using there size and the user supplied proportion of males
    # join predicted sex tibble with indices tibble
    # Should the predict sex part be it's own function? probably ...
    if (predict_sex) {
        predicted_sex <- predict_sex_by_size(tracking_data = raw_data,
                                             proportion_male = prop_male,
                                             frame_rate = frame_rate) %>%
            select(ArenaNumber, FlyId, pred_sex)
        indices <- left_join(indices, predicted_sex, by = c("ArenaNumber" = "ArenaNumber", "FlyId" = "FlyId") )
    }



    if (save_data) {
        message("    Saving Indices Table")
        SaveName <- paste0(save_path, unique(raw_data$Video_name),'_Indices.csv')
        fwrite(indices, SaveName)
    }
    if (return_obj) {
        return(indices)
    }
}





predict_sex_by_size <- function(tracking_data,
                                skip_first_frames = 250,
                                remove_copulation = TRUE,
                                proportion_male = 0.5,
                                min_dist = 2,
                                dist_wind = 50,
                                frame_rate = 25) {

    # Predict sex of flies using there size and the user supplied proportion of males

    # skip the first n (?) frames when calculating the area
    # skip the copulation frames when calculating the area
    # rank the sizes
    # compute a tibble with fly_id and predicted_sex

    # Returns a tibble of fly ids and predicted sex. Includes the following columns:
    #   "FileName": the name of the video file
    #   "ArenaNumber": ... arena number ...
    #   "FlyId": the id of the fly
    #   "min_frame": first frame for which area was considered
    #   "max_frame": last frame for which area was considered
    #   "avg_area": the mean area from the first to last frame considered
    #   "pred_sex": predicted sex

    n_flies <- length(unique(tracking_data$Fly_Id))
    n_males <- proportion_male * n_flies
    n_females <- n_flies - n_males

    predicted_sex <- tracking_data %>%
        select(Video_name,
               Arena,
               Fly_Id,
               Frame,
               major_axis_len,
               minor_axis_len,
               dist_to_other) %>%
        drop_na() %>%
        group_by(Fly_Id) %>%
        mutate(
            smoothed_distiance = rollmean(dist_to_other, dist_wind*frame_rate, fill = NA, align = c("center")),
            is_close = if_else(smoothed_distiance < min_dist, 1, 0)
        ) %>%
        do(
            if(skip_first_frames > 0)
                slice(., skip_first_frames:n())
        ) %>%
        do(
            if(remove_copulation)
                slice(., 1:if_else(sum(is_close, na.rm = TRUE)==0, n(), which.max(is_close)))
        ) %>%
        mutate(
            fly_area = pi * major_axis_len * minor_axis_len
        ) %>%
        summarise(FileName = unique(Video_name),
                  ArenaNumber = unique(Arena),
                  FlyId = unique(Fly_Id),
                  min_frame = min(Frame),
                  max_frame = max(Frame),
                  avg_area = mean(fly_area)
        )  %>%
        select(-Fly_Id) %>%
        mutate(pred_sex = "?")

    if (proportion_male == 0) {
        predicted_sex <- predicted_sex %>% mutate(pred_sex = "F")
    }
    if (proportion_male == 1) {
        predicted_sex <- predicted_sex %>% mutate(pred_sex = "M")
    }
    if (proportion_male > 0 & proportion_male < 1) {
        predicted_sex <- predicted_sex %>%
            group_by(ArenaNumber) %>%
            mutate(pred_sex = cut(avg_area,
                                  c(0, quantile(avg_area, proportion_male), max(avg_area)),
                                  c('M', 'F')
            )
            )
    }
    return(predicted_sex)
}
