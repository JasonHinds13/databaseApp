from flask_wtf import FlaskForm
from wtforms import StringField,TextAreaField,PasswordField
from wtforms.validators import InputRequired

class RegForm(FlaskForm):
    first_name = StringField('First Name', validators=[InputRequired()])
    last_name = StringField('Last Name', validators=[InputRequired()])
    phone_num = StringField('Phone Number', validators=[InputRequired()])
    address = StringField('Address', validators=[InputRequired()])
    sex = StringField('Sex', validators=[InputRequired()])
    dob = StringField('Date of Birth', validators=[InputRequired()])
    
class MedForm(FlaskForm):
    emp_id = StringField('Employee ID', validators=[InputRequired()]),
    p_id = StringField('Patient ID', validators=[InputRequired()]),
    disease_id = StringField('Disease ID', validators=[InputRequired()]),
    ddate = StringField('Date',validators=[InputRequired()])
    
class LoginForm(FlaskForm):
    username = StringField('Username', validators=[InputRequired()])
    password = PasswordField('Password', validators=[InputRequired()])

# Form Classes to submit data for queries

# query (a)
class DiagnosisForm(FlaskForm):
    diagnosis = StringField('Diagnosis', validators=[InputRequired()])
    startdate = StringField('Start Date', validators=[InputRequired()])
    enddate = StringField('End Date', validators=[InputRequired()])
    
# Can be used for queries (b) and (d)
class PatientForm(FlaskForm):
    first_name = StringField('First Name', validators=[InputRequired()])
    last_name = StringField('Last Name', validators=[InputRequired()])

# query (e)
class GetNursesForm(FlaskForm):
    first_name = StringField('First Name', validators=[InputRequired()])
    last_name = StringField('Last Name', validators=[InputRequired()])
    date = StringField('Date',validators=[InputRequired()])