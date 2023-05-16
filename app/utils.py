import json
import boto3
from botocore.exceptions import ClientError
from flask import current_app


def get_secret(secret_name, region_name='us-east-1'):
    """ Gets a key/value secret from Secrets Manager and returns it as a
        JSON object.
    """
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    # Decrypts secret using the associated KMS key.
    secret = get_secret_value_response['SecretString']

    # Return secret object
    return json.loads(secret)


def get_plaintext_secret(secret_name, region_name='us-east-1'):
    """ Get a plaintext secret from Secrets Manager and returns the value as
        a string.
    """
    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    # Decrypts secret using the associated KMS key.
    secret = get_secret_value_response['SecretString']

    # Return secret value string
    return secret


def get_presigned_s3_file_url(s3_key):
    """ Generate a presigned S3 file URL given a key.

        Return the URL as a string.

        See: https://stackoverflow.com/questions/52342974/serve-static-files-in-flask-from-private-aws-s3-bucket
    """
    s3 = boto3.client('s3',
                      region_name=current_app.config['AWS_REGION'],
                      aws_access_key_id=current_app.config['AWS_ACCESS_KEY_ID'],
                      aws_secret_access_key=current_app.config['AWS_SECRET_ACCESS_KEY'])

    url = s3.generate_presigned_url('get_object',
                                    Params={
                                        'Bucket': current_app.config['S3_BUCKET'],
                                        'Key': s3_key
                                    },
                                    ExpiresIn=100)

    return url


def lambda_client():
    client = boto3.client('lambda',
                          region_name=current_app.config['AWS_REGION'],
                          aws_access_key_id=current_app.config['AWS_ACCESS_KEY_ID'],
                          aws_secret_access_key=current_app.config['AWS_SECRET_ACCESS_KEY'])
    return client


def delete_from_s3(s3_key):
    """ Remove an object from an S3 bucket given a key.
    """
    s3 = boto3.client('s3',
                      region_name=current_app.config['AWS_REGION'],
                      aws_access_key_id=current_app.config['AWS_ACCESS_KEY_ID'],
                      aws_secret_access_key=current_app.config['AWS_SECRET_ACCESS_KEY'])

    response = s3.delete_object(Bucket=current_app.config['S3_BUCKET'], Key=s3_key)
    return response
