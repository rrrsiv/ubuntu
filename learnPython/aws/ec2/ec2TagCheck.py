import json
import boto3
import re
import uuid
import random
import logging
import ast
from datetime import datetime
import time


logger = logging.getLogger()
logger.setLevel(logging.INFO)



bucketname = 'ec2tagcheckbucket' # update s3 bucket name
ec2 = boto3.resource('ec2')
client = boto3.client('ec2')
s3 = boto3.resource('s3')
my_bucket = s3.Bucket(bucketname)

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
    instances_ = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['pending','running']}])
    for instance in instances_:
        print(instance.state, instance.id)

    time.sleep(5)
    instid=[]
    print(instances_)
    instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['pending','running']}])
    for instance in instances:
        try:
            envtagpresent = 0
            projtagpresent = 0
            instid = [instance.id]
            instance_tags = instance.tags
            print("Instance Id: ",instid)
            print("Instance: ", instance)
            print(type(instid))
            print("Instance tags: " , instance_tags)

            if instance_tags is not None:
                for tag in instance_tags:
                    print("Working on Tag: {}".format(tag))
                    if projtagpresent == 0:
                        projtagpresent,projtagvalue = validate_projecttag(tag)
                        print(projtagvalue)

                    if envtagpresent == 0:
                        envtagpresent,envtagvalue = validate_environmenttag(tag)
                        print(envtagvalue)

            if envtagpresent == 1 and projtagpresent == 1:
                if envtagvalue.lower() in env and projtagvalue.lower() in proj:
                    try:
                        print("Instance Creation is in progress")
                    except Exception as e:
                        print('tag value is either missing or not formatted correctly hence terminating the instance: '
                        'Instance ID: %s, Value: %s' % (instance['InstanceId'], tag['Value']))
                        print(e)
                        ec2.instances.filter(InstanceIds=instid).terminate()
                else:
                    print("tag value is either missing or not formatted correctly hence terminating the instance")
                    ec2.instances.filter(InstanceIds=instid).terminate()
            else:
                print("Tags are missing,hence terminating the instance please try with valid Tags Options")
                print(instid)
                ec2.instances.filter(InstanceIds=instid).terminate()
        except Exception as e:
            print(e)
    return {
        'statusCode': 200,
        'body': 'Lambda execution completed successfully'
    }
def validate_environmenttag(tag):
    envtagpresent = 0
    envtagvalue = 'None'
    if tag['Key'].lower() == 'environment':
        envtagvalue = tag["Value"]
        print(envtagvalue)
        envtagpresent = 1
    return envtagpresent,envtagvalue

def validate_projecttag(tag):
    projtagpresent = 0
    projtagvalue = 'None'
    if tag['Key'].lower() == 'project':
        projtagvalue = tag["Value"]
        print(projtagvalue)
        projtagpresent = 1
    return projtagpresent,projtagvalue
