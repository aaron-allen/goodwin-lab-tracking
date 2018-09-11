#!/usr/bin/env Rscript

library(tidyverse)
library(zoo)

CurrDir <- getwd()


for (i in list.dirs(getwd(),recursive = FALSE)){
  setwd(paste0(i,"/Results/"))
  LogFile <-file("CalculateIndicesError.log")
  
  tryCatch({
    AllRawData <- read_csv(list.files(pattern=glob2rx('*JAABAScores.csv')))
    AllRawData
    AllRawData$FileName <- as_factor(AllRawData$FileName)
    
    
    CleanedData <- AllRawData %>% mutate(
      Multitasking = ifelse(Copulation==0,(Approaching + Encirling + Contact + Turning + WingGesture), 0),
      MultitaskingWithFacing = ifelse(Copulation==0,(Approaching + Encirling + Facing + Contact + Turning + WingGesture), 0),
      Courtship = ifelse(Multitasking>=1, 1, 0),
      CourtshipWithFacing = ifelse(MultitaskingWithFacing>=1, 1, 0)
    )
    #CleanedData
    
    
    CourtshipIndex <- vector("numeric")
    CourtshipIndexWithFacing <- vector("numeric")
    WingIndex <- vector("numeric")
    ApproachingIndex <- vector("numeric")
    TurningIndex <- vector("numeric")
    ContactIndex <- vector("numeric")
    EncirclingIndex <- vector("numeric")
    FacingIndex <- vector("numeric")
    CopulationDuration <- vector("numeric")
    CourtshipInitiation <- vector("numeric")
    CourtshipTermination <- vector("numeric")
    CourtshipDuration <- vector("numeric")
    
    FlyId <- (unique(CleanedData$Id))
    ArenaNumber <- ceiling(FlyId/2)
    
    
    for (var in FlyId) {
      SubsectionedData <- filter(CleanedData, Id==var)
      #SubsectionedData <- slice(SubsectionedData, 2100:103590)
      
      SmoothedCourtship <- ifelse((rollmean(SubsectionedData$Courtship, 250,fill = c(0,0,0), align = c("center")))>0.5, 1, 0)
      SmoothedCopulation <- ifelse((rollmean(SubsectionedData$Copulation, 2250,fill = c(0,0,0), align = c("center")))>0.5, 1, 0)
      SubsectionedData <- add_column(SubsectionedData,SmoothedCourtship,SmoothedCopulation)
      #SubsectionedData
      
      StartOfCourtship <- as.numeric(which.max(SubsectionedData$SmoothedCourtship)) # NB: if the flies never court, this will be frame 1
      EndOfCourtship <- as.numeric(
        ifelse(
          sum(SubsectionedData$SmoothedCopulation)==0, 
          ifelse(
            (which.max(SubsectionedData$SmoothedCourtship)+15000)<=22500,
            which.max(SubsectionedData$SmoothedCourtship)+15000,
            22500),
          ifelse(
            which.max(SubsectionedData$SmoothedCopulation)<=(which.max(SubsectionedData$SmoothedCourtship)+15000), 
            which.max(SubsectionedData$SmoothedCopulation),
            (which.max(SubsectionedData$SmoothedCourtship)+15000))))

      
      if (EndOfCourtship<StartOfCourtship) {
        EndOfCourtship<-NA
        StartOfCourtship<-NA
        CourtshipIndex[var] <- NA
        CourtshipIndexWithFacing[var] <- NA
        CourtshipInitiation[var] <- NA
        CourtshipTermination[var] <- NA
        CourtshipDuration[var] = NA
        CopulationDuration[var] <- NA
        WingIndex[var] <- NA
        ApproachingIndex[var] <- NA
        TurningIndex[var] <- NA
        ContactIndex[var] <- NA
        EncirclingIndex[var] <- NA
        FacingIndex[var] <- NA
        
      } else {
        CourtshipNumerator <- slice(SubsectionedData, StartOfCourtship:EndOfCourtship)
        
        CourtshipIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, 0, (mean(CourtshipNumerator$Courtship)))
        CourtshipIndexWithFacing[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, 0, (mean(CourtshipNumerator$CourtshipWithFacing)))
        
        CourtshipInitiation[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, NA, (StartOfCourtship/25))
        CourtshipTermination[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, NA, (EndOfCourtship/25))
        CourtshipDuration[var] = (CourtshipTermination[var] - CourtshipInitiation[var])
        
        #CopulationDuration[var] <- (sum(SubsectionedData$Copulation))/25
        
        WingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$WingGesture)), (mean(CourtshipNumerator$WingGesture)))
        ApproachingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Approaching)), (mean(CourtshipNumerator$Approaching)))
        TurningIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Turning)), (mean(CourtshipNumerator$Turning)))
        ContactIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Contact)), (mean(CourtshipNumerator$Contact)))
        EncirclingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Encirling)), (mean(CourtshipNumerator$Encirling)))
        FacingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Facing)), (mean(CourtshipNumerator$Facing)))
      }
    }
    
    IndexDataTable <- tibble(ArenaNumber,FlyId,CourtshipIndex,CourtshipIndexWithFacing,CourtshipInitiation,CourtshipTermination,CourtshipDuration,ApproachingIndex,ContactIndex,EncirclingIndex,FacingIndex,TurningIndex,WingIndex)
    IndexDataTable %>% print(n=40)
    
    
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



