# import json

# # Load the JSON data from the file
# input_file_path = "test1.json"

# with open(input_file_path, "r") as file:
#     data = json.load(file)

# # Check if the data is a list of dictionaries
# if isinstance(data, list) and all(isinstance(entry, dict) for entry in data):
#     for entry in data:
#         repo_key = entry.get("repoKey")
#         used_space = entry.get("usedSpace")
#         if repo_key is not None and used_space is not None:
#             print(f"Repository: {repo_key}, Used Space: {used_space}")
# else:
#     print("Invalid JSON data format. Expected a list of dictionaries.")

import json

# Load the JSON data from the input file
input_file_path = "test1.json"
output_file_path = "output.json"

with open(input_file_path, "r") as file:
    data = json.load(file)

# Check if the data is a list of dictionaries
if isinstance(data, list) and all(isinstance(entry, dict) for entry in data):
    extracted_data = []

    for entry in data:
        repo_key = entry.get("repoKey")
        used_space = entry.get("usedSpace")
        if repo_key is not None and used_space is not None:
            extracted_data.append({"repoKey": repo_key, "usedSpace": used_space})

    # Save the extracted data to the output file
    with open(output_file_path, "w") as output_file:
        json.dump(extracted_data, output_file, indent=2)

    print(f"Extracted data saved to {output_file_path}")
else:
    print("Invalid JSON data format. Expected a list of dictionaries.")


# import json

# # Load the JSON data from the input file
# input_file_path = "output.json"
# output_file_path = "top_ten_repos.json"


# with open(input_file_path, "r") as file:
#     data = json.load(file)

# # Check if the data is a list of dictionaries
# if isinstance(data, list) and all(isinstance(entry, dict) for entry in data):
#     # Sort the data based on usedSpace in descending order
#     sorted_data = sorted(data, key=lambda entry: entry.get("usedSpace", 0), reverse=True)

#     # Get the entry with the highest usedSpace
#     most_used_repo = sorted_data[0]

#     # Save the most used repository to the output file
#     with open(output_file_path, "w") as output_file:
#         json.dump(most_used_repo, output_file, indent=2)

#     print(f"Most used repository based on usedSpace saved to {output_file_path}")
# else:
#     print("Invalid JSON data format. Expected a list of dictionaries.")
