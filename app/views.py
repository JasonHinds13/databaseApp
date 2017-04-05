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

@app.route('/test', methods=['POST', 'GET'])
def test_db():
    #if not session.get('logged_in'):
        #abort(401)

    #cursor = mysql.get_db().cursor()
    
    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute('select * from patient')
    d = cursor.fetchall()

    cursor.close()
    conn.close()

    return str(d)
    
@app.route('/register', methods=['POST', 'GET'])
def register():
    reg_form = RegForm(request.form)
    
    if request.method == "POST":
        if reg_form.validate_on_submit():
            user_name = reg_form.name.data
            user_email = reg_form.email.data
            subject = reg_form.subject.data
            msg = reg_form.message.data
            
            conn = mysql.connect()
            cursor = conn.cursor()
            cursor.execute('insert into  * from patient')
            d = cursor.fetchall()
            cursor.close()
            conn.close()
            
            return redirect(url_for('home'))
    
    return render_template('contact.html', form=reg_form)
    
@app.route('/meddata')
def medical():
    med_form=MedForm(request.form)
    
    if request.method == "POST":
        if med_form.validate_on_submit():
            pass
    
    return render_template('meddata.html', form=med_form)
    

@app.route('/reports')
def reports():
    return render_template('reports.html')
    
@app.route('/allergens', methods=["GET","POST"])
def allergens():
    form = PatientForm()
    if request.method == "POST":
        if form.validate_on_submit():
            conn = mysql.connect()
            cursor = conn.cursor()
            
            stmt = "call getAllergies({},{})".format(form.first_name.data,form.last_name.data)
            cursor.execute(stmt)
            res = cursor.fetchall()
            
            cursor.close()
            conn.close()
            return res
        
    return render_template('allergens.html',form=form)
    
@app.route('/results', methods=["GET","POST"])
def results():
    form = PatientForm()
    if request.method == "POST":
        if form.validate_on_submit():
            conn = mysql.connect()
            cursor = conn.cursor()
            
            stmt = "call getResults({},{})".format(form.first_name.data,form.last_name.data)
            cursor.execute(stmt)
            res = cursor.fetchall()
            
            cursor.close()
            conn.close()
            return res
        
    return render_template('results.html',form=form)
        

@app.route('/login', methods=['POST', 'GET'])
def login():
    error = None
    form = LoginForm()
    if request.method == 'POST':
        if request.form['username'] != app.config['USERNAME'] or request.form['password'] != app.config['PASSWORD']:
            error = 'Invalid username or password'
        else:
            session['logged_in'] = True
            
            flash('You were logged in')
            return redirect(url_for('add_file'))
    return render_template('login.html', form=form)

@app.route('/logout')
def logout():
    session.pop('logged_in', None)
    flash('You were logged out')
    return redirect(url_for('home'))

# Error handling route
@app.errorhandler(404)
def page_not_found(error):
    """Custom 404 page."""
    return render_template('404.html'), 404


if __name__ == '__main__':
    app.run(debug=True,host="0.0.0.0",port="8080")
