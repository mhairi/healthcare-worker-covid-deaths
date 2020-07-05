library(tidyverse)
library(lubridate)

most_recent_file <-
  list.files("scrapers/uk/data/") %>% 
  str_sub(end = -5) %>% 
  ymd %>% 
  max %>% 
  str_c(".csv")

df_raw <- read_csv(str_c("scrapers/uk/data/", most_recent_file))

df <- 
  df_raw %>%
  # Rename for consistency with other scrapers
  rename(
    location = place_of_work
  ) %>% 
  # Create name and age columns
  separate(name_and_age, c("name", "age"), sep = ",") %>% 
  # Remove leading colons
  mutate_all(~str_remove(., "^: ?")) %>% 
  # Use proper missing values
  mutate_all(~na_if(., "Unknown")) %>% 
  mutate_all(~na_if(., "unknown")) %>% 
  mutate_all(~na_if(., "N/A")) %>% 
  # Convert everything to the correct type
  mutate(
    # Sometimes missing year, but everything will in 2020.
    dod = if_else(str_detect(dod, "2020"), dod, paste(dod, "2020")) %>% dmy,
    age = as.integer(age)
  )
  
df <- df %>%
  transmute(
    name,
    age,
    occupation,
    country = "UK",
    dod,
    raw_data = paste(df_raw$name_and_age, df_raw$occupation, df_raw$place_of_work, df_raw$dod, sep = ", ")
  )

write_csv(df, "cleaning/data/clean_uk.csv")

