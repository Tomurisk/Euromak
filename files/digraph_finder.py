import re

# Read content from the HTML file with UTF-8 encoding
with open("test.htm", "r", encoding="utf-8") as file:
    html_content = file.read()

# Define the regex pattern
pattern = "ө."

# Find all matches using re.findall()
matches = re.findall(pattern, html_content)

# Join the matches into a single string separated by spaces
matches_as_string = ' '.join(matches)

# Print the matches as a single string
print(matches_as_string)
