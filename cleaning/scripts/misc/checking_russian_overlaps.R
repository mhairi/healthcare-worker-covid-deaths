library(tidyverse)
library(fuzzyjoin)

medscape <- read_csv("cleaning/data/clean_medscape.csv")
russia <- read_csv("cleaning/data/clean_russia.csv")

# There doesn't seem to be any overlap with Russia and Medscape.
# Extracting first and last names to be sure

medscape %>% 
  stringdist_inner_join(russia, by = "name", max_dist = 4) %>% 
  filter(name.x != name.y) %>% 
  select(name.x, name.y)

medscape %>% 
  stringdist_inner_join(russia, by = "name", max_dist = 4) %>% 
  filter(name.x != name.y) %>% 
  select(name.x, name.y)

russia_names <- 
  russia %>% 
  mutate(
    name_list = str_split(name, " "),
    name_len = map_int(name_list, length),
    first_name = map_chr(name_list, ~.x[[1]]),
    last_name =  map_chr(name_list, ~.x[[length(.x)]])
  ) 

medscape_names <- 
  medscape %>% 
  mutate(
    name_list = str_split(name, " "),
    name_len = map_int(name_list, length),
    first_name = map_chr(name_list, ~.x[[1]]),
    last_name =  map_chr(name_list, ~.x[[length(.x)]])
  ) 


medscape_names %>% 
  stringdist_inner_join(russia_names, by = c("first_name", "last_name"), max_dist = 3) %>% 
  select(name.x, name.y) 


medscape_names %>% 
  stringdist_inner_join(russia_names, by = "last_name", max_dist = 1) %>% 
  select(name.x, name.y) 

