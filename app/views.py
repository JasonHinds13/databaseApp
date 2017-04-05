import os
from app import app, mysql
from flask import render_template, request, redirect, url_for, flash, session, abort, jsonify
from werkzeug.utils import secure_filename
from forms import *

@app.route('/')
def home():
    """Render website's home page."""
    return render_template('home.html')


@app.route('/about/')
def about():
    """Render the website's about page."""
    return render_template('about.html', name="Mary Jane")

@app.route('/addpatient', methods=['POST', 'GET'])
def addpatient():
    form = RegForm()
    
    if request.method == "POST":
        conn = mysql.connect()
        cursor = conn.cursor()
        
        stmt = "insert into patient(first_name,last_name,phone_num,address,sex,dob) values('{}','{}','{}','{}','{}','{}')".format(form.first_name.data,form.last_name.data,form.phone_num.data,form.address.data,form.sex.data,form.dob.data)
        
        cursor.execute(stmt)
        cursor.commit()

        cursor.close()
        conn.close()
        return "Entered!"
        
    return render_template('addPatient.html', form=form)
    
@app.route('/listpatients', methods=['GET'])
def listpatients():
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.execute('select  * from patient')
    d = cursor.fetchall()
    cursor.close()
    conn.close()
    return str(res)
    
@app.route('/listdocs', methods=['GET'])
def listdocs():
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.execute('select  * from doctor')
    d = cursor.fetchall()
    cursor.close()
    conn.close()
    return str(res)
    
@app.route('/listnurses', methods=['GET'])
def listnurses():
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.execute('select  * from nurse')
    d = cursor.fetchall()
    cursor.close()
    conn.close()
    return str(res)
    
@app.route('/meddata')
def medical():
    form = MedForm()
    
    if request.method == "POST":
        if form.validate_on_submit():
            conn = mysql.connect()
            cursor = conn.cursor()
            
            stmt = "insert into diagnosis(emp_id,p_id,disease_id,ddate) values('{}',{},{},'{}')".format(form.emp_id,form.p_id,form.disease_id,form.ddate)
            cursor.execute(stmt)
            cursor.commit()
            
            cursor.close()
            conn.close()
    
    return render_template('meddata.html', form=form)

#Procedure a    
@app.route('/diagnosis', methods=["GET","POST"])
def diagnosis():
    form = DiagnosisForm()
    if request.method == "POST":
        if form.validate_on_submit():
            conn = mysql.connect()
            cursor = conn.cursor()
            
            stmt = "call getDiagnosisInRange('{}','{}','{}')".format(form.diagnosis.data,form.startdate.data,form.enddate.data)
            cursor.execute(stmt)
            res = cursor.fetchall()
            
            cursor.close()
            conn.close()
            
            return "<ul>" + "".join(["<li>" + item[0] + " " +item[1] + "</li>" for item in res]) + "</ul>"
        
    return render_template('diagnosis.html',form=form)
    
#Procedure b    
@app.route('/allergens', methods=["GET","POST"])
def allergens():
    form = PatientForm()
    if request.method == "POST":
        if form.validate_on_submit():
            conn = mysql.connect()
            cursor = conn.cursor()
            
            stmt = "call getAllergies('{}','{}')".format(form.first_name.data,form.last_name.data)
            cursor.execute(stmt)
            res = cursor.fetchall()
            
            cursor.close()
            conn.close()
            
            return form.first_name.data + " " + form.last_name.data + " is allergic to: " + str([item[0] for item in res])
        
    return render_template('allergens.html',form=form)

#Procedure c  
@app.route('/algmed', methods=["GET"])
def algmed():
    conn = mysql.connect()
    cursor = conn.cursor()
            
    stmt = "call mostAllergic"
    cursor.execute(stmt)
    res = cursor.fetchall()
            
    cursor.close()
    conn.close()
            
    return "Most people are allergic to: " + "<br/><ul>" + "".join(["<li>"+test[0]+"</li>" for test in res]) + "</ul>"
    
# Procedure d    
@app.route('/results', methods=["GET","POST"])
def results():
    form = PatientForm()
    if request.method == "POST":
        if form.validate_on_submit():
            conn = mysql.connect()
            cursor = conn.cursor()
            
            stmt = "call getResults('{}','{}')".format(form.first_name.data,form.last_name.data)
            cursor.execute(stmt)
            res = cursor.fetchall()
            
            cursor.close()
            conn.close()
            return "Results: " + str(res)
        
    return render_template('results.html',form=form)
    
#Procedure e   
@app.route('/adminnurse', methods=["GET","POST"])
def adminnurse():
    form = GetNursesForm()
    if request.method == "POST":
        if form.validate_on_submit():
            conn = mysql.connect()
            cursor = conn.cursor()
            
            stmt = "call getNurses('{}','{}','{}')".format(form.first_name.data,form.last_name.data,form.date.data)
            cursor.execute(stmt)
            res = cursor.fetchall()
            
            cursor.close()
            conn.close()
            
            return "<ul>" + "".join(["<li>" + item[0] + " " +item[1] + "</li>" for item in res]) + "</ul>"
        
    return render_template('adminnurse.html',form=form)
        
#Procedure f  
@app.route('/interns', methods=["GET"])
def interns():
    conn = mysql.connect()
    cursor = conn.cursor()
            
    stmt = "call getInterns"
    cursor.execute(stmt)
    res = cursor.fetchall()
            
    cursor.close()
    conn.close()
            
    return "These Interns treated the most patients: " + "<br/><ul>" + "".join(["<li>"+test[0]+"</li>" for test in res]) + "</ul>"
    
    
@app.route('/login', methods=['POST', 'GET'])
def login():
    error = None
    form = LoginForm()
    if request.method == 'POST':
        if request.form['password'] != app.config['PASSWORD']:
            error = 'Invalid username or password'
        else:
            if "doc" in form.username.data:
                session['doc'] = True
            elif "nur" in form.username.data:
                session['nur'] = True
            elif "sec" in form.username.data:
                session['sec'] = True
                
            session['logged_in'] = True
            
            flash('You were logged in')
            return redirect(url_for('home'))
    return render_template('login.html', form=form)

@app.route('/logout')
def logout():
    session.pop('logged_in', None)
    session.pop('doc', None)
    session.pop('nur', None)
    session.pop('sec', None)
    flash('You were logged out')
    return redirect(url_for('home'))

# Error handling route
@app.errorhandler(404)
def page_not_found(error):
    """Custom 404 page."""
    return render_template('404.html'), 404


if __name__ == '__main__':
    app.run(debug=True,host="0.0.0.0",port="8080")
