#!/usr/bin/env Rscript


# Author: Aaron M Allen
# Date: 2018.10.09
#     updated: 2021.12.02
#
#
# Description:
# This script takes in the JAABA scores data and computes indices for courtship and plots ethograms.
#


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


















library("data.table")
library("dtplyr")
library("tidyverse")
library("gridExtra")

OutputDirectory <- commandArgs(trailingOnly=T)[2]
FileName <- commandArgs(trailingOnly=T)[3]


setwd("Results/")
LogFile <-file(paste0(OutputDirectory,"/",FileName,"/Logs/CalculateIndicesError.log"))

tryCatch({

    # Calculate Indices Table
    #############################################

    source("calculate_indices_table.R")
    calculate_single_indices_table(input_dir = paste0(OutputDirectory,"/",FileName,"/Results/"),
                                court_init = TRUE,
                                max_court = TRUE
                                )



    # Ethogram Plots of JAABA Classifiers
    #############################################
    source("plot_jaaba_ethograms.R")
    AllRawData <- fread(list.files(pattern=glob2rx('*ALLDATA.csv')),sep = ",", showProgress = FALSE)
    # subset the data to only the variables we'll be working with
    CleanedData <- select(AllRawData,
                         FileName,
                         Arena,
                         Id,
                         Frame,
                         Approaching,
                         Contact,
                         Copulation,
                         Encircling,
                         Facing,
                         Turning,
                         WingGesture)
    CleanedData$FileName <- as_factor(CleanedData$FileName)

    FlyId <- (unique(CleanedData$Id))
    ArenaNumber <- ceiling(FlyId/2)
    OddFly <- (unique(ArenaNumber)*2)-1
    EthoFileName <- paste0(FileName, "_Ethogram.pdf")

    pdf(EthoFileName,width=10,height=7,paper='a4r')
    for (P in OddFly){
      Plot1 <- plot_jaaba_ethograms(CleanedData, P)
      Plot2 <- plot_jaaba_ethograms(CleanedData, P+1)
      grid.arrange(Plot1,Plot2,nrow=2)
    }
    dev.off()

    #############################################

    },
    error=function(e) {
        writeLines(paste0("at index/step ", i, " occurred following error ", as.character(e) ), LogFile)
        }
)
