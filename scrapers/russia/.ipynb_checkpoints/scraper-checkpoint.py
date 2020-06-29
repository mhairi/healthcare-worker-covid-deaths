#!/usr/bin/env python
# coding: utf-8
# %%
import requests
from csv import writer
from bs4 import BeautifulSoup
from datetime import date


# %%
# Get data from website
url = "https://sites.google.com/view/covid-memory/home"
request = requests.get(url)
html = request.content
soup = BeautifulSoup(html)


# %%
# Two lists on the page: get al elements from both
lists = soup.find_all("ol", class_ = "n8H08c BKnRcf")

russian_list = lists[0].find_all("li")
other_list = lists[1].find_all("li")

output = [element.text for element in list_elements]


# %%


# file will be named after the date of the scrape
today = date.today()
today = today.strftime("%Y-%m-%d")
file_name = "data/" + today + ".txt"


# %%


# Write to text file
with open(file_name, "w") as f:
    f.write("\n".join(output))


# %%




