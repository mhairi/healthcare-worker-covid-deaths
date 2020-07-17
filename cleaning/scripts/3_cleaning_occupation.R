library(tidyverse)

df <- read_csv("cleaning/data/data_with_address_info.csv", guess_max = 2000)

df <- 
df %>% 
  mutate(
    occupation =
    if_else(str_detect(occupation, fixed("doctor", ignore_case = TRUE)),
            "Doctor", occupation),
    occupation =
    if_else(str_detect(occupation, fixed("retired", ignore_case = TRUE)),
            "Retired", occupation),
    occupation = case_when(
      occupation %in% c(
        "Family Medicine/General Practitioner",
        "GP",
        "General Practitioner",
        "Family Medicine/General Practitioner", 
        "Physician",
        "Surgeon",
        "Pediatrician",
        "Internal Medicine",
        "Cardiologist",
        "OB-GYN",
        "Pediatrics",
        "Anesthetist-Resuscitator",
        "Anesthesiology"
      ) ~ "Doctor",
      occupation %in% c(
        "Registered Nurse",
        "ICU Nurse"
      ) ~ "Nurse",
      occupation %in% c(
        "Nursing Technician",
        "Nursing assistant"
      ) ~ "Nursing Assistant",
      occupation %in% c(
        "Therapist",
        "Dentist",
        "Paramedic",
        "Radiologist",
        "Pharmacist"
      ) ~ "Other Medical",
      TRUE ~ occupation
    )
  )



df %>% 
  count(occupation, sort = TRUE) %>% 
  write_csv("occupations.csv")
