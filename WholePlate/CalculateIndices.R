#!/usr/bin/env Rscript

library(tidyverse)
library(zoo)

CurrDir <- getwd()


for (i in list.dirs(getwd(),recursive = FALSE)){
  setwd(paste0(i,"/Results/"))
  LogFile <-file("CalculateIndicesError.log")
  
  tryCatch({
    CleanedData <- AllRawData %>% mutate(
      Multitasking = ifelse(Copulation==0,(Approaching + Encirling + Contact + Turning + WingGesture), 0),
      MultitaskingWithFacing = ifelse(Copulation==0,(Approaching + Encirling + Facing + Contact + Turning + WingGesture), 0),
      Courtship = ifelse(Multitasking>=1, 1, 0),
      CourtshipWithFacing = ifelse(MultitaskingWithFacing>=1, 1, 0)
    )
    CleanedData
    
    SmoothedCourtship <- ifelse((rollmean(CleanedData$Courtship, 250,fill = 0, align = c("left")))>0.5, 1, 0)
    SmoothedCopulation <- ifelse((rollmean(CleanedData$Copulation, 1500,fill = 0, align = c("left")))>0.5, 1, 0)
    CleanedData <- add_column(CleanedData,SmoothedCourtship,SmoothedCopulation)
    CleanedData
    
    
    CourtshipIndex <- vector("numeric")
    CourtshipIndexWithFacing <- vector("numeric")
    WingIndex <- vector("numeric")
    ApproachingIndex <- vector("numeric")
    TurningIndex <- vector("numeric")
    ContactIndex <- vector("numeric")
    EncirclingIndex <- vector("numeric")
    FacingIndex <- vector("numeric")
    CopulationDuration <- vector("numeric")
    LatencyToCourt <- vector("numeric")
    LatencyToCopulate <- vector("numeric")
    CourtshipInitiation <- vector("numeric")
    CourtshipTermination <- vector("numeric")
    
    
    FlyId <- (unique(CleanedData$Id))
    ArenaNumber <- ceiling(FlyId/2)
    
    
    for (var in FlyId) {
      sub <- filter(CleanedData, Id==var)
      #sub <- slice(sub, 2100:103590)
      
      StartOfCourtship <- as.numeric(which.max(sub$SmoothedCourtship))
      EndOfCourtship <- as.numeric(
        ifelse(
          sum(sub$SmoothedCopulation)==0, 
          which.max(sub$SmoothedCourtship)+15000,
          ifelse(
            which.max(sub$SmoothedCopulation)<=(which.max(sub$SmoothedCourtship)+15000), 
            which.max(sub$SmoothedCopulation),
            which.max(sub$SmoothedCourtship)+15000)))
      CourtshipDuration = EndOfCourtship - StartOfCourtship + 1
      
      CourtshipNumerator <- slice(sub, StartOfCourtship:EndOfCourtship)
      CourtshipIndex[var] <- (mean(CourtshipNumerator$Courtship))
      CourtshipIndexWithFacing[var] <- (mean(CourtshipNumerator$CourtshipWithFacing))
      
      CopulationDuration[var] <- (sum(sub$Copulation))/25
      LatencyToCourt[var] <- (StartOfCourtship/25)
      LatencyToCopulate[var] <- (EndOfCourtship/25)
      CourtshipInitiation[var] <- (StartOfCourtship/25)
      CourtshipTermination[var] <- (EndOfCourtship/25)
      
      WingIndex[var] <- (mean(CourtshipNumerator$WingGesture))
      ApproachingIndex[var] <- (mean(CourtshipNumerator$Approaching))
      TurningIndex[var] <- (mean(CourtshipNumerator$Turning))
      ContactIndex[var] <- (mean(CourtshipNumerator$Contact))
      EncirclingIndex[var] <- (mean(CourtshipNumerator$Encirling))
      FacingIndex[var] <- (mean(CourtshipNumerator$Facing))
      
    }
    
    IndexDataTable <- tibble(ArenaNumber,FlyId,CourtshipIndex,CourtshipIndexWithFacing,CourtshipInitiation,CourtshipTermination,ApproachingIndex,ContactIndex,EncirclingIndex,FacingIndex,TurningIndex,WingIndex)
    IndexDataTable
    
    
    # export data as csv
    #############################################
    SaveName <- paste0(unique(CleanedData$FileName),'_Indices.csv')
    write_csv(IndexDataTable, SaveName)
    
    setwd(paste0(CurrDir))
    }, 
    error=function(e) {
      writeLines(paste0("at index/step ", i, " occurred following error ", as.character(e) ), LogFile)
    }
  ) 
}



