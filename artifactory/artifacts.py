import requests
import json

# Define your Artifactory server URL and API key/token.
artifactory_url = "http://artifactory.nagarro.local/artifactory/"
api_key = "eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJQRjFNZWQxcU1TaS1iV2Q2cWRmdTRTSGEyenRVYUwxN25XTXFyVlpOOVJRIn0.eyJleHQiOiJ7XCJyZXZvY2FibGVcIjpcInRydWVcIn0iLCJzdWIiOiJqZmFjQDAxZ2Nra2ZjdGZra3J4MGR5enM0ejMxeWpnXC91c2Vyc1wva2FzdHVyaSIsInNjcCI6ImFwcGxpZWQtcGVybWlzc2lvbnNcL2FkbWluIiwiYXVkIjoiKkAqIiwiaXNzIjoiamZmZUAwMDAiLCJleHAiOjE3MjkyMzA0MTQsImlhdCI6MTY5NzY5NDQxNCwianRpIjoiMGMzZTk4ZTYtNjJiYy00MTA0LTlmZTMtNjFlODQ2MzE4NzVkIn0.IgEg4xu8OqgNIR9b5vJ0DyKrhacCIoiPtWIYVNWcqz1D58d7PXZtf-gcWf9bgiiNgwjNlM65NGUC4f3pNqpV52NVOvM8OWzxBzipkFwihDLTjbhlHZBqAU3Ko3zq2nrp7HaSNjq2TVBNvxpLTisjP_gT7W47mIKPXoThpn9VAY8XPUBoTYapySfSgjDaDgg3uU3_7oMVUOBM-NWjB6HMXkPTp8yAsBk55Hhf_I4Rj7VH24O5YimUY3zOFPnwLsbrs5ZaD5FIue68x7NOA65f-eHgzcW2QZT_cB4kqV__UNEB6MmnTFv2HS2S9cyqgJyCzTEQE9Z0mgYl-5UxRQzH2g"

# Function to get the size of a specific repository
def get_repository_size(repo_key):
    endpoint = f"{artifactory_url}/api/storage/{repo_key}"
    headers = {"X-JFrog-Art-Api": api_key}
    response = requests.get(endpoint, headers=headers)

    if response.status_code == 200:
        data = response.json()
        return data["repo"]
    else:
        print(f"Failed to get size for repository {repo_key}")
        return None

# Function to get the list of repositories
def get_repository_list():
    endpoint = f"{artifactory_url}/api/repositories"
    headers = {"X-JFrog-Art-Api": api_key}
    response = requests.get(endpoint, headers=headers)

    if response.status_code == 200:
        data = response.json()
        return [repo["key"] for repo in data]
    else:
        print("Failed to retrieve repository list")
        return []

# Main function to fetch the sizes of all repositories
def fetch_repository_sizes():
    repository_list = get_repository_list()
    
    if not repository_list:
        print("No repositories found.")
        return

    repository_sizes = {}
    for repo_key in repository_list:
        repo_size = get_repository_size(repo_key)
        if repo_size is not None:
            repository_sizes[repo_key] = repo_size

    return repository_sizes

# Run the main function
if __name__ == "__main__":
    repository_sizes = fetch_repository_sizes()
    if repository_sizes:
        for repo_key, repo_size in repository_sizes.items():
            print(f"Repository: {repo_key}, Size: {repo_size}")
