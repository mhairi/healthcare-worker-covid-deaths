library(tidyverse)
library(googleLanguageR)

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

###############
# Translating #
###############

# Translation with Google Translate API

# This will work if you setup Google Translate API and set the location of your 
# credential json file in .Renviron  GL_AUTH.
# See: https://cran.r-project.org/web/packages/googleLanguageR/vignettes/setup.html

# occupations <- gl_translate(unique(df$occupation), target = "en", source = "pt-br")
# situations <- gl_translate(unique(df$situation), target = "en", source = "pt-br")

# write_rds(list(occupations = occupations, situations = situations), "cleaning/api_responses/brazil.rds")

translation <- read_rds("cleaning/api_responses/brazil.rds")
occupations <- translation$occupations
situations <- translation$situations

df <- 
df %>% 
  left_join(occupations, by = c("occupation" = "text")) %>% 
  mutate(occupation = translatedText) %>% 
  select(-translatedText) %>% 
  left_join(situations, by = c("situation" = "text")) %>% 
  mutate(situation = translatedText) %>% 
  select(-translatedText)

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
