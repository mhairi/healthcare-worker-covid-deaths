The structure of the cleaning is as follows:

- Origional data is in the "scrapers" folder.
- Each dataset is cleaned from one of these raw datasets in the scripts folder.
- Results of calling the Google Translate API are saved in the folder "api_responses". This means scripts can be re-run without calling the API again and saving time/API calls. 
- Once each dataset is cleaned it is saved in "data".
- Datasets are combined with the script "combining_datasets.R", and are saved in data.
- Address info is added and the resulting dataset is saved in data.
- The dataset "covid_deaths.csv" is saved at the main level.