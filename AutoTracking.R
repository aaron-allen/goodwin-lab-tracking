library(tidyverse)



AllRawData <- read_csv('AllRawCourtshipData.csv')
AllRawData


CleanedData <- AllRawData %>% mutate(
  Multitasking = (Approaching + Contact + Encirling + Turning + WingGesture + Copulation),
#  Multitasking = ifelse(Copulation==0,(Approaching + Contact + Encirling + Turning + WingGesture + Copulation), 0),
  Courtship = ifelse(Multitasking>=1, 1, 0),
#  SimpleGenotype = GenotypeString,
#  Individual = IndividualString
)
CleanedData
CleanedData$Genotype <- as_factor(AllRawData$Genotype)
CleanedData$SimpleGenotype <- as_factor(CleanedData$SimpleGenotype)
CleanedData$Individual <- as_factor(CleanedData$Individual)
CleanedData


#CI
#################

CI <- vector("numeric")
Labels <- as.factor(unique(CleanedData$Genotype))
for (var in Labels) {
  sub <- filter(CleanedData, Genotype==var)
  StartOfCourtship <- as.numeric(which.max(sub$Courtship))
  #  EndOfCourtship <- as.numeric(ifelse(which.max(sub$Copulation)>=2, which.max(sub$Copulation),which.max(sub$Frame)))
  EndOfCourtship <- as.numeric(which.max(sub$Frame))
  CourtshipDuration = EndOfCourtship - StartOfCourtship + 1
  CI[var] <- (sum(sub$Courtship))/CourtshipDuration
}
CITable <- tibble(Labels,CI)
CITable
glimpse(CITable)
GenotypeString <- str_sub(str_extract(CITable$Labels, "fru(.*)_10min"), end = -7)
IndividualString <- str_sub(str_extract(CITable$Labels, "video(.*)_"), end = -2)
FinalCITable <- CITable %>% mutate(
  Genotype = GenotypeString,
  Individual = IndividualString
)
FinalCITable
glimpse(FinalCITable)



#Wing
############################################


WingGesture <- vector("numeric")
Labels <- as.factor(unique(CleanedData$Genotype))
for (var in Labels) {
  sub <- filter(CleanedData, Genotype==var)
  WingGesture[var] <- mean(sub$WingGesture)
}
WingGestureTable <- tibble(Labels,WingGesture)
WingGestureTable
glimpse(WingGestureTable)
GenotypeString <- str_sub(str_extract(WingGestureTable$Labels, "fru(.*)_10min"), end = -7)
IndividualString <- str_sub(str_extract(WingGestureTable$Labels, "video(.*)_"), end = -2)
FinalWingGestureTable <- WingGestureTable %>% mutate(
  Genotype = GenotypeString,
  Individual = IndividualString
)
FinalWingGestureTable
glimpse(FinalWingGestureTable)
which(is.na(FinalWingGestureTable$WingGesture))
which(is.nan(FinalWingGestureTable$WingGesture))
which(is.infinite(FinalWingGestureTable$WingGesture))


#Approaching
############################################
Approaching <- vector("numeric")
Labels <- as.factor(unique(CleanedData$Genotype))
for (var in Labels) {
  sub <- filter(CleanedData, Genotype==var)
  Approaching[var] <- mean(sub$Approaching)
}
ApproachingTable <- tibble(Labels,Approaching)
ApproachingTable
GenotypeString <- str_sub(str_extract(ApproachingTable$Labels, "fru(.*)_10min"), end = -7)
IndividualString <- str_sub(str_extract(ApproachingTable$Labels, "video(.*)_"), end = -2)
FinalApproachingTable <- ApproachingTable %>% mutate(
  Genotype = GenotypeString,
  Individual = IndividualString
)
FinalApproachingTable



#Turning
############################################
Turning <- vector("numeric")
Labels <- as.factor(unique(CleanedData$Genotype))
for (var in Labels) {
  sub <- filter(CleanedData, Genotype==var)
  Turning[var] <- mean(sub$Turning)
}
TurningTable <- tibble(Labels,Turning)
TurningTable
GenotypeString <- str_sub(str_extract(TurningTable$Labels, "fru(.*)_10min"), end = -7)
IndividualString <- str_sub(str_extract(TurningTable$Labels, "video(.*)_"), end = -2)
FinalTurningTable <- TurningTable %>% mutate(
  Genotype = GenotypeString,
  Individual = IndividualString
)
FinalTurningTable




#Contact
############################################
Contact <- vector("numeric")
Labels <- as.factor(unique(CleanedData$Genotype))
for (var in Labels) {
  sub <- filter(CleanedData, Genotype==var)
  Contact[var] <- mean(sub$Contact)
}
ContactTable <- tibble(Labels,Contact)
ContactTable
GenotypeString <- str_sub(str_extract(ContactTable$Labels, "fru(.*)_10min"), end = -7)
IndividualString <- str_sub(str_extract(ContactTable$Labels, "video(.*)_"), end = -2)
FinalContactTable <- ContactTable %>% mutate(
  Genotype = GenotypeString,
  Individual = IndividualString
)
FinalContactTable


#Encircling
############################################
Encircling <- vector("numeric")
Labels <- as.factor(unique(CleanedData$Genotype))
for (var in Labels) {
  sub <- filter(CleanedData, Genotype==var)
  Encircling[var] <- mean(sub$Encirling)
}
EncirclingTable <- tibble(Labels,Encircling)
EncirclingTable
GenotypeString <- str_sub(str_extract(EncirclingTable$Labels, "fru(.*)_10min"), end = -7)
IndividualString <- str_sub(str_extract(EncirclingTable$Labels, "video(.*)_"), end = -2)
FinalEncirclingTable <- EncirclingTable %>% mutate(
  Genotype = GenotypeString,
  Individual = IndividualString
)
FinalEncirclingTable




#Copulation
############################################
Copulation <- vector("numeric")
Labels <- as.factor(unique(CleanedData$Genotype))
for (var in Labels) {
  sub <- filter(CleanedData, Genotype==var)
  Copulation[var] <- mean(sub$Copulation)
}
CopulationTable <- tibble(Labels,Copulation)
CopulationTable
GenotypeString <- str_sub(str_extract(CopulationTable$Labels, "fru(.*)_10min"), end = -7)
IndividualString <- str_sub(str_extract(CopulationTable$Labels, "video(.*)_"), end = -2)
FinalCopulationTable <- CopulationTable %>% mutate(
  Genotype = GenotypeString,
  Individual = IndividualString
)
FinalCopulationTable












# export data as csv
#############################################

write_csv(x, path, na = "NA", append = FALSE, col_names = !append)