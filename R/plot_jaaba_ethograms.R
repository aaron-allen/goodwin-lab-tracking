#!/usr/bin/env Rscript


# Author: Aaron M Allen
# Date: 2021.12.02
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




plot_jaaba_ethograms <- function(input_Data,
                                 fly_id){

    suppressMessages(library("tidyverse"))

    ethogram_plot <- input_Data %>%
        filter(Fly_Id==fly_id) %>%
        select(Frame, Facing, Approaching, Turning, Encircling, WingGesture, Contact, Copulation) %>%
        gather("Behaviour", "Score", Facing, Approaching, Turning, Encircling, WingGesture, Contact, Copulation) %>%
        ggplot(aes(x=Frame,y=1)) +
            theme_classic() +
            facet_grid(Behaviour~.) +
            geom_raster(aes(fill = Score)) +
            scale_fill_gradient(low = NA, high = "black") +
            ylab("Behaviours") +
            ggtitle(paste0("FlyId_", fly_id)) +
            theme(legend.position="none",
                  plot.title = element_text(size=35,hjust = 0.5),
                  axis.text.y = element_blank(),
                  axis.ticks.y = element_blank(),
                  axis.text.x = element_text(colour = 'black', size=18),
                  axis.line = element_blank(),
                  axis.title = element_text(colour = 'black', size=24),
                  strip.text.y = element_text(colour = 'black', size=14, angle = 0)
                  )
    return(ethogram_plot)
}
