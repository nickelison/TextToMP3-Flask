import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_bcrypt import Bcrypt
from flask_login import LoginManager
from dotenv import load_dotenv
import boto3
import base64
from botocore.exceptions import ClientError
import json

load_dotenv()
db = SQLAlchemy()
bcrypt = Bcrypt()

# initialize login manager
login_manager = LoginManager()
login_manager.login_view = 'users.login'
login_manager.login_message_category = 'info'


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


def create_app():
    app = Flask(__name__)
    if os.environ['FLASK_DEBUG']:
        app.config.from_mapping(
            SECRET_KEY=os.environ['FLASK_SECRET'],
            AWS_ACCESS_KEY_ID=os.environ['AWS_ACCESS_KEY_ID'],
            AWS_SECRET_ACCESS_KEY=os.environ['AWS_SECRET_ACCESS_KEY'],
            AWS_REGION=os.environ['AWS_DEFAULT_REGION'],
            S3_BUCKET=os.environ['S3_BUCKET'],
            SQLALCHEMY_DATABASE_URI=f"postgresql://{os.environ['TEST_POSTGRES_USER']}:{os.environ['TEST_POSTGRES_PW']}@{os.environ['TEST_POSTGRES_HOST']}:5432/{os.environ['TEST_POSTGRES_DB']}",
            SQLALCHEMY_TRACK_MODIFICATIONS=False)
    else:
        db_config = get_secret('flask-demo-db-creds', region_name='us-east-1')
        app.config.from_mapping(
            SECRET_KEY=get_secret('flask-demo-flask-secret', region_name='us-east-1')['FLASK_SECRET'],
            AWS_ACCESS_KEY_ID=os.environ['AWS_ACCESS_KEY_ID'],
            AWS_REGION=os.environ['AWS_DEFAULT_REGION'],
            AWS_SECRET_ACCESS_KEY=os.environ['AWS_SECRET_ACCESS_KEY'],
            S3_BUCKET=os.environ['S3_BUCKET'],
            SQLALCHEMY_DATABASE_URI=f"postgresql://{db_config['POSTGRES_USER']}:{db_config['POSTGRES_PW']}@{db_config['POSTGRES_HOST']}:5432/{db_config['POSTGRES_DB']}",
            SQLALCHEMY_TRACK_MODIFICATIONS=False)

    db.init_app(app)
    migrate = Migrate(app, db, compare_type=True)

    bcrypt.init_app(app)
    login_manager.init_app(app)

    # register blueprints
    from main import bp as main_bp
    from users.routes import users

    app.register_blueprint(main_bp)
    app.register_blueprint(users)

    """
    with app.app_context():
        db.create_all()
    """

    return app


import models

app = create_app()


"""
def create_app():
    app = Flask(__name__)
    return app


app = create_app()


@app.route('/')
def hello_world() -> str:
    return 'Hello worlddd'
"""

if __name__ == '__main__':
    app.run(host='0.0.0.0')
