library(tidyverse)

df <- read_csv("cleaning/data/data_with_address_info.csv", guess_max = 2000)

df %>% 
  count(occupation, sort = TRUE)
