library(tidyverse)

source("cleaning/misc/update_translations.R")

df_raw <- read_csv("data/raw_data/arquivo_enfermagem.csv")

df <- df_raw

names(df) <- c("dod", "uf", "region", "occupation", "situation", 
               "sex", "age", "age_range")

# Add raw data

df <-
  df %>% 
  mutate(
    raw_data = unite(df_raw, "raw_data", everything(), sep = ", ")$raw_data

  )

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

raw_data <- 
unite(df_raw, "raw_data", everything(), sep = ", ")$raw_data


df <- df %>%
  transmute(
    name = "Anonymous Brazilian Healthcare Worker",
    age,
    occupation,
    country = "Brazil",
    dod,
    raw_data 
  )

write_csv(df, "data/intermediate_data/country_data/clean_brazil.csv")
