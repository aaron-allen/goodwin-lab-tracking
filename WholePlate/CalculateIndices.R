#!/usr/bin/env Rscript

library("tidyverse")
library("zoo")
library("gridExtra")

CurrDir <- getwd()


for (i in list.dirs(getwd(),recursive = FALSE)){
  setwd(paste0(i,"/Results/"))
  LogFile <-file("CalculateIndicesError.log")
  
  tryCatch({
    AllRawData <- read_csv(list.files(pattern=glob2rx('*ALLDATA.csv')))
    #AllRawData
    CleanedData <- select(AllRawData,
                         FileName,
                         StartPosition,
                         Arena,
                         Id,
                         Frame,
                         Approaching,
                         Contact,
                         Copulation,
                         Encirling,
                         Facing,
                         Turning,
                         WingGesture)
    CleanedData$FileName <- as_factor(CleanedData$FileName)
    
    
    CleanedData <- CleanedData %>% mutate(
      Multitasking = ifelse(Copulation==0,(Approaching + Encirling + Contact + Turning + WingGesture), 0),
      MultitaskingWithFacing = ifelse(Copulation==0,(Approaching + Encirling + Facing + Contact + Turning + WingGesture), 0),
      Courtship = ifelse(Multitasking>=1, 1, 0),
      CourtshipWithFacing = ifelse(MultitaskingWithFacing>=1, 1, 0)
    )
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
    CourtshipInitiation <- vector("numeric")
    CourtshipTermination <- vector("numeric")
    CourtshipDuration <- vector("numeric")
    #CourtTermReason <- vector("numeric")
    
    FlyId <- (unique(CleanedData$Id))
    ArenaNumber <- ceiling(FlyId/2)
    StartPos <- vector()
    
    for (var in FlyId) {
      SubsectionedData <- filter(CleanedData, Id==var) %>% drop_na()
      #SubsectionedData <- slice(SubsectionedData, 2100:103590)
      #SubsectionedData[ is.na(SubsectionedData) ] <- 0
      
      
      SmoothedCourtship <- ifelse((rollmean(SubsectionedData$Courtship, 250, fill = c(0,0,0), align = c("left")))>0.5, 1, 0)
      SmoothedCopulation <- ifelse((rollmean(SubsectionedData$Copulation, 2250, fill = c(0,0,0), align = c("center")))>0.5, 1, 0)
      SubsectionedData <- add_column(SubsectionedData,SmoothedCourtship,SmoothedCopulation)
      #SubsectionedData
      
      StartOfCourtship <- as.numeric(which.max(SubsectionedData$SmoothedCourtship)) # NB: if the flies never court, this will be frame 1
      EndOfCourtship <- as.numeric(
        ifelse(
          sum(SubsectionedData$SmoothedCopulation)==0, 
          ifelse(
            (which.max(SubsectionedData$SmoothedCourtship)+15000)<=which.max(SubsectionedData$Frame),
            which.max(SubsectionedData$SmoothedCourtship)+15000,
            which.max(SubsectionedData$Frame)),
          ifelse(
            which.max(SubsectionedData$SmoothedCopulation)<=(which.max(SubsectionedData$SmoothedCourtship)+15000), 
            which.max(SubsectionedData$SmoothedCopulation),
            (which.max(SubsectionedData$SmoothedCourtship)+15000))))

      
      if (EndOfCourtship<StartOfCourtship) {
        StartPos[var] <- SubsectionedData$StartPosition[1]
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
        #CourtTermReason[var] <- ifelse(
                                    # sum(SubsectionedData$SmoothedCourtship)==0, NA,
                                    # ifelse(
                                    #   sum(SubsectionedData$SmoothedCopulation)==0, 
                                    #   ifelse(
                                    #     (which.max(SubsectionedData$SmoothedCourtship)+15000)<=which.max(SubsectionedData$Frame),
                                    #     '10 minutes',
                                    #     'End of tracking'),
                                    #   ifelse(
                                    #     which.max(SubsectionedData$SmoothedCopulation)<=(which.max(SubsectionedData$SmoothedCourtship)+15000), 
                                    #     'Copulated',
                                    #     '10 minutes')))
                                    # 
        
        
        #CopulationDuration[var] <- (sum(SubsectionedData$Copulation))/25
        StartPos[var] <- SubsectionedData$StartPosition[1]
        
        WingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$WingGesture)), (mean(CourtshipNumerator$WingGesture)))
        ApproachingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Approaching)), (mean(CourtshipNumerator$Approaching)))
        TurningIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Turning)), (mean(CourtshipNumerator$Turning)))
        ContactIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Contact)), (mean(CourtshipNumerator$Contact)))
        EncirclingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Encirling)), (mean(CourtshipNumerator$Encirling)))
        FacingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Facing)), (mean(CourtshipNumerator$Facing)))
      }
    }
    
    #IndexDataTable <- tibble(ArenaNumber,FlyId,StartPos,CourtshipIndex,CourtshipIndexWithFacing,CourtshipInitiation,CourtshipTermination,CourtshipDuration,CourtTermReason,ApproachingIndex,ContactIndex,EncirclingIndex,FacingIndex,TurningIndex,WingIndex)
    IndexDataTable <- tibble(ArenaNumber,FlyId,StartPos,CourtshipIndex,CourtshipIndexWithFacing,CourtshipInitiation,CourtshipTermination,CourtshipDuration,ApproachingIndex,ContactIndex,EncirclingIndex,FacingIndex,TurningIndex,WingIndex)
    IndexDataTable %>% print(n=40)
    
    
    # export data as csv
    #############################################
    SaveName <- paste0(unique(CleanedData$FileName),'_Indices.csv')
    write_csv(IndexDataTable, SaveName)
    #############################################
    
    


    # Ethogram Plots of JAABA Classifiers
    #############################################
    OddFly <- (unique(ArenaNumber)*2)-1
    EthoFileName <- paste0(basename(i), "_Ethogram.pdf")
    pdf(EthoFileName,width=10,height=7,paper='a4r')
    for (P in OddFly){
      Plot1 <- CleanedData %>% 
        filter(Id==P) %>%
        select(Frame, Facing, Approaching, Turning, Encirling, WingGesture, Contact, Copulation) %>% 
        gather("Behaviour", "Score", Facing, Approaching, Turning, Encirling, WingGesture, Contact, Copulation) %>% 
        ggplot(aes(x=Frame,y=1)) +
          theme_classic() +
          facet_grid(Behaviour~.) +
          geom_raster(aes(fill = Score)) +
          scale_fill_gradient(low = NA, high = "black") +
          ylab("Behaviours") +
          ggtitle(paste0("FlyId_", P)) +
          theme(legend.position="none",
                plot.title = element_text(size=35,hjust = 0.5),
                axis.text.y = element_blank(),
                axis.ticks.y = element_blank(),
                axis.text.x = element_text(colour = 'black', size=18),
                axis.line = element_blank(),
                axis.title = element_text(colour = 'black', size=24),
                strip.text.y = element_text(colour = 'black', size=14, angle = 0)
                )
      Plot2 <- CleanedData %>% 
        filter(Id==P+1) %>%
        select(Frame, Facing, Approaching, Turning, Encirling, WingGesture, Contact, Copulation) %>% 
        gather("Behaviour", "Score", Facing, Approaching, Turning, Encirling, WingGesture, Contact, Copulation) %>% 
        ggplot(aes(x=Frame,y=1)) +
          theme_classic() +
          facet_grid(Behaviour~.) +
          geom_raster(aes(fill = Score)) +
          scale_fill_gradient(low = NA, high = "black") +
          ylab("Behaviours") +
          ggtitle(paste0("FlyId_", P+1)) +
          theme(legend.position="none",
                plot.title = element_text(size=35,hjust = 0.5),
                axis.text.y = element_blank(),
                axis.ticks.y = element_blank(),
                axis.text.x = element_text(colour = 'black', size=18),
                axis.line = element_blank(),
                axis.title = element_text(colour = 'black', size=24),
                strip.text.y = element_text(colour = 'black', size=14, angle = 0)
          )
      grid.arrange(Plot1,Plot2,nrow=2)
    }
    dev.off()
    #############################################




    setwd(paste0(CurrDir))
    }, 
    error=function(e) {
      writeLines(paste0("at index/step ", i, " occurred following error ", as.character(e) ), LogFile)
    }
  ) 
}

