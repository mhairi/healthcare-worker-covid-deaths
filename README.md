# Counting Covid-19 Deaths in Healthcare Workers

The aim of this project is to combine several online sources which track healthcare
workers who have died of Coronavirus.

The latest clean data can be found in `covid_deaths.csv`

Currently combining data from five sources:

* [Worldwide deaths on Medscape](https://www.medscape.com/viewarticle/927976)
* [UK deaths from the Guardian](https://www.theguardian.com/world/2020/apr/16/doctors-nurses-porters-volunteers-the-uk-health-workers-who-have-died-from-covid-19)
* [Italian deaths](https://portale.fnomceo.it/elenco-dei-medici-caduti-nel-corso-dellepidemia-di-covid-19/)
* [Russian deaths](https://sites.google.com/view/covid-memory/home)
* [Brazilian deaths](http://observatoriodaenfermagem.cofen.gov.br/)

## Project Structure

The scraper for each website is written in Python and is stored in its own folder
inside `scrapers`. The data is also stored there. 

The scrapers generally carry out very little data cleaning. The data cleaning is 
done in R and can be found in the folder `cleaning`. Cleaning makes intermediate
data which is stored in `data`.

Each of `scraper`, `cleaning` and `data` have their own README.md. 

## Data Dictionary for `covid_deaths.csv`

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



