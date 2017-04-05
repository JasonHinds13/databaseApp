from flask_wtf import FlaskForm
from wtforms import StringField,TextAreaField,PasswordField,DateField
from wtforms.validators import InputRequired

class RegForm(FlaskForm):
    name = StringField('Name', validators=[InputRequired()])
    email = StringField('E-mail', validators=[InputRequired()])
    subject = StringField('Subject', validators=[InputRequired()])
    message = TextAreaField('Message', validators=[InputRequired()])
    
class MedForm(FlaskForm):
    emp_id = StringField('Employee ID', validators=[InputRequired()]),
    p_id = StringField('Patient ID', validators=[InputRequired()]),
    disease_id = StringField('Disease ID', validators=[InputRequired()]),
    ddate = DateField('Date', format='%Y-%m-%d',validators=[InputRequired()])
    
class LoginForm(FlaskForm):
    username = StringField('Username', validators=[InputRequired()])
    password = PasswordField('Password', validators=[InputRequired()])

# Form Classes to submit data for queries

# query (a)
class DiagnosisForm(FlaskForm):
    diagnosis = StringField('Diagnosis', validators=[InputRequired()])
    startdate = DateField('Start Date', format='%Y/%m/%d',validators=[InputRequired()])
    enddate = DateField('End Date', format='%Y-%m-%d',validators=[InputRequired()])
    
# Can be used for queries (b) and (d)
class PatientForm(FlaskForm):
    first_name = StringField('First Name', validators=[InputRequired()])
    last_name = StringField('Last Name', validators=[InputRequired()])

# query (e)
class GetNursesForm(FlaskForm):
    first_name = StringField('First Name', validators=[InputRequired()])
    last_name = StringField('Last Name', validators=[InputRequired()])
    date = DateField('Date', format='%Y-%m-%d',validators=[InputRequired()])