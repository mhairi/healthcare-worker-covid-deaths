library(tidyverse)
library(lubridate)
library(stringr)
library(readr)
library(purrr)

most_recent_file <-
list.files("scrapers/medscape/data/") %>% 
  str_sub(end = -5) %>% 
  ymd %>% 
  max %>% 
  str_c(".csv")

df_raw <- read_csv(str_c("scrapers/medscape/data/", most_recent_file))

# Last entry is wrong (name Facebook)
df_raw <- filter(df_raw, name != "Facebook" | is.na(name))
df_raw <- df_raw %>%  filter(!(is.na(name) & other_text == "\n\n\n"))

# Split by commas
df <- mutate(df_raw, other_text = str_split(other_text, pattern = ",") %>% map(str_trim))

# If name is missing, take first section of other text as name
df <- mutate(df, name = if_else(is.na(name), map_chr(other_text, 1), name))


extract_information <- function(item){
  
  #  Three cases
  # 1. We have "age unknown"
  # 2. An age is given
  # 3. No age is given
  # They should be treated in the above priority order. 
  
  age_number <- which(str_detect(item, "\\d\\d"))[1] # Assuming all ages are between 10 and 99 (says eldest is 99 on site)
  age_unknown <- which(str_detect(item, "age unknown"))[1]
  
  if (!is.na(age_number)){
    age <- str_extract(item[age_number], "\\d\\d") %>%  as.integer
  } 
  if (!is.na(age_unknown)){
    age <- NA_integer_
  }
  if (is.na(age_unknown) && is.na(age_number)){
    age <- NA_integer_
  }
  
  # Get the position in the vector where the age is stored. Next is normally job description
  age_position <- coalesce(age_unknown, age_number, 1L)
  len <- length(item)
  
  occupation <- item[age_position + 1]
  
  # If there is enough items, then last is normally country
  country <- if_else(age_position + 2 <= len, item[len], NA_character_)

  # If there is enough items, then the second last is normally location
  location <- if_else(age_position + 3 <= len, item[len - 1], NA_character_)
  
  return(
    data.frame(
      age = age,
      occupation = occupation,
      location = location,
      country = country
    )
  )
}

# other_text <- as.list(1:nrow(df))
# for (i in 1:nrow(df)){
#   other_text[[i]] <- extract_information(df$other_text[[i]])
# }

other_text <- 
map_df(df$other_text,extract_information)

df <- cbind(select(df, -other_text), other_text)

#########################
# Manual cleaning steps #
#########################

# Delete trailling commas from names
df <- mutate(df, name = if_else(str_sub(name, start = -1) == ",", str_sub(name, end = -2), name))

# Country and job title cannot be empty string
df <- 
mutate(df, 
  occupation = if_else(occupation == "", NA_character_, occupation),
  country = if_else(country == "", NA_character_, country)
)

# Delete anything in brackets from country
df <- mutate(df, country = str_remove(country, "\\(.*\\)?"))

# Some cities start with " 
df <- mutate(df, location = if_else(str_sub(location, end = 2) == "\" ", str_sub(location, start = 3), location))
df <- mutate(df, location = if_else(str_sub(location, end = 2) == "” ", str_sub(location, start = 3), location))

df <-
  df %>% 
  mutate( 
    occupation = case_when(
      name == "Khulisani Nkala" & age == 46 ~ "Mental Health Nurse",
      name == "Ate Wilma Banaag" & country == "England" ~ "Nurse",
      name == "Ana Arreaga" & country == "Ecuador" ~ "Nurse",
      name == "Anonymous Ambulance Driver" & occupation == "Volyn Region" ~ "Ambulance Driver",
      TRUE ~ occupation
    ),
    location = case_when(
      location == "and New York; last assignment in Brooklyn" ~ "Brooklyn", 
      name == "Luigi Macori" & age == 70 ~ "Morciano di Romagna (RN)",
      country == "Tlatelolco México" ~ "Tlatelolco",
      location == "Plastic and Reconstructive Surgery at the Albert Einstein College of Medicine" ~ "New York",
      name == "Ana Arreaga" & country == "Ecuador" ~ "Guayaquil",
      name == "Anonymous Ambulance Driver" & location == "Starovyzhevskaya Central District PCR Hospital" ~ NA_character_,
      TRUE ~ location
    ),
    country = case_when(
      country == "Tlatelolco México" ~ "Mexico",
      TRUE ~ country
    )
)

df <- mutate(df, raw_data = paste(df_raw$name, df_raw$other_text, sep = ", "))

# Seems to be duplicated
df <- 
df %>% 
  filter(!(name == "Samar Sinjab" & occupation == "General Practitioner" & is.na(age)))


write_csv(df, "cleaning/data/clean_medscape.csv")