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


df_original <-
  raw_data$data %>% 
  # Treat text as CSV - easy way of splitting on commas
  read_csv(col_names = c("name", "age", "occupation", "location_1", "location_2", "location_3", "location_4", "location_5")) %>% 
  # If age does not contain a number, then we have no age and the age column actually
  # contains location. Assuming ages are between 10 and 99.
  mutate(
    occupation = if_else(str_detect(age, "\\d\\d"), occupation, age),
    occupation = str_to_title(occupation),
    age = str_extract(age, "\\d\\d"),
    age = as.numeric(age)
  ) %>% 
  rowwise() %>% 
  mutate(
    locations =  list(c(location_1, location_2, location_3, location_4, location_5)),
  ) %>% 
  ungroup() %>% 
  mutate(
    location = if_else(raw_data$country == "Russia",
                   map_chr(locations, ~extract_last(.x)),
                   map_chr(locations, ~extract_second_last(.x))
    ),
    country = if_else(raw_data$country == "Russia",
                      "Russia",
                      map_chr(locations, ~extract_last(.x))
    )
  )

###############
# Translating #
###############

# Translation with Google Translate API

# This will work if you setup Google Translate API and set the location of your 
# credential json file in .Renviron  GL_AUTH.
# See: https://cran.r-project.org/web/packages/googleLanguageR/vignettes/setup.html

# translations <- 
#   df_original %>% 
#   transmute(
#     name =  gl_translate(name, target = "en", source = "ru")$translatedText,
#     occupation = gl_translate(occupation, target = "en", source = "ru")$translatedText,
#     location = gl_translate(location, target = "en", source = "ru")$translatedText,
#     country = if_else(country != "Russia", gl_translate(country,  target = "en", source = "ru")$translatedText, "Russia")
#   )
# 
# write_rds(
#   translations,
#   "cleaning/translations/russia.rds"
# )

translations <- read_rds("cleaning/translations/russia.rds")


###########################
# Put everything together #
###########################

df <- 
  tibble(
    name = translations$name,
    age = df_original$age,
    occupation = translations$occupation,
    location = translations$location,
    country = translations$country,
    name_original = df_original$name,
    occupation_original = df_original$occupation,
    location_original = df_original$location,
    country_original = df_original$country
  )

write_csv(df, "cleaning/data/clean_russia.csv")