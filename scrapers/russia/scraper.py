import requests
from csv import DictWriter
from bs4 import BeautifulSoup
from datetime import date


# Get data from website
url = "https://sites.google.com/view/covid-memory/home"
request = requests.get(url)
html = request.content
soup = BeautifulSoup(html, features="lxml")

# Two lists on the page: get al elements from both
lists = soup.find_all("ol", class_ = "n8H08c BKnRcf")

russian_list = lists[0].find_all("li")
other_list = lists[1].find_all("li")

def extract_url(element):
    try:
        return element.find("a")["href"]
    except (TypeError, KeyError):
        return None

output_1 = [{"data":element.text, "country":"Russia", "url":extract_url(element)} for element in russian_list]
output_2 = [{"data":element.text, "country":"Other", "url":extract_url(element)} for element in other_list]
outputs = output_1 + output_2

# File will be named after the date of the scrape
today = date.today()
today = today.strftime("%Y-%m-%d")
file_name = "data/" + today + ".csv"

# Write to CSV
with open(file_name, "w") as f:
    field_names = ["data", "country", "url"]
    writer = DictWriter(f, fieldnames = field_names)
    writer.writeheader()
    writer.writerows(outputs)
