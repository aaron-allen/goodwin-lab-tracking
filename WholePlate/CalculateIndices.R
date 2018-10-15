#!/usr/bin/env Rscript

# Aaron M. Allen, 2018.10.09
# This script takes in the JAABA scores data and computes indices for courtship and plots ethograms.



library("tidyverse")
library("zoo")
library("gridExtra")

CurrDir <- getwd()


for (i in list.dirs(getwd(),recursive = FALSE)){
  setwd(paste0(i,"/Results/"))
  LogFile <-file("CalculateIndicesError.log")
  
  tryCatch({
    AllRawData <- read_csv(list.files(pattern=glob2rx('*ALLDATA.csv')))
    # subset the data to only the variables we'll be working with
    CleanedData <- select(AllRawData,
                         FileName,
                         StartPosition,
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
    
    # Using the binary JAABA scores, we compute a courtship variables such that if the fly is performing at least one
    # of the behaviours, the courtship variables will be equal to 1.  
    CleanedData <- CleanedData %>% mutate(
      # The below if statements for Multitasking causes an issue if the start of smoothedCopulation is significantly different to the 
      # actual start of copulation. So I've reset the variable to just be the sum of the features.
      # Multitasking = ifelse(Copulation==0,(Approaching + Encircling + Contact + Turning + WingGesture), 0),
      # MultitaskingWithFacing = ifelse(Copulation==0,(Approaching + Encircling + Facing + Contact + Turning + WingGesture), 0),
      Multitasking = (Approaching + Encircling + Contact + Turning + WingGesture),
      MultitaskingWithFacing = (Approaching + Encircling + Facing + Contact + Turning + WingGesture),
      Courtship = ifelse(Multitasking>=1, 1, 0),
      CourtshipWithFacing = ifelse(MultitaskingWithFacing>=1, 1, 0),
      MultitaskingWithCopulation = (Approaching + Encircling + Contact + Turning + WingGesture + Copulation),
      MultitaskingWithCopulationWithFacing = (Approaching + Encircling + Facing + Contact + Turning + WingGesture + Copulation),
      CourtshipAndCopulation = ifelse(MultitaskingWithCopulation>=1, 1, 0),
      CourtshipAndCopulationWthFacing = ifelse(MultitaskingWithCopulationWithFacing>=1, 1, 0)
    )

    # Setting up empty vectors that will be populated below for each fly
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
    TotalCCI <- vector("numeric")
    TotalCCIwFacing <- vector("numeric")

    FlyId <- (unique(CleanedData$Id))
    ArenaNumber <- ceiling(FlyId/2)
    StartPos <- vector()
    
    NumberOfFlies = (1:length(FlyId))
    for (var in NumberOfFlies) {
      SubsectionedData <- filter(CleanedData, Id==FlyId[var]) %>% drop_na()
      
      # Applying a smoothing filter to the courtship and copulation variables.
      # The smoothed courtship allows us to assertain the starting point for when the fly has conducted courtship behaviour
      # for at least 3 seconds over a 6 second window. The smoothed copulation allows us to mask any subtle inaccuracies with
      # raw JAABA annotation.
      SmoothedCourtship <- ifelse((rollmean(SubsectionedData$Courtship, 150, fill = c(0,0,0), align = c("left")))>0.5, 1, 0)
      SmoothedCopulation <- ifelse((rollmean(SubsectionedData$Copulation, 1250, fill = c(0,0,0), align = c("center")))>0.5, 1, 0)
      SubsectionedData <- add_column(SubsectionedData,SmoothedCourtship,SmoothedCopulation)
      
      StartOfCourtship <- as.numeric(which.max(SubsectionedData$SmoothedCourtship)) # NB: if the flies never court, this will be frame 1
      # End of Courtship is defined as either the start of copulation, 10 minutes after courtship initiation, or the end to tracking, which
      # ever is the lowest value.
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

      # Sometimes there is a false positive annotation of courtship initiation after copulation initiation for females.
      # To address (or rather hide) this, if courtship initiation occurs after courtship termination, then I record 'not available'
      # for all the indices.     
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
        TotalCCI[var] <- NA
        TotalCCIwFacing[var] <- NA
        
      } else {
        CourtshipNumerator <- slice(SubsectionedData, StartOfCourtship:EndOfCourtship)
        # If the fly fails to initiate courtship (ie 3 out 6 seconds from above) then CI is recorded at 0
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
        
        # If the fly fails to initiate courtship (ie 3 out 6 seconds from above) then other indices are recorded at for the full duration of tracking
        WingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$WingGesture)), (mean(CourtshipNumerator$WingGesture)))
        ApproachingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Approaching)), (mean(CourtshipNumerator$Approaching)))
        TurningIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Turning)), (mean(CourtshipNumerator$Turning)))
        ContactIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Contact)), (mean(CourtshipNumerator$Contact)))
        EncirclingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Encircling)), (mean(CourtshipNumerator$Encircling)))
        FacingIndex[var] <- ifelse(sum(SubsectionedData$SmoothedCourtship)==0, (mean(SubsectionedData$Facing)), (mean(CourtshipNumerator$Facing)))
        TotalCCI[var] <- mean(SubsectionedData$CourtshipAndCopulation)
        TotalCCIwFacing[var] <- mean(SubsectionedData$CourtshipAndCopulationWthFacing)
      }
    }
    
    #IndexDataTable <- tibble(ArenaNumber,FlyId,StartPos,CourtshipIndex,CourtshipIndexWithFacing,CourtshipInitiation,CourtshipTermination,CourtshipDuration,CourtTermReason,ApproachingIndex,ContactIndex,EncirclingIndex,FacingIndex,TurningIndex,WingIndex)
    IndexDataTable <- tibble(ArenaNumber,FlyId,StartPos,CourtshipIndex,CourtshipIndexWithFacing,CourtshipInitiation,CourtshipTermination,CourtshipDuration,ApproachingIndex,ContactIndex,EncirclingIndex,FacingIndex,TurningIndex,WingIndex,TotalCCI,TotalCCIwFacing)
    IndexDataTable %>% print(n=40)
    
    
    # export data as csv
    #############################################
    SaveName <- paste0(unique(CleanedData$FileName),'_Indices.csv')
    write_csv(IndexDataTable, SaveName)
    #############################################
    
    


    # Ethogram Plots of JAABA Classifiers
    #############################################
    FlyId <- (unique(CleanedData$Id))
    ArenaNumber <- ceiling(FlyId/2)
    OddFly <- (unique(ArenaNumber)*2)-1
    EthoFileName <- paste0(basename(i), "_Ethogram.pdf")
    pdf(EthoFileName,width=10,height=7,paper='a4r')
    for (P in OddFly){
      Plot1 <- CleanedData %>% 
        filter(Id==P) %>%
        select(Frame, Facing, Approaching, Turning, Encircling, WingGesture, Contact, Copulation) %>% 
        gather("Behaviour", "Score", Facing, Approaching, Turning, Encircling, WingGesture, Contact, Copulation) %>% 
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
        select(Frame, Facing, Approaching, Turning, Encircling, WingGesture, Contact, Copulation) %>% 
        gather("Behaviour", "Score", Facing, Approaching, Turning, Encircling, WingGesture, Contact, Copulation) %>% 
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

