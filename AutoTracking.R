library(tidyverse)
library(zoo)

setwd('C:\\Users\\aaron\\Desktop\\2018-07-17\\plate01\\Results')
getwd()
CurrDir <- getwd()

AllRawData <- read_csv(list.files(pattern=glob2rx('*JAABAScoresData.csv')))
AllRawData
AllRawData$FileName <- as_factor(AllRawData$FileName)


CleanedData <- AllRawData %>% mutate(
  Multitasking = ifelse(Copulation==0,(Approaching + Contact + Encirling + Turning + WingGesture + Copulation), 0),
  Courtship = ifelse(Multitasking>=1, 1, 0)
)
CleanedData

SmoothedCourtship <- ifelse((rollmean(CleanedData$Courtship, 250,fill = 0, align = c("center")))>0.5, 1, 0)
SmoothedCopulation <- ifelse((rollmean(CleanedData$Copulation, 1500,fill = 0, align = c("center")))>0.5, 1, 0)
CleanedData <- add_column(CleanedData,SmoothedCourtship,SmoothedCopulation)
CleanedData


CourtshipIndex <- vector("numeric")
WingIndex <- vector("numeric")
ApproachingIndex <- vector("numeric")
TurningIndex <- vector("numeric")
ContactIndex <- vector("numeric")
EncirclingIndex <- vector("numeric")
FacingIndex <- vector("numeric")
CopulationDuration <- vector("numeric")

FlyId <- (unique(CleanedData$Id))


for (var in FlyId) {
  sub <- filter(CleanedData, Id==var)

  StartOfCourtship <- as.numeric(which.max(sub$SmoothedCourtship))
  EndOfCourtship <- as.numeric(ifelse(which.max(sub$Copulation)>=2, which.max(sub$Copulation),which.max(sub$Frame)))
  CourtshipDuration = EndOfCourtship - StartOfCourtship + 1
  
  CourtshipIndex[var] <- (sum(sub$Courtship))/CourtshipDuration
  
  WingIndex[var] <- (sum(sub$WingGesture))/CourtshipDuration
  ApproachingIndex[var] <- (sum(sub$Approaching))/CourtshipDuration
  TurningIndex[var] <- (sum(sub$Turning))/CourtshipDuration
  ContactIndex[var] <- (sum(sub$Contact))/CourtshipDuration
  EncirclingIndex[var] <- (sum(sub$Encirling))/CourtshipDuration
  FacingIndex[var] <- (sum(sub$Facing))/CourtshipDuration
  
  CopulationDuration[var] <- (sum(sub$Copulation))/25
}

IndexDataTable <- tibble(FlyId,CourtshipIndex,CopulationDuration,ApproachingIndex,ContactIndex,EncirclingIndex,TurningIndex,WingIndex)
IndexDataTable


# export data as csv
#############################################
SaveName <- paste0(unique(CleanedData$FileName),'_Indices.csv')
write_csv(IndexDataTable, SaveName)


