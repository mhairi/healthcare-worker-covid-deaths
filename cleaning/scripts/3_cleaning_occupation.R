library(tidyverse)

df <- read_csv("data/intermediate_data/data_with_address_info.csv", guess_max = 10000)

df <- 
df %>% 
  mutate(
    
    ################################
    # Regular Expression searching #
    ################################
    
    ### Retired ####
    
    occupation_detailed = occupation,
    occupation = str_to_lower(occupation),
    occupation =
      if_else(str_detect(occupation, "retired"),
              "Retired", occupation),
    occupation =
      if_else(str_detect(occupation, "former"),
              "Retired", occupation),
    
    ### Doctor ####
    
    occupation = 
      if_else(str_detect(occupation, "(anesthetist|anesthesiology|anestheiologist|anesthesiologist)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(cardiologist|cardiology)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "consultant"),
              "Doctor", occupation),
    occupation =
      if_else(str_detect(occupation, "(dermatologist|dermatology|dermatovenerologist)"),
              "Doctor", occupation),
    occupation =
      if_else(str_detect(occupation, "doctor"),
              "Doctor", occupation),
    occupation =
      if_else(str_detect(occupation, "emergency medicine"),
              "Doctor", occupation),
    occupation =
      if_else(str_detect(occupation, "(endocrinologist|endocrinology)"),
              "Doctor", occupation),
    occupation =
      if_else(str_detect(occupation, "(ent|otolaryngologist|otolaryngology|otorhinolaryngologist|otorhinolaryngology)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(family medicine|family practitioner)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(general practitioner|gp|general practioner)"),
            "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(gastroenterologist|gastroenterology)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(geriatrician|geriatrics)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(hematologist|hematology)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(internal medicine|internist)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(nephrology|nephrologist)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(neonatologist|neonatology)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(neurologist|neurology|neurosurgery|neurosurgeon)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(ob-gyn|obstetrics|gynecology|gynecologist|obstetrician)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(oncologist|oncology)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(ophthalmology|ophthalmologist|ophtalmologist)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(pathologist|pathology)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(orthopedist|orthopedics)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(pediatrician|pediatrics|pediatric)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(psychiatrist|psychiatry)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(pulmonologist|pulmonary)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "physician"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "resident"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(surgeon|surgery)"),
            "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(traumatologist|traumatology)"),
              "Doctor", occupation),
    occupation = 
      if_else(str_detect(occupation, "(urologist|urology)"),
              "Doctor", occupation),
    
    ### Other Medical ###
    
    occupation = 
      if_else(str_detect(occupation, "care"),
            "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "clinical"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "chinese medicine"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "cna"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "counselor"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "coroner"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "(dentist|dental|orthodonist)"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "emt"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "(medical|medicine)"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "medication technician"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "mental health"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "midwife"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "(nurse|nursing) (assistant|technician)"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "occupational medicine"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "orderly"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "paramedic"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "(pharmacist|pharmacy)"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "phlebotomist"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "(psychologist|psychology)"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "(radiologist|radiology|radiographer)"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "resuscitator"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "therapist"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "veterinarian"),
              "Other Medical", occupation),
    occupation = 
      if_else(str_detect(occupation, "(x-ray lab|x-ray lab assistant)"),
              "Other Medical", occupation),
    
    ### Nurse ###
    
    occupation =
      if_else(str_detect(occupation, "nurse"),
            "Nurse", occupation),
    occupation =
      if_else(str_detect(occupation, "nursing staff"),
              "Nurse", occupation),
    occupation = 
      if_else(str_detect(occupation, "sister"),
              "Other Medical", occupation),

    ### Unknown ###
    occupation = 
      if_else(str_detect(occupation, "unknown"),
              "Unknown", occupation)
   )


####################
# Explicit Matches #
####################
df <- 
mutate(df,
  occupation = case_when(
    occupation %in% c(
      "cardiorenatologist",
      "diabetologist",
      "immunologist",
      "infectious disease specialist",
      "infectious disease",
      "infectionist",
      "ophthamologist",
      "phthisiatrist",
      "physiatrist",
      "pneumologist",
      "proctologist",
      "respiratory medicine",
      "rheumatologist",
      "specialist in general surgery and oncology",
      "specialist in general surgery, in vascular surgery and in thoracic surgery, former general surgery primary",
      "specialist in hygiene and preventive medicine",
      "specialist in otolaryngology and phoniatrics",
      "tb specialist"
    ) ~ "Doctor",
    occupation %in% c(
      "bank staff",
      "certified nursing assistant",
      "ekg technician",
      "electrocardiograph",
      "emergency medical technician",
      "endoscopist",
      "mammogram technician",
      "maternity assistant",
      "radiologic technologist",
      "surgical technician",
      "theatre assistant"
    ) ~ "Other Medical",
    occupation %in% c(
      "nursing supervisor"
    ) ~ "Nurse",
    occupation %in% c(
      "ambulance driver",
      "ambulance volunteer",
      "hospital staff",
      "other"
    ) ~
      "Other",
    is.na(occupation) ~ "Unknown",
    TRUE ~ occupation
  )
)


### Everything left is 'Other' ###

df <- 
df %>% 
mutate(
  occupation = if_else(occupation %in% c("Doctor", "Nurse", "Other Medical", "Other", "Retired", "Unknown"), occupation, "Other")
)

write_csv(df, "data/intermediate_data/data_with_cleaned_occupations.csv")


