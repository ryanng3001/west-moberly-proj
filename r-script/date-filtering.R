# obtain necessary packages 
library(tidyverse)

# read data that contains 2023 records 
sp_data <- read_csv("cleaned-data/actaea-rubra-data.csv") # !!! 

# filter data from 1980 to 2022 (inclusive)
sp_data_2022 <- filter(sp_data, year != "2023")

# filter data from 1980 to 2020 (inclusive)
sp_data_2020 <- filter(sp_data, year <= 2020)

# get number of records
nrow(sp_data_2022)
nrow(sp_data_2020)

# overwrite csv file to contain filtered data till 2022 
# !!! 
write.csv(sp_data_2022, "C:\\Users\\ryann\\Downloads\\west-moberly-proj\\cleaned-data\\actaea-rubra-data.csv", row.names=FALSE)


