import json
import boto3
import base64
from botocore.signers import CloudFrontSigner
from botocore.exceptions import ClientError
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives import serialization
from datetime import datetime, timedelta
from flask import current_app


def get_secret(secret_name, region_name='us-east-1'):
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

    # Your code goes here.
    return json.loads(secret)


def get_plaintext_secret(secret_name, region_name='us-east-1'):
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

    return secret


def rsa_signer(message):
    private_key_str = get_plaintext_secret('cloudfront_private_key', 'us-east-1')

    import logging
    logging.basicConfig(level=logging.INFO)
    logging.info(f"private key str: {private_key_str}")

    private_key = serialization.load_pem_private_key(
        private_key_str.encode(),
        password=None,
        backend=default_backend(),
    )

    signature = private_key.sign(
        message,
        padding.PKCS1v15(),
        hashes.SHA1()
    )

    return base64.b64encode(signature)


def get_presigned_cloudfront_file_url(filename):
    resource = 'avatars/' + filename
    cf_domain = "d2tqckyhayhkf8.cloudfront.net"
    cf_key_pair_id = 'APKAWI7PDCH6C4YGJRM4'
    cf_url = f'https://{cf_domain}/{resource}'

    cf_signer = CloudFrontSigner(cf_key_pair_id, rsa_signer)
    expires = datetime.utcnow() + timedelta(seconds=100)
    url = cf_signer.generate_presigned_url(cf_url, date_less_than=expires)

    return url


def get_presigned_s3_file_url(s3_key):
    # https://stackoverflow.com/questions/52342974/serve-static-files-in-flask-from-private-aws-s3-bucket
    #resource = 'avatars/' + filename
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
    s3 = boto3.client('s3',
                      region_name=current_app.config['AWS_REGION'],
                      aws_access_key_id=current_app.config['AWS_ACCESS_KEY_ID'],
                      aws_secret_access_key=current_app.config['AWS_SECRET_ACCESS_KEY'])

    response = s3.delete_object(Bucket=current_app.config['S3_BUCKET'], Key=s3_key)
    return response
