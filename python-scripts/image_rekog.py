import boto3
import logging
import os

#importing metadata
import os
metadata_table = os.environ["METADATA_TABLE"]


#added this to find our the no of faces(for pascal it was not working so added for me working without these strange)
# import logging

# logger = logging.getLogger()
# logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    client = boto3.client("rekognition")
    #making python to store the details in dynamoDB
    dynamodb_resource = boto3.resource("dynamodb")

    for record in event["Records"]:
        bucket_name = record["s3"]["bucket"]["name"]
        image_obj = record["s3"]["object"]["key"]

    print(bucket_name)
    print(image_obj)

    #the details we want to see in lambda output
    # print(bucket_name)
    # print(image_obj)

    #to detect face
    response = client.detect_faces(Image={'S3Object':{'Bucket':bucket_name,'Name':image_obj}},Attributes=['ALL'])

    #to find faces
    faces = response["FaceDetails"]

    #to find eyeglases
    #eyeglases = response["FaceDetails"].["Eyeglasses"]

    #to find no of faces
    no_of_faces = len(faces)
    # no_of_eyeglases = len(eyeglases)
    
    print(f"Number of faces detected: {no_of_faces}")
    print(f"Number of faces with eyeglases detected: {faces['Eyeglasses']}")

    #to find no of male and female in the picture

    male = 0
    female = 0
    for face in faces:
        if face["Gender"]["Value"] == "Male":
            male +=1
        elif face["Gender"]["Value"] == "Female":
            female +=1


    #creating a variable
    metadata = {
        "filename": image_obj,
        "no_of_faces": no_of_faces,
        "male": male,
        "female": female

    }

    #creating table
    table = dynamodb_resource.Table(metadata_table)
    table.put_item (Item=metadata)


    print(f"Number of male detected: {male}")
    print(f"Number of female detected: {female}")


    #find the following items from the image and store it in dynamodb 
    #eyeglases
    #sunglases
    #beard
    #mustache