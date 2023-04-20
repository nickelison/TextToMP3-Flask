import os
from flask import Blueprint, flash, current_app, render_template, url_for, redirect, request, jsonify
from main import bp
from app import db
from main.forms import NameForm, UploadForm, DeleteMP3Form
from models import User, Name, MP3File
from flask_login import current_user, login_required
from utils import lambda_client
import json


@bp.route("/")
def index():
    if current_user.is_authenticated:
        return render_template('home.html', title='Convert Text to MP3')
    else:
        return render_template('index.html', title='Convert Text to MP3')
    # return f"Hello World!!!"


@bp.route("/test", methods=['GET', 'POST'])
def test():
    form = NameForm()

    if form.validate_on_submit():
        name = Name(fname=form.fname.data,
                    lname=form.lname.data)

        db.session.add(name)
        db.session.commit()

        flash('Name added.', 'success')

        return redirect(url_for('main.test'))

    names = Name.query.all()

    return render_template('test.html', form=form, names=names)


@bp.route('/delete/', methods=['POST'])
def delete():
    req = request.get_json()
    name = Name.query.filter_by(id=req['name_id']).first()

    if not name:
        return {'status': 'error: no name for id'}

    db.session.delete(name)
    db.session.commit()

    return {'status': 'success'}


@bp.route('/new/', methods=['GET', 'POST'])
def new():
    form = UploadForm()

    import logging
    logging.basicConfig(level=logging.INFO)

    if form.validate_on_submit():
        text = form.text.data
        user_file_name = form.title.data
        if user_file_name[-4:].lower() != '.mp3':
            user_file_name += '.mp3'

        payload = {'text': text}
        client = lambda_client()

        # call Lambda function
        response = client.invoke(FunctionName='arn:aws:lambda:us-east-1:431608762876:function:testFunction',
                                 InvocationType='RequestResponse',
                                 Payload=json.dumps(payload))

        response_json = json.loads(response['Payload'].read())
        logging.info(response_json)
        logging.info('fuck')

        if response_json['statusCode'] == 200:
            filename = response_json['body']['filename']
            s3_key = f'mp3/{filename}'

            # create db entry for mp3 file
            mp3_file = MP3File(user_file_name=user_file_name,
                               file_name=filename,
                               s3_key=s3_key,
                               user_id=current_user.id)
            db.session.add(mp3_file)
            db.session.commit()

            # redirect to uploads page
            return redirect(url_for('main.files'))
        else:
            # error
            pass

        # redirect to uploads page
        return redirect(url_for('main.index'))
    else:
        return render_template('upload.html', title='Create New MP3', form=form)


@bp.route('/files/', methods=['GET'])
def files():
    user = User.query.get(current_user.id)
    form = DeleteMP3Form()
    mp3_files = user.mp3_files
    return render_template('uploads.html', title='Your MP3 Files', mp3_files=mp3_files, form=form)


@bp.route('/delete/<file_id>', methods=['POST'])
def delete_file(file_id):
    mp3_file = MP3File.query.filter(MP3File.id == file_id).first()
    db.session.delete(mp3_file)
    db.session.commit()
    return {'status': 'success'}


@bp.route('/delete_mp3', methods=['POST'])
def delete_mp3():
    form = DeleteMP3Form()
    if form.validate_on_submit():
        mp3_id = form.mp3_id.data
        mp3 = MP3File.query.get_or_404(mp3_id)

        # Make sure current user is file owner
        if mp3.user_id != current_user.id:
            abort(403)

        # Remove the file from the S3 bucket
        mp3.delete_from_s3()

        # Remove the file from the database
        db.session.delete(mp3)
        db.session.commit()

        flash('MP3 file has been deleted.', 'success')
    else:
        flash('Error deleting MP3 file.', 'danger')

    return redirect(url_for('main.files'))
