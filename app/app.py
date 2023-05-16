import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_bcrypt import Bcrypt
from flask_login import LoginManager
from dotenv import load_dotenv
from utils import get_secret

# Load environment variables from .env file
load_dotenv()

# Initialize the extensions
db = SQLAlchemy()
bcrypt = Bcrypt()
login_manager = LoginManager()

# Set login view and message category for Flask-Login
login_manager.login_view = 'users.login'
login_manager.login_message_category = 'info'

def create_app():
    """ Create the Flask app.
    """
    app = Flask(__name__)

    # Configure app
    app.config['AWS_ACCESS_KEY_ID'] = os.getenv('AWS_ACCESS_KEY_ID')
    app.config['AWS_SECRET_ACCESS_KEY'] = os.getenv('AWS_SECRET_ACCESS_KEY')
    app.config['AWS_REGION'] = os.getenv('AWS_DEFAULT_REGION')
    app.config['S3_BUCKET'] = os.getenv('S3_BUCKET')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    if os.getenv('FLASK_DEBUG'):  # If running locally
        app.config['SECRET_KEY'] = os.environ['FLASK_SECRET']
        app.config['SQLALCHEMY_DATABASE_URI'] = f"postgresql://{os.getenv('TEST_POSTGRES_USER')}:{os.getenv('TEST_POSTGRES_PW')}@{os.getenv('TEST_POSTGRES_HOST')}:5432/{os.getenv('TEST_POSTGRES_DB')}"
    else:  # If in production
        app.config['SECRET_KEY'] = get_secret('flask-demo-flask-secret', region_name='us-east-1')['FLASK_SECRET']
        db_config = get_secret('spotscool-db-creds', region_name='us-east-1')
        app.config['SQLALCHEMY_DATABASE_URI'] = f"postgresql://{db_config['POSTGRES_USER']}:{db_config['POSTGRES_PW']}@{db_config['POSTGRES_HOST']}:5432/{db_config['POSTGRES_DB']}"

    # Initialize the extensions with the app
    db.init_app(app)
    migrate = Migrate(app, db, compare_type=True)
    bcrypt.init_app(app)
    login_manager.init_app(app)

    # Register blueprints
    from main import bp as main_bp
    from users.routes import users
    app.register_blueprint(main_bp)
    app.register_blueprint(users)
    
    return app

# Import models after the app and db have been created
# to avoid circular imports
import models

app = create_app()

if __name__ == '__main__':
    app.run(host='0.0.0.0')