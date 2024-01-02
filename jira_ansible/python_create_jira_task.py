import requests
import os
from datetime import datetime, timedelta
def set_due_date():
    # Get the current date and time
    current_date_time = datetime.now()

    # Calculate the due date for the next month on the 5th
    if current_date_time.month == 12:
        next_due_date = datetime(current_date_time.year + 1, 1, 5)
    else:
        next_due_date = datetime(current_date_time.year, current_date_time.month + 1, 5)

    # Format the due date as a string in year-month-day format
    next_due_date_str = next_due_date.strftime('%Y-%m-%d')

    return next_due_date_str


due_date = set_due_date()
token = os.environ.get("password")
jira_url = "https://genus.nagarro.com"
project_key = "BBBP"
issue_type = "Task"
component_name = "Delivery"
severity_type = "Medium"

client_name = "nagarro"



issue_data = {
    "fields": {
        "project": {"key": project_key},
        "issuetype": {"name": issue_type},
        "summary": "Monthly Report",
        "description": "Insurance Monthly Report",
        "components": [{"name": component_name}],
        "customfield_10015": {"value": severity_type},
        "duedate": due_date,
        "reporter": {
            "self": "https://genus.nagarro.com/rest/api/2/user?username=anandkumar02",
            "name": "anandkumar02",
            "key": "anandkumar02"
        },
        "assignee": {"name": "shemsilva"},
        "customfield_36149": {"value": "No"},
        "customfield_33440": {"value": "Prospect"},
        "customfield_34443": "www.nagarro.com",

        "customfield_28440": {"value": "BU-BFSI"},
        "customfield_29541": "Nagarro",
        "customfield_36044": {"value": "surya.vedula@nagarro.com"},
        "customfield_35948": {"value": "India"},
        
        "customfield_34458": {"name": "suryavedula"},
        "customfield_34455": {"value": "Administrative", "child": {"value": "Miscellaneous"}},
        "customfield_34456": {"value": "General", "child": {"value": "Other"}},
     
        "customfield_34454": [
           {
            "self": "https://genus.nagarro.com/rest/api/2/customFieldOption/20381",
            "value": "Not Applicable",
            "id": "20381",

           }
         ],
        # Add values for other required fields
    }
}

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json",
}

response = requests.post(
    f"{jira_url}/rest/api/2/issue/",
    headers=headers,
    json=issue_data
)

if response.status_code == 201:
    print("Recurring issue created successfully.")
else:
    print(f"Failed to create issue. Status code: {response.status_code}")
    print(response.text)