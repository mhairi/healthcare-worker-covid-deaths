library(tidyverse)
library(lubridate)

file_names <-
  list.files("data/historical_data/") %>% 
  str_sub(end = -5) %>% 
  ymd %>% 
  sort(decreasing = TRUE)

current_df <- read_csv(str_c("data/historical_data/", file_names[1], ".csv"), guess_max = 10000)
previous_df <- read_csv(str_c("data/historical_data/", file_names[2], ".csv"), guess_max = 10000)

anti_join(current_df, previous_df) %>% View
anti_join(previous_df, current_df) %>% View
