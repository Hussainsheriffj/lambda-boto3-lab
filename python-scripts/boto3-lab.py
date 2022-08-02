from logging import Filter
from turtle import st
import boto3
import json

# client = boto3.client('s3') variable name can be anything
s3_client = boto3.client('s3')
ec2_client = boto3.client('ec2')

#list bucket function
response = s3_client.list_buckets()

# print(response["Buckets"])
#to print in json format

# print(json.dumps(response, default=str))

#list all buckets from response
# for buc in response["Buckets"]:
#     print(buc["Name"])

#list all instance
response = ec2_client.describe_instances(
    Filters = [
        {
            'Name': 'instance-state-name',
            # 'Values': ['stopped']
            'Values': ['running'] #to see all running instanes
        }
    ]
)
# print(json.dumps(response, default=str))


# for instance in response["Reservations"][0]["Instances"]:
#     # print(instance["InstanceId"])
#     # print(f"Instance Id: {instance['InstanceId']} - State: {instance['State']}") #created a similar line below
#         print(f"Instance Id: {instance['InstanceId']} - State: {instance['State']['Name']}")

#to see all the instance state we need to use two for loops
for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:
        print(f"Instance Id: {instance['InstanceId']} - State: {instance['State']}")


    #commenting below to check the instance state
    # instanceStateResponse = ec2_client.describe_instance_status(
    #     InstanceIds=[instance['InstanceId']]
    # )
    # print(json.dumps(instanceStateResponse, default=str))
    # print(f"Instance Id: {instance['InstanceId']} - State: {instance['State']}")   #f method to print instance ID

