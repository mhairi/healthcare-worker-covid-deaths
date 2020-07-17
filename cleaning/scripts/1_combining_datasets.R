library(tidyverse)
library(fuzzyjoin)
library(magrittr)

#  NOTE WHEN UPDATING DATA:
#  This script needs to be run carefully line by line, since lots can go 
#  wrong at the combining stage. Also recommending to run 
#  `cleaning/misc/checking_russian_overlaps.R` to ensure still no overlap between
#  medscape and russia.

# Add ID column just for joining

medscape <- read_csv("data/intermediate_data/country_data/clean_medscape.csv") %>% mutate(id = 1:nrow(.))
uk <- read_csv("data/intermediate_data/country_data/clean_uk.csv") %>% mutate(id = 1:nrow(.))
italy <- read_csv("data/intermediate_data/country_data/clean_italy.csv") %>% mutate(id = 1:nrow(.))
russia <- read_csv("data/intermediate_data/country_data/clean_russia.csv") %>% mutate(id = 1:nrow(.))
brazil <- read_csv("data/intermediate_data/country_data/clean_brazil.csv")

############
# Checking #
############

# Assuming that we only have overlaps between Medscape and others. For example 
# no one should appear on both the UK and Russian lists

# Checking if joins are working and 
# do manual tweaking to subjectively find best distance for each dataset

uk_dist <- 3

uk_join <-
medscape %>% 
  filter(country %in% c("United Kingdom", "England", "Scotland", "Wales", NA)) %>% 
  stringdist_inner_join(uk, by = "name", max_dist = uk_dist) 

uk_join %>% 
  filter(name.x != name.y) %>% 
  select(name.x, name.y) 

uk_join %>% 
  count(id.x) %>% 
  filter(n > 1)

uk_join %>% 
  count(id.y) %>% 
  filter(n > 1)

italy_dist <- 2

italy_join <-
medscape %>% 
  filter(country == "Italy" | is.na(country)) %>% 
  stringdist_inner_join(italy, by = "name", max_dist = italy_dist) 


# S.F and S.L are different people I think
# Alberto Paolini and Alberto Pollini are different people

italy_join <- italy_join %>%  
  filter(name.x != "S. L.") %>% 
  filter(name.x != "Alberto Paolini" &  name.y != "Alberto Pollini") %>% 
  filter(name.x != "Alberto Pollini" &  name.y != "Alberto Paolini") 

italy_join %>% 
  filter(name.x != name.y) %>% 
  select(name.x, name.y) 

italy_join %>% 
  count(id.x) %>% 
  filter(n > 1)

italy_join %>% 
  count(id.y) %>% 
  filter(n > 1)


# There doesn't seem to be any overlap between Medscape and the Russian dataset.
# See file "checking_russian_overlaps.R" for an investigation.

#################
# Doing joining #
#################

# If we have conflicting information, we are taking Medscape as truth

# UK and Medscape overlap

uk_and_medscape <-   
  uk_join %>% 
  transmute(
    name = name.x,
    age = coalesce(age.x, age.y),
    occupation = coalesce(occupation.x, occupation.y),
    country = coalesce(country.x, country.y),
    dod = dod,
    source = "uk_and_medscape",
    raw_data = paste("Medscape:", raw_data.x, "| UK:", raw_data.y)
  )

uk_only <-
  uk %>% 
  filter(!(id %in% uk_join$id.y)) %>% 
  mutate(
    source = "uk"
  )

# Italy and Medscape overlap

italy_and_medscape <-   
  italy_join %>% 
  transmute(
    name = name.x,
    age = age,
    occupation = coalesce(occupation.x, occupation.y),
    country = coalesce(country.x, country.y),
    dod = dod,
    occupation_original,
    source = "italy_and_medscape",
    raw_data = paste("Medscape:", raw_data.x, "| Italy:", raw_data.y)
  )

italy_only <-
  italy %>% 
  filter(!(id %in% italy_join$id.y)) %>% 
  mutate(
    source = "italy"
  )

# Medscape

medscape <- 
  medscape %>% 
  filter(!(id %in% uk_join$id.x)) %>% 
  filter(!(id %in% italy_join$id.x)) %>% 
  filter(country != "Brazil") %>% # Drop all Brazil data and use Brazil specific data
  mutate(
    source = "medscape"
  )

# Russia

russia <-
  russia %>% 
  mutate(
    source = "russia"
  )


# Brazil
brazil <-
brazil %>% 
  mutate(
    source = "brazil"
  )

df <- 
  medscape %>% 
  plyr::rbind.fill(uk_and_medscape) %>% 
  plyr::rbind.fill(uk_only) %>% 
  plyr::rbind.fill(italy_and_medscape) %>% 
  plyr::rbind.fill(italy_only) %>% 
  plyr::rbind.fill(russia) %>% 
  plyr::rbind.fill(brazil) %>% 
  select(-id)

write_csv(df, "data/intermediate_data/combined_data.csv")


# Checking
# All three should return TRUE

nrow(italy) == nrow(italy_and_medscape) + nrow(italy_only)

nrow(uk) == nrow(uk_and_medscape) + nrow(uk_only)

original_medscape <- read_csv("data/intermediate_data/country_data/clean_medscape.csv")
nrow(medscape) == nrow(original_medscape) - nrow(uk_and_medscape) - nrow(italy_and_medscape) - nrow(filter(original_medscape, country == "Brazil"))
