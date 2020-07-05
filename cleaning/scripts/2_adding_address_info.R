library(ggmap)
library(tidyverse)

df <- read_csv("cleaning/data/combined_data.csv", guess_max = 2000)

get_lat <- function(output){
  lat <- output$results[[1]]$geometry$location$lat
  
  if (is.null(lat)) return(NA_real_)
  
  return(lat)
}

get_lng <- function(output){
  lng <-output$results[[1]]$geometry$location$lng
  
  if (is.null(lng)) return(NA_real_)
  
  return(lng)
}

get_country <- function(output){
  
  components <- output$results[[1]]$address_components
  
  for (component in components){
    if (component$types[[1]] == "country"){
      return(component$long_name[[1]])
    }
  }
  
  return(NA_character_)
  
}

get_city <- function(output){
  
  components <- output$results[[1]]$address_components
  
  for (component in components){
    if (component$types[[1]] == "locality"){
      return(component$long_name[[1]])
    }
  }
  
  for (component in components){
    if (component$types[[1]] == "administrative_area_level_1"){
      return(component$long_name[[1]])
    }
  }
  
  return(NA_character_)
}

get_lat <- possibly(get_lat, NA_real_)
get_lng <- possibly(get_lng, NA_real_)
get_country <- possibly(get_country, NA_character_)
get_city <- possibly(get_city, NA_character_)

get_address_info <- function(output){
  data.frame(
    lat = get_lat(output),
    lng = get_lng(output),
    get_country = get_country(output),
    get_city = get_city(output)
  )
}

df <- 
df %>% 
  mutate(
    location = coalesce(location, ""),
    country = coalesce(country, ""),
    address = paste(location, country, sep = ", ")
  ) 


address_info <- read_rds("cleaning/api_responses/google_maps.rds")

new_addresses <- df$address[!(df$address %in% address_info$address)]

if (length(new_addresses) != 0){
  
  api_response <- map(new_addresses, geocode, output = "all")
  address_info_new <- map_df(api_response, get_address_info) %>% 
    mutate(address = new_addresses)
  
  address_info <- rbind(address_info, address_info_new)
  
  address_info <- address_info %>% distinct(address, .keep_all = TRUE)
  
  write_rds(address_info, "cleaning/api_responses/google_maps.rds")
  
}

df <- left_join(df, address_info, by = "address")

# Save in three places
# 1. Add to historical record
# 2. Add to intermediate data
# 3. Overwrite final clean data

write_csv(df, paste0("cleaning/data/old_data/", lubridate::today(), ".csv"))
write_csv(df, "cleaning/data/data_with_address_info.csv")
write_csv(df, "covid_deaths.csv")
