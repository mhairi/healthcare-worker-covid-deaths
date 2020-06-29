library(tidyverse)
library(lubridate)
library(googleLanguageR)


most_recent_file <-
  list.files("scrapers/italy/data/") %>% 
  str_sub(end = -5) %>% 
  ymd %>% 
  max %>% 
  str_c(".csv")

df <- 
  read_csv(str_c("scrapers/italy/data/", most_recent_file)) %>% 
  rename(
    occupation_original = occupation
  ) %>% 
  mutate(
    dod = dod %>% 
      str_remove(fixed("†")) %>% 
      str_remove(fixed("(data segnalazione)")) %>% 
      str_remove(fixed("*")) %>% 
      str_trim() %>% 
      dmy(locale = "it_IT")
  )


# Translation with Google Translate API

# This will work if you setup Google Translate API and set the location of your 
# credential json file in .Renviron  GL_AUTH.
# See: https://cran.r-project.org/web/packages/googleLanguageR/vignettes/setup.html

# occupations <- gl_translate(df$occupation_original, target = "en", source = "it")$translatedText
# 
# translations <- list(occupations = occupations)
# write_rds(
#   translations,
#   "cleaning/translations/italy.rds"
# )

translations <- read_rds("cleaning/translations/italy.rds")

df <- df %>% 
  mutate(
    occupation = str_to_title(translations$occupations)
  )

# Reordering

df <- df %>% transmute(name, occupation, dod, country = "Italy", occupation_original)

write_csv(df, "cleaning/data/clean_italy.csv")
