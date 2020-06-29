library(tidyverse)
library(fuzzyjoin)
library(magrittr)

# Add ID column just for joining

medscape <- read_csv("cleaning/data/clean_medscape.csv") %>% mutate(id = 1:nrow(.))
uk <- read_csv("cleaning/data/clean_uk.csv") %>% mutate(id = 1:nrow(.))
italy <- read_csv("cleaning/data/clean_italy.csv") %>% mutate(id = 1:nrow(.))
russia <- read_csv("cleaning/data/clean_russia.csv") %>% mutate(id = 1:nrow(.))

############
# Checking #
############

# Assuming that we only have overlaps between Medscape and others. for example 
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


           
italy_dist <- 2

italy_join <-
medscape %>% 
  filter(country == "Italy" | is.na(country)) %>% 
  stringdist_inner_join(italy, by = "name", max_dist = italy_dist) 

italy_join %>% 
  filter(name.x != name.y) %>% 
  select(name.x, name.y) 

# S.F and S.L are different people I think

italy_join <- filter(italy_join, name.x != "S. L.")


italy_join %>% 
  transmute(
    name = name.x,
    age = coalesce(age.x, age.y),
    occupation = coalesce(occupation.x, occupation.y),
    country = coalesce(country.x, country.y),
    dod = dod
  )
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
    dod = dod
  )

uk_only <-
  uk %>% 
  filter(!(id %in% uk_join$id.y))

medscape <- filter(medscape, !(id %in% uk_join$id.y))

# Italy and Medscape overlap
  

italy_and_medscape <-   
  italy_join %>% 
  transmute(
    name = name.x,
    age = age,
    occupation = coalesce(occupation.x, occupation.y),
    country = coalesce(country.x, country.y),
    dod = dod,
    occupation_original
  )

italy_only <-
  italy %>% 
  filter(!(id %in% italy_join$id.y))

medscape <- filter(medscape, !(id %in% italy_join$id.y))

df <- 
  medscape %>% 
  plyr::rbind.fill(uk_and_medscape) %>% 
  plyr::rbind.fill(uk_only) %>% 
  plyr::rbind.fill(italy_and_medscape) %>% 
  plyr::rbind.fill(italy_only) %>% 
  plyr::rbind.fill(russia)

write_csv(df, "covid_deaths.csv")
