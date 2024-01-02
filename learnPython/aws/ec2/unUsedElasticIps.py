import boto3
from datetime import datetime, timedelta

def lambda_handler(event, context):
    # Initialize the SNS client for sending notifications
    sns_client = boto3.client('sns')
    
    # Get all AWS regions
    ec2_client_global = boto3.client('ec2', region_name='us-east-1')
    regions = [region['RegionName'] for region in ec2_client_global.describe_regions()['Regions']]

    # Iterate through each region
    for region in regions:
        # Initialize the EC2 client for the current region
        ec2_client = boto3.client('ec2', region_name=region)

        # Get all Elastic IP addresses
        elastic_ips = ec2_client.describe_addresses()['Addresses']

        # Get the list of instances with their launch times
        instances = ec2_client.describe_instances()
        instance_launch_times = {}

        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                launch_time = instance['LaunchTime']
                instance_launch_times[instance_id] = launch_time

        # Calculate the threshold time for considering an Elastic IP as unused
        threshold_time = datetime.now() - timedelta(days=7)  # Adjust the threshold as needed

        # Identify unused Elastic IP addresses
        unused_elastic_ips = []

        for elastic_ip in elastic_ips:
            allocation_time = elastic_ip.get('AllocationTime', None)
            instance_id = elastic_ip.get('InstanceId', None)

            if not instance_id or (allocation_time and instance_launch_times.get(instance_id, None) < threshold_time):
                unused_elastic_ips.append(elastic_ip)

        # If there are unused Elastic IPs, send a notification
        if unused_elastic_ips:
            # Customize the SNS topic and message based on your preferences
            sns_topic_arn = 'arn:aws:sns:ap-south-1:729093267362:test'
            notification_message = f"Unused Elastic IP addresses in {region} region:\n" + "\n".join([ip['PublicIp'] for ip in unused_elastic_ips])

            sns_client.publish(
                TopicArn=sns_topic_arn,
                Message=notification_message,
                Subject=f"Unused Elastic IPs in {region}"
            )
        else:
            print(f"No unused Elastic IP addresses in {region} region.")



