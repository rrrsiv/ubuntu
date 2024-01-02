import boto3

region_name = 'ap-south-1'


# Initialize Boto3 client for CloudTrail
cloudtrail_client = boto3.client('cloudtrail', region_name=region_name)


response = cloudtrail_client.lookup_events(
    LookupAttributes=[
        {
            'AttributeKey': 'EventName',
            'AttributeValue': 'RunInstances'
        },
        {
            'AttributeKey': 'ResourceName',
            'AttributeValue': 'i-0ee5fbcc95f850903'
        },
    ],

    MaxResults=1,

)
print(response)
# creators = set()
# for event in response.get('Events', []):
#     username = event.get('Username', 'Unknown')

#     creators.add((username))
# print(creators)