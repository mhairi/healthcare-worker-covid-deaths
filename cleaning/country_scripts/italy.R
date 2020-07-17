library(tidyverse)
library(lubridate)

source("cleaning/scripts/misc/update_translations.R")

most_recent_file <-
  list.files("scrapers/italy/data/") %>% 
  str_sub(end = -5) %>% 
  ymd %>% 
  max %>% 
  str_c(".csv")

df_raw <- read_csv(str_c("scrapers/italy/data/", most_recent_file))

df <- 
  df_raw %>% 
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


df$occupation <- update_translations(df$occupation_original, "italy.rds", "it") %>% 
  str_to_title()

# Reordering

df_raw <- 
  unite(df_raw, "raw_data", everything(), sep = ", ")

df <- df %>% 
  transmute(
    name,
    occupation,
    dod,
    country = "Italy",
    occupation_original,
    raw_data = df_raw$raw_data
  )

write_csv(df, "cleaning/data/clean_italy.csv")
