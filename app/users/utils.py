import boto3
import os
import secrets
from PIL import Image, ImageOps
from flask import current_app, url_for, render_template

def save_profile_picture(form_img):
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