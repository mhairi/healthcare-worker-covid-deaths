library(tidyverse)

source("cleaning/scripts/misc/update_translations.R")

df_raw <- read_csv("cleaning/country_scripts/data/arquivo_enfermagem.csv") %>% 
  mutate(id = row_number())

df <- df_raw

names(df) <- c("dod", "uf", "region", "occupation", "situation", 
               "sex", "age", "age_range", "id")

# Removing capitals
df <-
  df %>% 
  mutate(
    across(c(occupation, situation), str_to_title)
  )


# Translating 
df <- 
df %>% 
  rename(
    occupation_original = occupation
  ) %>% 
  mutate(
    occupation = update_translations(occupation_original, "brazil_occupation.rds", "pt-br"),
    situation = update_translations(situation, "brazil_situation.rds", "pt-br")
  )

############
# Cleaning #
############

# Only diagnosed cases where the patient died

df <- 
  df %>% 
  filter(situation == "Confirmed Diagnosis Of Covid-19 Deceased")

# Add raw data

df_raw <- 
unite(df_raw, "raw_data", -id, sep = ", ")

df <- 
df %>% 
  left_join(df_raw) %>% 
  select(-id)

df <- df %>%
  transmute(
    name = "Anonymous Brazilian Healthcare Worker",
    age,
    occupation,
    country = "Brazil",
    dod,
    raw_data =raw_data
  )

write_csv(df, "cleaning/data/clean_brazil.csv")
