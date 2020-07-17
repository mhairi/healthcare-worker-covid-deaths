# Folders

## Raw Data

Raw data contains data which isn't created by writing code. Other raw data is
avalible in the scrapers folder.

## Intermediate Data

This is data created by scripts and saved here.

* The data in `country_data` is created by it's corrisponding script in `country_scripts`
* `combined_data.csv` is created by `1_combining_datasets.R`
* `data_with_address_info.csv` is created by `2_adding_address_info.R`.
* `data_with_cleaned_occupations.csv` is created by `3_cleaning_occupation.R`.
* The data in `api_reponses` is "catched" versions of data called from Google Maps 
and Google Translate APIs. Details of this data is generated can be found in the script 
`scripts/misc/update_translations.R`.

## Historical Data

The cleanest version of the data is stored here every time a new scrape is run.
This allows examination of how the data has changed through time.

## Clean Data

Two datasets are in clean data. The first is "covid_deaths_full.csv". Here we 
have all possible variables. The purpose of this dataset is to allow checking 
and  validation of the data. Some of the variables may also be useful for 
analysis.

The second is "covid_deaths.csv", this is a simplier version designed for 
analysts to use. This is also stored at the top level.


# Data Dictionary for `covid_deaths_full.csv`

| Variable              | Description                                                                                                                                                                                                      |
|-----------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name                  | Person's name                                                                                                                                                                                                    |
| age                   | Age at death                                                                                                                                                                                                     |
| occupation            | Category of occupation at time of death: Doctor, Nurse, Other Medical   (including nurses assistants, dentists, radiographers etc.), Other (including   porters, firefighters, researchers), Retired and Unknown |
| location              | Location within country - either a town, city of region of death                                                                                                                                                 |
| country               | Country of death                                                                                                                                                                                                 |
| lat                   | Latitute corresponding to location and country                                                                                                                                                                   |
| lng                   | Longitude corresponding to location and country                                                                                                                                                                  |
| dod                   | Date of death (if available)                                                                                                                                                                                     |
| source                | Source of information (either medscape, uk, brazil, italy or russia)                                                                                                                                             |
| link                  | Link to more information about the individual (if available)                                                                                                                                                     |
| unnormalised_location | Location as it appeared in the data before being normalised by Google   Maps API                                                                                                                                 |
| unnormalised_country  | Country as it appeared in the data before being normalised by Google Maps   API                                                                                                                                  |
| detailed_occupation   | More detailed version of occupation that has been simplified into   occupation column                                                                                                                            |
| original_name         | Name before translation to English, if data has been translated                                                                                                                                                  |
| original_occupation   | Occupation before translation to English, if data has been translated                                                                                                                                            |
| original_location     | Location before translation to English, if data has been translated                                                                                                                                              |
| original_country      | Country before translation to English, if data has been translated                                                                                                                                               |
| raw_data              | Data from the scrape before any processing                                                                                                                                                                       |