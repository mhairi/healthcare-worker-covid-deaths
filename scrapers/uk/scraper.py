import requests
from csv import DictWriter
from bs4 import BeautifulSoup
from datetime import date

# Get data from website
url = "https://www.theguardian.com/world/2020/apr/16/doctors-nurses-porters-volunteers-the-uk-health-workers-who-have-died-from-covid-19"
request = requests.get(url)
html = request.content
soup = BeautifulSoup(html)

# Find all h2 elements, these contain the name and age
main_article = soup.find("div", {"data-test-id": "article-review-body"})
titles = soup.find_all("h2", class_ = None)

# Pull out information under each h2
outputs = []
for title in titles:
    # The next paragraph tag contains their info
    for tag in title.next_siblings:
        if tag.name == "p":
            info = tag
            break

    info = [tag.next_sibling for tag in info.find_all("strong")]

    outputs.append({
        "name_and_age" : title.text,
        "occupation" : info[0],
        "place_of_work" : info[1],
        "dod" : info[2]
    })

# CSVs will be named after the date of the scrape
today = date.today()
today = today.strftime("%Y-%m-%d")
file_name = "data/" + today + ".csv"

# Write to CSV
with open(file_name, "w") as f:
    field_names = ["name_and_age", "occupation", "place_of_work", "dod"]
    writer = DictWriter(f, fieldnames = field_names)
    writer.writeheader()
    writer.writerows(outputs)
