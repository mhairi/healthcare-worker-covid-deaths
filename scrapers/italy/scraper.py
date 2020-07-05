import requests
from csv import DictWriter
from bs4 import BeautifulSoup
from datetime import date

# Get data from website
url = "https://portale.fnomceo.it/elenco-dei-medici-caduti-nel-corso-dellepidemia-di-covid-19/"
request = requests.get(url)
html = request.content
soup = BeautifulSoup(html, features="lxml")

# Find the main list on the page
main_content = soup.find("div", class_= "entry-content typography")
main_list = main_content.find("ol")

list_elements = main_list.find_all("li")

# Extract information from each list element
outputs = []
for element in list_elements:

    name = element.find("strong").text

    br_tag = element.find("br")

    if br_tag is not None and br_tag.parent.name == "li": # Most common case
        occupation = br_tag.next_sibling.strip()
        dod = br_tag.previous_sibling
    elif br_tag is None: # Sometimes no location data
        occupation = None
        dod = element.find("strong").next_sibling
    elif br_tag.parent.name == "strong": # Sometimes br is wrapped in strong
        occupation = br_tag.parent.next_sibling.strip()
        dod = br_tag.parent.previous_sibling

    outputs.append({
        "name" : name,
        "occupation" : occupation,
        "dod" : dod
    })


# CSVs will be named after the date of the scrape
today = date.today()
today = today.strftime("%Y-%m-%d")
file_name = "data/" + today + ".csv"


# Write to CSV
with open(file_name, "w") as f:
    field_names = ["name", "occupation", "dod"]
    writer = DictWriter(f, fieldnames = field_names)
    writer.writeheader()
    writer.writerows(outputs)
