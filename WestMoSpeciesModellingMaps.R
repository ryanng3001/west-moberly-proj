#West Moberly Plant Mapping Project
#Hazel Barthel
#July 2023

#script modified from Emma Nikkel's original https://github.com/enikkel/PNW-Habitat-Suitability-Modelling/blob/main/Scripts/Species%20record%20cleaning%20example%20script.R

setwd("~/NSERC/WestMoPlantProject")

# install necessary packages
install.packages("devtools")
install.packages("CoordinateCleaner")
install.packages("countrycode")
install.packages("rnaturalearthdata")
install.packages("maptools")
install.packages("dismo")
install.packages("maps")
# scrubr not available from CRAN for this version of R, so alternate download:
devtools::install_github("ropenscilabs/scrubr")


# load packages 
library(rgbif)
library(scrubr)
library(maps)
library(dplyr)
library(sp) #The legacy packages maptools, rgdal, and rgeos, underpinning the sp package, which was just loaded, will retire in October 2023. Please refer to R-spatial evolution reports for details, especially https://r-spatial.org/r/2023/05/15/evolution4.html. It may be desirable to make the sf package available; package maintainers should consider adding sf to Suggests:. The sp package is now running under evolution status 2 (status 2 uses the sf package in place of rgdal)
library(raster)
library(maptools) #Please note that 'maptools' will be retired during October 2023, plan transition at your earliest convenience (see https://r-spatial.org/r/2023/05/15/evolution4.html and earlier blogs for guidance);some functionality will be moved to 'sp'.
library(rgdal) #same note as above
library(dismo)
library(countrycode)
library(CoordinateCleaner) #rgeos version: 0.6-3, (SVN revision 696) GEOS runtime version: 3.11.2-CAPI-1.17.2 Please note that rgeos will be retired during October 2023, plan transition to sf or terra functions using GEOS at your earliest convenience. See https://r-spatial.org/r/2023/05/15/evolution4.html for details.
library(ggplot2)
library(devtools)


# download data from GBIF
myspecies <- c("Galeopsis bifida") #specify species of interest
species_search <- occ_search(scientificName = myspecies, 
                             hasCoordinate = TRUE, 
                             hasGeospatialIssue = FALSE, 
                             limit = 99999) #79000

# make sure all records have been downloaded
species_search$meta$endOfRecords

# remove records with specific issues
species_issues_clean <- species_search %>%
  occ_issues(-bri, -ccm, -cdiv, -cdout, -cdpi, -cdrepf, -cdreps,
             -cdumi, -conti, -cucdmis, -cum, -gdativ, -geodi, 
             -geodu, -iccos, -iddativ, -iddatunl, -indci, -mdativ, 
             -mdatunl, -osifbor, -osu, -preneglat, -preneglon, 
             -preswcd, -rdativ, -rdatm, -rdatunl, -typstativ, 
             -zerocd)

# keep columns of interest   
species_data <- species_issues_clean$data[ , c("species", "decimalLongitude", "decimalLatitude", 
                                               "issues", "countryCode", "individualCount", 
                                               "occurrenceStatus", "coordinateUncertaintyInMeters", 
                                               "institutionCode", "gbifID", "references", "basisOfRecord", 
                                               "year", "month", "day", "eventDate", "geodeticDatum", 
                                               "datasetName", "catalogNumber")]

# create map of raw data points
wm <- borders("world", colour="gray70", fill="gray70")
ggplot()+ coord_fixed()+ wm +
  geom_point(data = species_data, aes(x = decimalLongitude, y = decimalLatitude),
             colour = "black", bg = "brown1", pch = 21, size = 0.75) +
  theme_bw()

# remove rows with N/A 
species_data <- species_data%>%
  filter(!is.na(decimalLongitude))%>%
  filter(!is.na(decimalLatitude))%>%
  filter(!is.na(countryCode))%>%
  filter(!is.na(occurrenceStatus))%>%
  filter(!is.na(coordinateUncertaintyInMeters))%>%
  filter(!is.na(institutionCode))%>%
  filter(!is.na(geodeticDatum))%>%
  filter(occurrenceStatus != "ABSENT")%>% # remove 'absent' occurrences
  filter(countryCode != "XK") #remove non-UN recognized country codes (XK is a user-assigned code for Kosovo)

# remove records pre-1970 and post-2020
species_data <- species_data%>%
  filter(between(year, 1980, 2020)) #****1970-2020??

# create histograms to find inconsistencies
#hist(species_data$year, breaks = 50)
#hist(species_data$month, breaks = 12)
#hist(species_data$day, breaks = 31)

# convert country code from ISO2c to ISO3c (so coordinatecleaner can use it)
species_data$countryCode <-  countrycode(species_data$countryCode, 
                                         origin =  'iso2c', 
                                         destination = 'iso3c') 

# identify and remove flag records at the same time 
# to avoid specifying it in each function
names(species_data)[2:3] <- c("decimallongitude", "decimallatitude")

species_data_clean <- species_data%>%
  cc_val()%>% # invalid lat/lon coordinates
  cc_equ()%>% # records with identical lat/lon
  cc_cap()%>% # coordinates in vicinity of country capitals
  cc_cen()%>% # coordinates in vicinity of country or province centroids
  cc_coun(iso3 = "countryCode")%>% #coordinates outside reported country
  cc_gbif()%>% # coordinates assigned to GBIF headquarters
  cc_inst()%>% # coordinates in the vicinity of biodiversity institutions (botanical gardens, universities, museums)
  cc_zero()%>% # coordinates that are zero 
  cc_dupl() # duplicate records

# coordinate uncertainty <1000m - to match spatial resolution of 1km or less
species_data_clean <- coord_uncertain(species_data_clean, coorduncertainityLimit = 1000)
nrow(species_data_clean) # shows the number of records left

# check if there are an 'zero' individual counts through the 'table' function
table(species_data_clean$individualCount) # remove zeros (if applicable), N/As are OK

# create map to visualize cleaning 
wm <- borders("world", colour="gray70", fill="gray70")
ggplot()+ coord_fixed()+ wm +
  geom_point(data = species_data_clean, aes(x = decimallongitude, y = decimallatitude),
             colour = "black", bg = "olivedrab2", pch = 21, size = 0.75) +
  labs (x = "Longitude", 
        y = "Latitude",
        title = myspecies) + 
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, face="italic"))

#histogram to check distribution across years
hist(species_data_clean$year, breaks = 50, ylab="Frequency", xlab="Year", main=substitute(paste(italic("Galeopsis bifida")," observations by year")), xlim=c(1980, 2020))


#######################

# split records into training and testing datasets
species_data_train <- species_data_clean%>%
  filter(between(year, 1970, 2000)) 
species_data_test <- species_data_clean%>%
  filter(between(year, 2001, 2020)) 

# create map for training data
wm <- borders("world", colour="gray50", fill="gray50")
ggplot()+ coord_fixed()+ wm +
  geom_point(data = species_data_train, aes(x = decimallongitude, y = decimallatitude),
             colour = "yellow", size = 0.5)+
  theme_bw()

# create map for testing data
wm <- borders("world", colour="gray50", fill="gray50")
ggplot()+ coord_fixed()+ wm +
  geom_point(data = species_data_test, aes(x = decimallongitude, y = decimallatitude),
             colour = "orange", size = 0.5)+
  theme_bw()

# write to a csv file to save
write.csv(species_data_clean, "umbellatus_data__clean.csv")
write.csv(species_data_train, "umbellatus_data__train.csv")
write.csv(species_data_test, "umbellatus_data__test.csv")