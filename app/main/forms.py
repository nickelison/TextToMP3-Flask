from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, TextAreaField, IntegerField
from wtforms.validators import DataRequired, Length, ValidationError, Regexp

class UploadForm(FlaskForm):
    title = StringField('File Name', validators=[DataRequired(), Regexp(r'^[\w.@+-]+$'), Length(min=4, max=128)], render_kw={'placeholder': 'audio.mp3'})
    text = TextAreaField('Text (maxiumum of 4096 characters)', validators=[DataRequired(), Length(min=1, max=4096)])
    submit = SubmitField('Create MP3')

class DeleteMP3Form(FlaskForm):
    mp3_id = IntegerField('MP3 ID', validators=[DataRequired()])
    submit = SubmitField('Delete')
