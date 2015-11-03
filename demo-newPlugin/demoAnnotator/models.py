from flask.ext.sqlalchemy import SQLAlchemy
from werkzeug import generate_password_hash, check_password_hash

db = SQLAlchemy()

from models import db


class User(db.Model):
  __tablename__ = 'user'
  user_id = db.Column(db.Integer, primary_key = True)
  name = db.Column(db.String(45))
  email = db.Column(db.String(100), unique=True)
  pwdhash = db.Column(db.String(54))
   
  def __init__(self, name, email, password):
    self.name = name.title()
    self.email = email.lower()
    self.set_password(password)
     
  def set_password(self, password):
    self.pwdhash = generate_password_hash(password)
   
  def check_password(self, password):
    return check_password_hash(self.pwdhash, password)
