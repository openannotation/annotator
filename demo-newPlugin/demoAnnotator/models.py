from flask.ext.sqlalchemy import SQLAlchemy
from werkzeug import generate_password_hash, check_password_hash

db = SQLAlchemy()

from models import db


class User(db.Model):
	__tablename__ = 'user'
	id = db.Column(db.Integer, primary_key = True)
	uid = db.Column(db.String(54))
	username = db.Column(db.String(30))
	admin = db.Column(db.Boolean)
	manager = db.Column(db.Boolean)
	email = db.Column(db.String(100), unique=True)
	status = db.Column(db.Integer)
	last_login_date = db.Column(db.DateTime)
	registered_date = db.Column(db.DateTime)
	activation_id = db.Column(db.Integer)
	password = db.Column(db.String(256))
  
	def __init__(self, uid, username, admin, manager, email, status, last_login_date, registered_date, activation_id, password):
		self.uid = uid
		self.username = username.title()
		self.admin = admin
		self.manager = manager
		self.email = email.lower()
		self.status = status
		self.last_login_date = last_login_date
		self.registered_date = registered_date
		self.activation_id = activation_id
		self.set_password(password)
    
	def set_password(self, password):
		self.password = generate_password_hash(password)
    
	def check_password(self, password):
		return check_password_hash(self.password, password)
	
class Activation(db.Model):
	__tablename__ = 'activation'
	id = db.Column(db.Integer, primary_key = True, autoincrement=True)
	code = db.Column(db.String(30))
	created_by = db.Column(db.String(30))
	valid_until = db.Column(db.DateTime)

	def __init__(self, code, created_by, valid_until):
		self.code = code.title()
		self.created_by = created_by
		self.valid_until = valid_until
	
