import json
import csv

# Load the JSON data from the input file
input_file_path = "datefrom.json"
output_file_path = "datefrom.csv"

with open(input_file_path, "r") as json_file:
    data = json.load(json_file)

# Check if the data is a list of dictionaries
if isinstance(data, list) and all(isinstance(entry, dict) for entry in data):
    # Extract the keys from the first dictionary to be used as CSV headers
    headers = data[0].keys()

    # Write data to the CSV file
    with open(output_file_path, "w", newline="") as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=headers)
        writer.writeheader()  # Write the CSV header
        writer.writerows(data)  # Write the data rows

    print(f"Data converted from JSON to CSV and saved to {output_file_path}")
else:
    print("Invalid JSON data format. Expected a list of dictionaries.")


# import csv
# import re

# # Define file paths
# input_csv_file = "output.csv"
# output_csv_file = "output0bytes.csv"

# # Function to filter rows with usedSpace of 0 bytes
# def filter_used_space_zero(input_file, output_file):
#     with open(input_file, mode='r', newline='') as infile, open(output_file, mode='w', newline='') as outfile:
#         reader = csv.DictReader(infile)
#         fieldnames = reader.fieldnames

#         # Write the header to the output file
#         writer = csv.DictWriter(outfile, fieldnames=fieldnames)
#         writer.writeheader()

#         # Iterate through the rows and filter based on usedSpace
#         for row in reader:
#             used_space_str = row.get("usedSpace", "0 bytes")
#             numeric_value = float(re.search(r'\d+\.\d+|\d+', used_space_str).group())
#             if numeric_value == 0:
#                 writer.writerow(row)

# # Execute the filter function
# filter_used_space_zero(input_csv_file, output_csv_file)

# import csv

# # Define file paths
# input_csv_file = "input.csv"
# output_csv_file = "output.csv"

# # Function to filter rows with usedSpace not equal to 0 bytes
# def filter_used_space_nonzero(input_file, output_file):
#     with open(input_file, mode='r', newline='') as infile, open(output_file, mode='w', newline='') as outfile:
#         reader = csv.DictReader(infile)
#         fieldnames = reader.fieldnames

#         # Write the header to the output file
#         writer = csv.DictWriter(outfile, fieldnames=fieldnames)
#         writer.writeheader()

#         # Iterate through the rows and filter based on usedSpace
#         for row in reader:
#             used_space = int(row.get("usedSpace", 0))
#             if used_space != 0:
#                 writer.writerow(row)

# # Execute the filter function
# filter_used_space_nonzero(input_csv_file, output_csv_file)

# import csv
# import re

# # Define file path
# csv_file_path = "input.csv"

# # Function to filter and remove rows with usedSpace equal to 0 bytes
# def remove_used_space_zero(input_file):
#     # Create a temporary file to write the filtered data
#     temp_file_path = "temp.csv"

#     with open(input_file, mode='r', newline='') as infile, open(temp_file_path, mode='w', newline='') as outfile:
#         reader = csv.DictReader(infile)
#         fieldnames = reader.fieldnames

#         # Write the header to the output file
#         writer = csv.DictWriter(outfile, fieldnames=fieldnames)
#         writer.writeheader()

#         # Iterate through the rows and filter based on usedSpace
#         for row in reader:
#             used_space_str = row.get("usedSpace", "0 bytes")
#             numeric_value = float(re.search(r'\d+\.\d+|\d+', used_space_str).group())
#             if numeric_value != 0:
#                 writer.writerow(row)

#     # Replace the original file with the temporary file
#     import shutil
#     shutil.move(temp_file_path, input_file)

# # Execute the filter function
# remove_used_space_zero(csv_file_path)
