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

###################
# Manual Cleaning #
###################
df <-
df %>% 
  mutate(
    name = case_when(
      name == "Francis Olabode Ajanlekoko 53" ~ "Francis Olabode Ajanlekoko",
      TRUE ~ name
    ),
    age = case_when(
      name == "Francis Olabode Ajanlekoko" ~ 53L,
      TRUE ~ age
    )
  )

df_raw <- 
  unite(df_raw, "raw_data", everything(), sep = ", ")
  
df <- df %>%
  transmute(
    name,
    age,
    occupation,
    country = "UK",
    dod,
    raw_data = df_raw$raw_data
  )

write_csv(df, "data/intermediate_data/country_data/clean_uk.csv")

