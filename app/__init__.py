from flask import Flask
from flaskext.mysql import MySQL

# Config Values
USERNAME = 'admin'
PASSWORD = 'password123'

# SECRET_KEY is needed for session security, the flash() method in this case stores the message in a session
SECRET_KEY = 'Sup3r$3cretkey'
UPLOAD_FOLDER = "/app/static/uploads"

# App configurations
app = Flask(__name__)
app.config.from_object(__name__)

mysql = MySQL()
 
# MySQL configurations
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = ''
app.config['MYSQL_DATABASE_DB'] = 'hospital'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)

from app import views
