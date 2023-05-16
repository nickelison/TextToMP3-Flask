from app import db, login_manager
from datetime import datetime
from flask import current_app
from flask_login import UserMixin
from utils import delete_from_s3
from utils import get_presigned_s3_file_url

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(20), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(60), nullable=False)
    profile_picture = db.Column(db.String(40), nullable=False, default="default.jpg")
    mp3_files = db.relationship('MP3File', backref='user', lazy=True)

    def get_profile_picture_url(self):
        return get_presigned_s3_file_url("avatars/" + self.profile_picture)

    def remove(self):
        db.session.delete(self)

class MP3File(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    user_file_name = db.Column(db.String(255), nullable=False)
    file_name = db.Column(db.String(255), nullable=False)
    s3_key = db.Column(db.String(255), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)

    def get_mp3_url(self):
        return get_presigned_s3_file_url('mp3/' + self.file_name)

    def delete_from_s3(self):
        delete_from_s3(self.s3_key)