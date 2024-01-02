import boto3
from datetime import datetime, timedelta

def lambda_handler(event, context):
    # Set the AWS region
    region = 'us-east-1'
   # Initialize the SNS client
    sns_client = boto3.client('sns')

    # Initialize the EC2 client
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
        allocation_time = elastic_ip['AllocationTime']
        instance_id = elastic_ip.get('InstanceId', None)

        if not instance_id or instance_launch_times.get(instance_id, None) < threshold_time:
            unused_elastic_ips.append(elastic_ip)

    # If there are unused Elastic IPs, send a notification
    if unused_elastic_ips:
        # Replace the following lines with your notification logic (e.g., sending an email, using SNS, etc.)
        notification_message = "Unused Elastic IP addresses:\n" + "\n".join([ip['PublicIp'] for ip in unused_elastic_ips])
        sns_topic_arn = 'arn:aws:sns:ap-south-1:729093267362:test'
        notification_message = f"Unused Elastic IP addresses in {region} region:\n" + "\n".join([ip['PublicIp'] for ip in unused_elastic_ips])

        sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=notification_message,
            Subject=f"Unused Elastic IPs in {region}"
        )
    else:
        print(f"No unused Elastic IP addresses in {region} region.")

    # You can also add additional cleanup logic if needed (e.g., releasing the unused Elastic IPs)
    # Uncomment the following lines to release the unused Elastic IPs
    # for elastic_ip in unused_elastic_ips:
    #     ec2_client.release_address(AllocationId=elastic_ip['AllocationId'])

# Uncomment the following line to test the function locally
# lambda_handler({}, {})
