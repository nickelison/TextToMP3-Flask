import boto3
import os
import secrets
from PIL import Image, ImageOps
from flask import current_app, url_for, render_template
#import pyheif


def save_profile_picture(form_img):
    """
    # Issue installing pyheif package; only allowing jpg/png for now
    if form_img.filename.split(".")[-1].lower() == "heic":
        f_ext = ".JPG"
        heif_file = pyheif.read(form_img)
        img = Image.frombytes(heif_file.mode, heif_file.size, heif_file.data, "raw", heif_file.mode, heif_file.stride)
    else:
        img = Image.open(form_img)
        img = ImageOps.exif_transpose(img)
        _, f_ext = os.path.splitext(form_img.filename)
    """
    img = Image.open(form_img)
    img = ImageOps.exif_transpose(img)
    _, f_ext = os.path.splitext(form_img.filename)

    # Determine image mimetype by image's file extension.
    # The image mimetype is needed when uploading to S3 to prevent image
    # from automatically being downloaded when opening in new tab.

    if f_ext.replace('.', '') in ['jpeg', 'jpg']:
        mimetype = 'image/jpeg'
    else:
        mimetype = 'image/png'

    # create new filename
    random_hex = secrets.token_hex(8)
    img_fn = random_hex + f_ext
    img_dir = os.path.join(current_app.root_path, "static/img/avatars")
    if not os.path.exists(img_dir):
        os.makedirs(img_dir)
    img_path = img_dir + img_fn

    # resize
    basewidth = 250
    wpercent = (basewidth / float(img.size[0]))
    hsize = int((float(img.size[1]) * float(wpercent)))
    img = img.resize((basewidth, hsize), Image.LANCZOS)

    # save locally
    img.save(img_path)  # will be lost with container

    # save to s3 bucket
    s3 = boto3.client(
        's3',
        aws_access_key_id=current_app.config['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key=current_app.config['AWS_SECRET_ACCESS_KEY']
    )

    s3.upload_file(
        img_path,
        'cloud-project-demo-app',
        'avatars/' + img_fn,
        ExtraArgs={
            'ContentType': mimetype
        }
    )

    return img_fn


"""
def get_presigned_file_url(filename):
    # https://stackoverflow.com/questions/52342974/serve-static-files-in-flask-from-private-aws-s3-bucket
    resource = 'avatars/' + filename

    s3 = boto3.client('s3',
                      aws_access_key_id=current_app.config['AWS_ACCESS_KEY_ID'],
                      aws_secret_access_key=current_app.config['AWS_SECRET_ACCESS_KEY'],
                      region_name='us-east-1')

    url = s3.generate_presigned_url('get_object',
                                    Params={'Bucket': 'cloud-project-demo-app',
                                            'Key': resource},
                                    ExpiresIn=100)

    return url
"""
