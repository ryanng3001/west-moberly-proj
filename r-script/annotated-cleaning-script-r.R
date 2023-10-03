### STEP 00: install packages ###
install.packages("devtools")
install.packages("countrycode")
install.packages("rnaturalearthdata")
install.packages("maps")
install.packages("usethis")
devtools::install_github("ropenscilabs/scrubr")
install_github("ropensci/CoordinateCleaner")

### STEP 01: load packages ###
library(rgbif)
library(scrubr)
library(maps) 
library(dplyr)
library(countrycode)
library(CoordinateCleaner) # retire oct 2023 
library(ggplot2)
library(usethis)
library(devtools)
library(sf)


### STEP 03: download data from GBIF ###
myspecies <- c("Lonicera dioica") # specify species here !!!
species_search <- occ_search(scientificName = myspecies, 
                             hasCoordinate = TRUE, 
                             hasGeospatialIssue = FALSE, 
                             limit = 99999) 


### STEP 04: ensure all records have been downloaded (True) ###
species_search$meta$endOfRecords  
nrow(species_search$data) 

### STEP 05: remove records with specific issues ###
# to see abbreviations, type 'gbif_issues()' 
species_issues_clean <- species_search %>%
  occ_issues(-bri, -ccm, -cdiv, -cdout, -cdpi, -cdrepf, -cdreps,
             -cdumi, -conti, -cucdmis, -cum, -gdativ, -geodi, 
             -geodu, -iccos, -iddativ, -iddatunl, -indci, -mdativ, 
             -mdatunl, -osifbor, -osu, -preneglat, -preneglon, 
             -preswcd, -rdativ, -rdatm, -rdatunl, -typstativ, 
             -zerocd)

### STEP 06: keep columns of interest ###
species_data <- species_issues_clean$data[ , c("species", "decimalLongitude", 
                                               "decimalLatitude", "issues",
                                               "countryCode", "individualCount", 
                                               "occurrenceStatus", 
                                               "coordinateUncertaintyInMeters", 
                                               "institutionCode", "gbifID", 
                                               "references", "basisOfRecord", 
                                               "year", "month", "day", 
                                               "eventDate", "geodeticDatum", 
                                               "datasetName", "catalogNumber")]

### STEP 07: remove rows with N/A ###
species_data <- species_data%>%
  filter(!is.na(decimalLongitude))%>%
  filter(!is.na(decimalLatitude))%>%
  filter(!is.na(countryCode))%>%
  filter(!is.na(occurrenceStatus))%>%
  filter(!is.na(coordinateUncertaintyInMeters))%>%
  filter(!is.na(institutionCode))%>%
  filter(!is.na(geodeticDatum))%>%
  filter(occurrenceStatus != "ABSENT")%>% # remove 'absent' occurrences
  #remove non-UN recognized country codes (XK is a user-assigned code for Kosovo
  filter(countryCode != "XK") 

### STEP 08: remove records before 1980 ###
species_data <- species_data%>%
  filter(between(year, 1980, 2020)) 

### STEP 09: convert country code from ISO2c to ISO3c ###
species_data$countryCode <-  countrycode(species_data$countryCode, 
                                         origin =  'iso2c', 
                                         destination = 'iso3c') 

### STEP 10: identify and remove flagged records ###
species_data_clean <- species_data%>%
  cc_val()%>% # invalid lat/lon coordinates
  cc_equ()%>% # identical lat/lon
  cc_cap()%>% # coordinates in vicinity of country capitals
  cc_cen()%>% # coordinates in vicinity of country or province centroids
  cc_coun(iso3 = "countryCode")%>% #coordinates outside reported country
  cc_gbif()%>% # coordinates assigned to GBIF headquarters
  cc_inst()%>% # coordinates in the vicinity of biodiversity institutions
  cc_zero()%>% # coordinates that are zero
  cc_dupl()%>% # duplicate records
  cc_sea()%>%
  cc_outl()

### STEP 11: coordinate uncertainty <1000m ###
species_data_clean <- coord_uncertain(species_data_clean, 
                                      coorduncertainityLimit = 1000)
nrow(species_data_clean) # shows the number of records left

### STEP 12A: Histogram frequency ### 
hist(species_data_clean$year, breaks = 50, 
     ylab="Frequency", xlab="Year", 
     main=substitute(paste(italic("Lonicera dioica")," observations by year")),
     xlim=c(1980, 2023))

### STEP 12B: Map ###  
wm <- borders("world", colour="gray70", fill="gray70")
ggplot()+ coord_fixed()+ wm +
  geom_point(data = species_data_clean, 
             aes(x = decimalLongitude, y = decimalLatitude),
             colour = "black", bg = "olivedrab2", pch = 21, size = 0.75) +
  labs (x = "Longitude", 
        y = "Latitude",
        title = myspecies) + 
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, face="italic"))