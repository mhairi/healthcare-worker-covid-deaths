library(tidyverse)
library(lubridate)
library(googleLanguageR)

most_recent_file <-
  list.files("scrapers/russia/data/") %>% 
  str_sub(end = -5) %>% 
  ymd %>% 
  max %>% 
  str_c(".csv")

raw_data <- read_csv(str_c("scrapers/russia/data/", most_recent_file))

# Translation with Google Translate API

# This will work if you setup Google Translate API and set the location of your 
# credential json file in .Renviron  GL_AUTH.
# See: https://cran.r-project.org/web/packages/googleLanguageR/vignettes/setup.html

# translations <- gl_translate(raw_data$data, target = "en", source = "ru")$translatedText
# 
# write_rds(
#   translations,
#   "cleaning/translations/russia.rds"
# )

translations <- read_rds("cleaning/translations/russia.rds")

df <- 
translations %>% 
  # Treat text as CSV - easy way of splitting on commas
  read_csv(col_names = c("name", "age", "occupation", "location_1", "location_2", "location_3", "location_4", "location_5")) %>% 
  # If age does not contain a number, then we have no age and the age column actually
  # contains location. Assuming ages are between 10 and 99.
  mutate(
    occupation = if_else(str_detect(age, "\\d\\d"), occupation, age),
    occupation = str_to_title(occupation)
  ) %>% 
  # Change age to a number
  mutate(
    age = str_remove(age, "years old"),
    age = as.numeric(age)
  ) 

#################################
# Pulling out correct locations #
#################################

extract_last <- function(vector){
  if (all(is.na(vector))) return(NA)
  vector <- vector[!is.na(vector)]
  return(vector[length(vector)])
}

extract_second_last <- function(vector){
  if (all(is.na(vector))) return(NA)
  vector <- vector[!is.na(vector)]
  if (length(vector) == 1) return(NA) # No second last
  return(vector[length(vector) - 1])
}

locations <-
df %>% 
  rowwise() %>% 
  mutate(
    locations =  list(c(location_1, location_2, location_3, location_4, location_5)),
  ) 

last_location <- map_chr(locations$locations, ~extract_last(.x))
second_last_location <- map_chr(locations$locations, ~extract_second_last(.x))

df <- 
df %>% 
  select(-starts_with("location")) %>% 
  mutate(
    city     = if_else(raw_data$country == "Russia", last_location, second_last_location),
    country  = if_else(raw_data$country == "Russia", "Russia", last_location)
  )

write_csv(df, "cleaning/data/clean_russia.csv")