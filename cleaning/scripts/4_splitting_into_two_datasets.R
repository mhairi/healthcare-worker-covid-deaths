library(tidyverse)

df <- read_csv("data/intermediate_data/data_with_cleaned_occupations.csv", guess_max = 10000)

# Here we are going to split the data into two datasets. 
# 
# First "covid_deaths_full.csv" one with many variables which
# shows all the intermediate steps so that the data can be validated.
# 
# Second "covid_deaths.csv" a simpler version designed for analysts to use.
# 
# Also doing some renaming of columns for consistency

covid_deaths_full <- 
  df %>% 
  select(
    # Variables in analysis data
    name,
    age, 
    occupation = occupation_original,
    location,
    country,
    lat,
    lng,
    dod,
    # Source of data
    source,
    # Link to more information, if available
    link,
    # Location variables before being normalised by Google Maps API
    unnormalised_location = raw_location,
    unnormalised_country = raw_country,
    # More detailed version of occupation that has been simplified into occupation column
    detailed_occupation = occupation_detailed,
    # Variables before translation to English, if data has been translated
    original_name = name_original,
    original_occupation = occupation_original,
    original_location = location_original,
    original_country = country_original,
    cleaned_occupation = occupation,
    # Data as it was first scraped
    raw_data
  )

write_csv(covid_deaths_full, "data/clean_data/covid_deaths_full.csv")

covid_deaths <- 
df %>% 
  select(
    name,
    age, 
    occupation,
    location,
    country,
    lat,
    lng,
    dod
  )


# Save in two places
# 1. Add to historical record
# 2. Overwrite final clean data

write_csv(covid_deaths_full, paste0("data/historical_data/", lubridate::today(), ".csv"))
write_csv(covid_deaths, "covid_deaths.csv")
