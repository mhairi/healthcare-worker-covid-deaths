# Counting Covid-19 Deaths in Healthcare Workers

The aim of this project is to combine several online sources which track healthcare
workers who have died of Coronavirus.

Currently combining data from four sources:

* [Worldwide deaths on Medscape](https://www.medscape.com/viewarticle/927976)
* [UK deaths from the Guardian](https://www.theguardian.com/world/2020/apr/16/doctors-nurses-porters-volunteers-the-uk-health-workers-who-have-died-from-covid-19)
* [Italian deaths](https://portale.fnomceo.it/elenco-dei-medici-caduti-nel-corso-dellepidemia-di-covid-19/)
* [Russian deaths](https://sites.google.com/view/covid-memory/home)

### Project Structure

The scraper for each website is stored in its own folder inside scrapers. The data is also stored there. A website scrape is named after the date it is carried out, so you can always track which data is the latest. The scrapers are written in Python using BeautifulSoup.

The scrapers generally carry out very little data cleaning. The data cleaning is done in R and can be found in the folder 'cleaning'.
