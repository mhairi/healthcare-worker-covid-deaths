library(tidyverse)
library(fuzzyjoin)
library(magrittr)

#  NOTE WHEN UPDATING DATA:
#  This script needs to be run carefully line by line, since lots can go 
#  wrong at the combining stage. 

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
  filter(country %in% c("United Kingdom", "England", "Scotland", "Wales", NA) | name == "Rachel Makombe Chikanda") %>% #Rachel Makombe Chikanda	is a special case, appears in Medscape as from Zimbabwe
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
  filter(!(name.x == "Alberto Paolini" &  name.y == "Alberto Pollini")) %>% 
  filter(!(name.x == "Alberto Pollini" &  name.y == "Alberto Paolini")) 

italy_join %>% 
  filter(name.x != name.y) %>% 
  select(name.x, name.y) 

italy_join %>% 
  count(id.x) %>% 
  filter(n > 1)

italy_join %>% 
  count(id.y) %>% 
  filter(n > 1)

##########
# Russia #
##########

# Russian names are in the form:
# name_1 name_2 name_3 
# in the Russian data, and in the form:
# name_2 name_1
# In the Medscape data. This function moves names from the Russian form to the
# Medscape form to allow joining.
russia_dist <- 2

russia <- 
russia %>% 
  mutate(
    split_name = str_split(name, " "),
    joinable_name = paste(map_chr(split_name, 2), map_chr(split_name, 1))
  ) 

russia_join <-
  medscape %>% 
  filter(country == "Russia" | is.na(country)) %>% 
  filter(name != "Tatyana Safonova") %>%  # Remove Tatyana Safonova: we have two Tatyana Safonova's in the Russia data, so having one here messes up joining
  stringdist_inner_join(russia, by = c("name" = "joinable_name"), max_dist = russia_dist) 

# Need to still check for names in the same order too
russia_join2 <- 
medscape %>% 
  filter(country == "Russia" | is.na(country)) %>% 
  stringdist_inner_join(russia, by = c("name" = "name"), max_dist = russia_dist) 

russia_join <- rbind(russia_join, russia_join2)

russia_join %>% 
  filter(name.x != name.y) %>% 
  select(name.x, name.y) 

russia_join %>% 
  count(id.x) %>% 
  filter(n > 1)

russia_join %>% 
  count(id.y) %>% 
  filter(n > 1)

# Two more names need manually joined
chzhan_tszu_fen_id_medscape <-
medscape %>% 
  filter(name == "Chzhan Tszu Fen" & country == "Russia") %>% 
  pull(id)

chzhan_tszu_fen_id_russia <-
russia %>% 
  filter(name == "Zhang Junfeng") %>% 
  pull(id)

tatyana_ivanovna_alexandrova_id_medscape <-
  medscape %>% 
  filter(name == "Tatyana Ivanovna Alexandrova") %>% 
  pull(id)

tatyana_ivanovna_alexandrova_id_russia <-
  russia %>% 
  filter(name == "Alexandrova Tatyana Ivanovna") %>% 
  pull(id)

russia_join <- 
russia_join %>% 
  select(id.x, id.y) %>% 
  rbind(
    tibble(
      id.x = c(chzhan_tszu_fen_id_medscape, tatyana_ivanovna_alexandrova_id_medscape),
      id.y = c(chzhan_tszu_fen_id_russia, tatyana_ivanovna_alexandrova_id_russia)
    )
  )

#

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
    link = link,
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
    link = link,
    raw_data = paste("Medscape:", raw_data.x, "| Italy:", raw_data.y)
  )

italy_only <-
  italy %>% 
  filter(!(id %in% italy_join$id.y)) %>% 
  mutate(
    source = "italy"
  )

# Russia

rows_from_medscape <-
  medscape %>% 
  filter(id %in% russia_join$id.x) %>% 
  # Arrange in the same order as in russia_join
  mutate(id = factor(id, levels = russia_join$id.x)) %>% 
  arrange(id) %>% 
  mutate(id = as.numeric(as.character(id)))

rows_from_russia <-
  russia %>% 
  filter(id %in% russia_join$id.y) %>% 
  # Arrange in the same order as in russia_join
  mutate(id = factor(id, levels = russia_join$id.y)) %>% 
  arrange(id) %>% 
  mutate(id = as.numeric(as.character(id)))

russia_and_medscape <-   
  tibble(
    # Russian name by default here
    name = rows_from_medscape$name,
    age = coalesce(rows_from_medscape$age, rows_from_russia$age),
    occupation = coalesce(rows_from_medscape$occupation, rows_from_russia$occupation),
    location = coalesce(rows_from_medscape$location, rows_from_russia$location),
    country = coalesce(rows_from_medscape$age, rows_from_russia$age),
    occupation_original = rows_from_russia$occupation_original,
    location_original = rows_from_russia$location_original,
    country_original = rows_from_russia$country_original,
    link = coalesce(rows_from_medscape$link, rows_from_russia$link),
    source = "russia_and_medscape",
    raw_data = paste("Medscape:", rows_from_medscape$raw_data, "| Russia:", rows_from_russia$raw_data)
  )

italy_only <-
  italy %>% 
  filter(!(id %in% italy_join$id.y)) %>% 
  mutate(
    source = "italy"
  )


russia_only <-
  russia %>% 
  select(-split_name, joinable_name) %>%
  filter(!(id %in% russia_join$id.y)) %>% 
  mutate(
    source = "russia"
  )


# Brazil
brazil <-
brazil %>% 
  mutate(
    source = "brazil"
  )

# Medscape

medscape <- 
  medscape %>% 
  filter(!(id %in% uk_join$id.x)) %>% 
  filter(!(id %in% italy_join$id.x)) %>% 
  filter(!(id %in% russia_join$id.x)) %>% 
  filter(country != "Brazil") %>% # Drop all Brazil data and use Brazil specific data
  mutate(
    source = "medscape"
  )

df <- 
  medscape %>% 
  plyr::rbind.fill(uk_and_medscape) %>% 
  plyr::rbind.fill(uk_only) %>% 
  plyr::rbind.fill(italy_and_medscape) %>% 
  plyr::rbind.fill(italy_only) %>% 
  plyr::rbind.fill(russia_and_medscape) %>% 
  plyr::rbind.fill(russia_only) %>% 
  plyr::rbind.fill(brazil) %>% 
  select(-id)

write_csv(df, "data/intermediate_data/combined_data.csv")

############
# Checking #
############

# All should return TRUE

nrow(italy) == nrow(italy_and_medscape) + nrow(italy_only)

nrow(uk) == nrow(uk_and_medscape) + nrow(uk_only)

nrow(russia) == nrow(russia_and_medscape) + nrow(russia_only)


# Checking repeat names
df %>% 
  count(name) %>% 
  filter(n > 1)

# Checking similar names
# Takes a while to run - uncomment if you want to run this
# names <- unique(df$name)
# 
# distance_matrix <- adist(names, names)
# 
# for (i in 1:length(names)){
#   for (j in (i+ 1):length(names)){
# 
#     if (distance_matrix[i, j] < 3){
#       cat(names[i], names[j])
#       cat("\n")
#     }
#   }
# }

# Verified different people:
# Richard Kesner Richard Kisser
# S. L. S. F.
# María López Maria Lopez
# José Porras José Torres
# Alberto Paolini Alberto Pollini
# Sirbu Vasile Hirbu Vasile

