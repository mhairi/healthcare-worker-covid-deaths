# Cleaning Structure

- Original data is in the "scrapers" folder.
- Except for Brazil which is downloaded to CSV from http://observatoriodaenfermagem.cofen.gov.br/. A Brazilian IP address is needed to access this data.
- Each dataset is cleaned from one of these raw datasets using a script from "country_scripts". 
- The cleaned country datasets are stored in "data".
- The datasets are then combined and cleaned further, using scripts from "scripts".
- Intermediate steps are saved in "data".
- The dataset "covid_deaths.csv" is saved at the main level.

- Results of calling the APIs are "cached" in the folder "api_responses". This means scripts can be re-run without calling the API again and saving time/API calls. 