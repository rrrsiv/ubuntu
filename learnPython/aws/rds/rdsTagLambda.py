
import json
import boto3
import re
import uuid
import time
import random
import logging
import ast
from datetime import datetime


logger = logging.getLogger()
logger.setLevel(logging.INFO)


#bucketname = 'anupam-tags-876724398547'
# bucketname = 'anupam-tags--876724398547' # For the nagarro account ending with 8547
bucketname = 'anupam-test2' # For the nagarro account ending with 4780
ec2 = boto3.resource('ec2')
client = boto3.client('ec2')
s3 = boto3.resource('s3')
my_bucket = s3.Bucket(bucketname)
rds = boto3.client('rds')

env = []
proj = []


def lambda_handler(event, context):
    for object_summary in my_bucket.objects.filter(Prefix="Tags/config.ini"):
        contents = object_summary.get()['Body'].read().decode(encoding="utf-8",errors="ignore")
        for line in contents.splitlines():
            key,value = (line.strip().split('='))
            if key == 'Environment':
                env = ast.literal_eval(value)
            elif key == 'Project':
                proj = ast.literal_eval(value)
        env = [x.lower() for x in env]
        proj = [x.lower() for x in proj]
        env = set (env)
        proj = set (proj)
        print(env)
        print(proj)
    rds_response = rds.describe_db_instances()
    creating = [i['DBInstanceIdentifier'] for i in rds_response['DBInstances'] if i['DBInstanceStatus'] == 'creating']
    print(creating)
    length = len(creating)
    if length > 0:
        for id in range(length):
            try:
                dbarn = rds_response['DBInstances'][id]['DBInstanceArn']
                dbiden = rds_response['DBInstances'][id]['DBInstanceIdentifier']
                tagresponse = rds.list_tags_for_resource(ResourceName=dbarn)
                print(tagresponse)
                envtagpresent = 0
                projtagpresent = 0
                for tag in tagresponse["TagList"]:
                    if tag['Key'].lower() == 'owner':
                        receiver_email = tag["Value"]
                    elif tag['Key'].lower() == 'environment':
                        envtagvalue = tag["Value"]
                        print(envtagvalue)
                        envtagpresent = 1
                    elif tag['Key'].lower() == 'project':
                        projtagvalue = tag["Value"]
                        print(projtagvalue)
                        projtagpresent = 1
                    else:
                        print("Checking for Next entry")

                if envtagpresent == 1 and projtagpresent == 1:
                    if envtagvalue.lower() in env and projtagvalue.lower() in proj:
                        try:
                            print("Instance Creation is in progress")
                        except Exception as e:
                            print('tag value is either missing or not formatted correctly hence terminating the instance: '
                            'Instance ID: %s, Value: %s' % (instance['InstanceId'], tag['Value']))
                            print(e)
                            #rds.delete_db_instance(DBInstanceIdentifier=dbiden,SkipFinalSnapshot=True)
                            send_email(receiver_email)
                    else:
                        print("tag value is either missing or not formatted correctly hence terminating the instance")
                        #rds.delete_db_instance(DBInstanceIdentifier=dbiden,SkipFinalSnapshot=True)
                        send_email(receiver_email)
                else:
                    print("Tags are missing,hence terminating the instance please try with valid Tags Options")
                    print(dbiden)
                    #rds.delete_db_instance(DBInstanceIdentifier=dbiden,SkipFinalSnapshot=True)
                    send_email(receiver_email)
            except Exception as e:
                print(e)
    else:
        print("No instance in creation process")

def send_email(receiver_email):
    print("Send Email function")
    receiver_email = receiver_email
    print(receiver_email)
    import smtplib
    smtp_server = "smtp-mail.outlook.com"
    port = 587  # For starttls
    sender_email = 'devops.services@nagarro.com'
    password = 'ojooep981240!'
    message = """\
    Subject: AWS Alert - RDS Intance without Tags

    You are getting this email because you are running RDS instances without proper tags."""

    # Try to log in to server and send email
    server = smtplib.SMTP(smtp_server,port)
    print("SMTP connection done")
    server.starttls() # Secure the connection
    print("Secure connection established")
    server.login(sender_email, password)
    print("Sending email to %s",receiver_email)
    server.sendmail(sender_email, receiver_email, message)
    server.quit()
