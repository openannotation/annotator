from flask import Flask
app = Flask(__name__)

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:dba@localhost/AnnotatorDBMI'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS']=False
app.secret_key = 'dbmi-annotator-test'

from models import db
db.init_app(app)

from app import *


