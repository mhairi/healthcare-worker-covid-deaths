import requests
from csv import DictWriter
from bs4 import BeautifulSoup
from datetime import date

# Get data from website
url = "https://www.medscape.com/viewarticle/927976"
request = requests.get(url)
html = request.content
soup = BeautifulSoup(html)

# Find all paragraphs inside the main content
main_content = soup.find("div", id = "article-content")
paragraphs = main_content.find_all("p")

# Pull out link, link text and other text for each paragraph
outputs = []
for p in paragraphs[7:]: # First 7 paragraphs are introduction (this might change)
    
    link = p.find("a")
    if link is not None:
        name = link.text
        other_text = link.next_sibling
    else:
        name = None
        other_text = p.text
        
    outputs.append({
        "name" : name,
        "other_text": other_text
    })

# CSVs will be named after the date of the scrape
today = date.today()
today = today.strftime("%Y-%m-%d")
file_name = "data/" + today + ".csv"

# Write to CSV
with open(file_name, "w") as f:
    field_names = ["name", "other_text"]
    writer = DictWriter(f, fieldnames = field_names)
    writer.writeheader()
    writer.writerows(outputs)
