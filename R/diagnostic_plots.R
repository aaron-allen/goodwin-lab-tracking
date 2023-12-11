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






diagnostic_plots <- function(input_data_table,flies_per_arena,assay_type,indicator_light,save_path,slim_by=NULL) {

    suppressMessages(library("data.table"))
    suppressMessages(library("tidyverse"))
    suppressMessages(library("cowplot"))
    suppressMessages(library("zoo"))

    # Values of +/-2pi are due to the fly's angle crossing the "zero" line and
    # don't represent 'true' large changes in angle. So I've reset anything
    # larger than 5 to 0, making the plot more informative to find the times
    # when the fly's angle changes by pi, which would be an orientation
    # miss-annotation.
    input_data_table <- input_data_table %>%
        group_by(Arena, Fly_Id) %>%
        mutate(change_in_ori = c(0,diff(ori))) %>%
        mutate(change_in_ori = if_else(abs(change_in_ori) > 5, 0, change_in_ori))

    # The velocity measure is very noisy, so I'm smoothing it out taking the rolling
    # mean over a 200 frame window.
    input_data_table <- input_data_table %>%
        group_by(Arena, Fly_Id) %>%
        mutate(smoothed_vel = zoo::rollmean(x = vel, k = 200, fill = c(0,0,0), align = c("center")))


    if (is.numeric(slim_by)) {
        message(paste0("Slimming the data.\n    Only plotting every ", slim_by, "th frame."))
        input_data_table <- input_data_table %>%
            filter(Frame %% slim_by == 1)
    }

    arenas <- unique(input_data_table$Arena)
    vid_name <- unique(input_data_table$Video_name)
    save_name <- paste0(save_path,"Results/",vid_name,"_Diagnostic_Plots_R.pdf")

    message(paste0("Plotting Diagnostic Plots for: ", vid_name))

    pdf(save_name,width=7.75,height=11.25,paper='a4')
    for (i in arenas){

        message(paste0("    Plotting arena ", i))
        single_arena_data <-  input_data_table %>%
            filter(Arena == i)

        if (assay_type == "optomotor" & indicator_light) {
            indicator_light_frames <- read_csv( paste0(OutputDirectory,"/",FileName,"/",FileName,"--led_state.csv"), col_names = "LED_state") %>% rowid_to_column(var = "Frame")
            single_arena_data <- left_join(x = single_arena_data, y = indicator_light_frames, by = "Frame")
        }

        p_list <- list()
        p_list[["area"]] <- single_arena_data %>%
            ggplot(aes(x = Frame, y = major_axis_len*minor_axis_len*pi/14.85/14.85, colour = Fly_Id)) +
            geom_line(size = 0.5) +
            ylab("Area (px^2)") +
            labs(title = paste0(unique(single_arena_data$Video_name),":   Arena_",i)) +
            # ylim(0,20) +  # since I'm using pixel measurements and not mm, I need to remove this bound as 5 arena videos are off the chart
            xlim(0,max(single_arena_data$Frame))
        if (flies_per_arena == 2) {
            p_list[["dist_to_other"]] <- single_arena_data %>%
                ggplot(aes(x = Frame, y = dist_to_other, colour = Fly_Id)) +
                geom_line(size = 0.5) +
                ylab("Distance to Other (mm)") +
                ylim(0,20) +
                xlim(0,max(single_arena_data$Frame))
        } else {
            p_list[["dist_to_wall"]] <- single_arena_data %>%
                ggplot(aes(x = Frame, y = dist_to_wall, colour = Fly_Id)) +
                geom_line(size = 0.5) +
                ylab("Distance to Wall (mm)") +
                ylim(0,max(20, max(single_arena_data$dist_to_wall))) +
                xlim(0,max(single_arena_data$Frame))
        }
        p_list[["change_in_ori"]] <- single_arena_data %>%
            group_by(Fly_Id) %>%
            # mutate(change_in_ori = c(0,diff(ori))) %>%
            # mutate(change_in_ori = if_else(abs(change_in_ori) > 5, 0, change_in_ori)) %>%
            ggplot(aes(x = Frame, y = change_in_ori, colour = Fly_Id)) +
            geom_line(size = 0.5) +
            ylab("Change in Angle (rad)") +
            ylim(-pi,pi) +
            xlim(0,max(single_arena_data$Frame))
        if (flies_per_arena == 2) {
            p_list[["facing_angle"]] <- single_arena_data %>%
                ggplot(aes(x = Frame, y = facing_angle, colour = Fly_Id)) +
                geom_line(size = 0.5) +
                ylab("Facing Angle (rad)") +
                ylim(0,pi) +
                xlim(0,max(single_arena_data$Frame))
        } else {
            p_list[["max_wing_ang"]] <- single_arena_data %>%
                ggplot(aes(x = Frame, y = max_wing_ang, colour = Fly_Id)) +
                geom_line(size = 0.5) +
                ylab("Max. Wing Angle (rad)") +
                ylim(0,20) +
                xlim(0,max(single_arena_data$Frame))
        }
        p_list[["vel"]] <- single_arena_data %>%
            #ggplot(aes(x = Frame, y = rollmean(x = vel, k = 200, fill = c(0,0,0), align = c("center")), colour = Fly_Id)) +
            ggplot(aes(x = Frame, y = smoothed_vel, colour = Fly_Id)) +
            geom_line(size = 0.5) +
            ylab("Velocity") +
            #ylim(0,40) +
            xlim(0,max(single_arena_data$Frame))

        if (assay_type == "optomotor" & indicator_light) {
            for (ii in seq_along(p_list)) {
                p_list[[ii]] <- p_list[[ii]] + geom_line(aes(x = Frame, y = LED_state), colour = "black", size = 0.1)
            }
        }
        print(plot_grid(plotlist = p_list, ncol = 1))

        p_list <- list()
        p_list[["ori"]] <- single_arena_data %>%
            ggplot(aes(x = Frame, y = ori, colour = Fly_Id)) +
            geom_line(size = 0.5) +
            ylab("Angle (rad") +
            labs(title = paste0(unique(single_arena_data$Video_name),":   Arena_",i)) +
            ylim(-pi,pi) +
            xlim(0,max(single_arena_data$Frame))
        p_list[["pos_x"]] <- single_arena_data %>%
            ggplot(aes(x = Frame, y = pos_x, colour = Fly_Id)) +
            geom_line(size = 0.5) +
            ylab("X positon (px)") +
            xlim(0,max(single_arena_data$Frame))
        p_list[["pos_y"]] <- single_arena_data %>%
            ggplot(aes(x = Frame, y = pos_y, colour = Fly_Id)) +
            geom_line(size = 0.5) +
            ylab("Y positon (px)") +
            xlim(0,max(single_arena_data$Frame))
        p_list[["major_axis_len"]] <- single_arena_data %>%
            ggplot(aes(x = Frame, y = major_axis_len/14.85, colour = Fly_Id)) +
            geom_line(size = 0.5) +
            ylab("Major Axis Length (mm)") +
            #ylim(0,5) +
            xlim(0,max(single_arena_data$Frame))
        p_list[["minor_axis_len"]] <- single_arena_data %>%
            ggplot(aes(x = Frame, y = minor_axis_len/14.85, colour = Fly_Id)) +
            geom_line(size = 0.5) +
            ylab("Minor Axis Length (mm)") +
            #ylim(0,5) +
            xlim(0,max(single_arena_data$Frame))
        p_list[["axis_ratio"]] <- single_arena_data %>%
            ggplot(aes(x = Frame, y = major_axis_len/minor_axis_len, colour = Fly_Id)) +
            geom_line(size = 0.5) +
            ylab("Axis Ratio") +
            ylim(0,5) +
            xlim(0,max(single_arena_data$Frame))

        if (assay_type == "optomotor" & indicator_light) {
            for (ii in seq_along(p_list)) {
                p_list[[ii]] <- p_list[[ii]] + geom_line(aes(x = Frame, y = LED_state), colour = "black", size = 0.1)
            }
        }
        print(plot_grid(plotlist = p_list, ncol = 1))
    }
    dev.off()
}
