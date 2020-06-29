#!/usr/bin/env python
# coding: utf-8
# %%
import requests
from csv import DictWriter
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

output_1 = [{"data":element.text, "country":"Russia"} for element in russian_list]
output_2 = [{"data":element.text, "country":"Other"} for element in other_list]
outputs = output_1 + output_2


# %%
# File will be named after the date of the scrape
today = date.today()
today = today.strftime("%Y-%m-%d")
file_name = "data/" + today + ".csv"


# %%
# Write to CSV
with open(file_name, "w") as f:
    field_names = ["data", "country"]
    writer = DictWriter(f, fieldnames = field_names)
    writer.writeheader()
    writer.writerows(outputs)


# %%



