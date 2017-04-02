#!usr/bin/env/ python
# Python 3 
# sudo pip3 install faker

'''
Tables not done:
* family
* familyMember
* familyMemberDisease
* familyMedicalRecord
'''

from faker import Factory
import random

f = Factory.create()

fil = open("populate.sql", "w")

#fil.write("use hospital;\n\n")

build = """
create database hospital;
use hospital;

-- Note: Foreign keys need to be added

create table employee(
	emp_id int auto_increment primary key not null,
	first_name varchar(255) not null,
	last_name varchar(255) not null,
	phone_num varchar(255) not null,
	address varchar(255) not null,
	dob date not null
);

create table patient(
	p_id int auto_increment primary key not null,
	first_name varchar(255) not null,
	last_name varchar(255) not null,
	phone_num varchar(255) not null,
	address varchar(255) not null,
	sex varchar(6) not null,
	dob date not null
);

create table family(
	p_id int not null,
	fam_id int not null,
	primary key(p_id,fam_id)
);

create table familyMember(
	fam_id int auto_increment primary key not null,
	first_name varchar(255) not null,
	last_name varchar(255) not null
);

create table familyMemberDisease(
	fam_id int not null,
	disease_id int not null,
	primary key(fam_id,disease_id)
);

create table familyMedicalRecord(
	p_id int not null,
	fam_id int not null,
	relation varchar(255) not null,
	primary key(p_id,fam_id)
);

-- Consultant, Resident and Intern Doctors?
create table doctor(
	emp_id int auto_increment primary key not null,
	first_name varchar(255) not null,
	last_name varchar(255) not null,
	phone_num varchar(255) not null,
	address varchar(255) not null,
	type varchar(10) not null,
	dob date
);

create table consultant(
	emp_id int auto_increment primary key not null,
	specialization varchar(255) not null,
	first_name varchar(255) not null,
	last_name varchar(255) not null,
	phone_num varchar(255) not null,
	address varchar(255) not null,
	dob date
);

-- Registered, Enrolled, Registered_Midwife Nurse?
create table nurse(
	emp_id int auto_increment primary key not null,
	first_name varchar(255) not null,
	last_name varchar(255) not null,
	phone_num varchar(255) not null,
	address varchar(255) not null,
	type varchar(20) not null,
	dob date not null
);

create table disease(
	disease_id int auto_increment primary key not null,
	disease_name varchar(255)
);

create table diagnosis(
	emp_id int,
	p_id int,
	disease_id int,
	ddate date,
	primary key(emp_id, p_id, disease_id)
);

create table prescribe_medicine(
	emp_id int,
	p_id int,
	med_id int,
	pdate date,
	primary key(emp_id,p_id,med_id)
);

create table test(
	test_id int auto_increment primary key not null,
	test_name varchar(255) not null
);

create table test_result(
	result_id int auto_increment primary key not null,
	result varchar(255) not null,
	tdate date not null
);

create table scan(
	scan_id int auto_increment primary key not null,
	scan_name varchar(255) not null
);

create table result(
	test_id int,
	result_id int,
	primary key(test_id, result_id)
);

create table medicine(
	med_id int auto_increment primary key not null,
	medicine_name varchar(255) not null
);

create table medicates(
	emp_id int,
	med_id int,
	p_id int,
	dose varchar(255) not null,
	ddate date not null,
	primary key(emp_id,med_id,p_id)
);

create table doctor_medicine_dosage(
	p_id int not null,
	med_id int not null,
	dose int,
	primary key(p_id,med_id)
);

create table vitals(
	vital_id int auto_increment primary key not null,
	respiration_rate int not null,
	blood_pressure int not null,
	body_temp int not null,
	pulse_rate int not null
);

create table record(
	emp_id int not null,
	p_id int not null,
	vital_id int not null,
	rdate date not null,
	primary key(emp_id,p_id,vital_id)
);

create table treatment(
	treatment_id int auto_increment primary key not null,
	treatment_name varchar(255) not null
);

create table prescribe_treatment(
	emp_id int not null,
	p_id int not null,
	treatment_id int not null,
	tdate date,
	primary key(emp_id,p_id,treatment_id)
);

create table performs(
	pdate date
);

create table procedures(
	proc_id int auto_increment primary key not null,
	proc_name varchar(255) not null
);

create table nurse_medicine_dosage(
	p_id int not null,
	med_id int not null,
	dose int,
	primary key(p_id,med_id)
);

create table doctor_perform_procedure(
	emp_id int not null,
	proc_id int not null,
	p_id int not null,
	pdate date,
	primary key(emp_id,proc_id,p_id)
);

create table nurse_perform_procedure(
	emp_id int not null,
	proc_id int not null,
	p_id int not null,
	pdate date,
	primary key(emp_id,proc_id,p_id)
);

create table order_test(
	emp_id int not null,
	p_id int not null,
	test_id int not  null,
	odate date,
	primary key(emp_id,p_id,test_id)
);

create table order_procedure(
	emp_id int not null,
	p_id int not null,
	proc_id int not  null,
	odate date,
	primary key(emp_id,p_id,proc_id)
);

create table allergic(
	p_id int primary key not null,
	med_id int not null,
	severity int
);

-- (a) Get the names of all patients with a certain diagnosis between the specified date range.
delimiter //
create procedure getDiagnosisInRange(in diagn varchar(255), in date1 date, in date2 date)
	begin
	(select first_name,last_name from patient where p_id in
		(select p_id from disease join diagnosis on disease.disease_id = diagnosis.disease_id 
			where disease.disease_name = diagn and diagnosis.ddate between date1 and date2));
	end //
delimiter ;

-- (b) Get all allergies of a specific patient
delimiter //
create procedure getAllergies(in f_name varchar(255), in l_name varchar(255))
	begin
	(select medicine_name from medicine join
		(select allergic.p_id, allergic.med_id from patient join allergic on patient.p_id = allergic.p_id 
			where patient.first_name = f_name and patient.last_name = l_name) as new_tab
		on medicine.med_id = new_tab.med_id);
	end //
delimiter ;

-- (c) Get the medication that most patients are allergic to
delimiter //
create procedure mostAllergic()
	begin
	(select medicine_name from medicine where med_id in
		(select med_id from allergic group by med_id having count(med_id) =
			(select max(medcount) from
				(select count(med_id) as medcount from allergic group by med_id) as ntable)));
    end //
delimiter ;

-- (d) Retrieve all test results which may include images/scans of a specific patient
-- note: scan_id is only used in the scan table. No way to retrieve scans
delimiter //
create procedure getResults(in f_name varchar(255), in l_name varchar(255))
	begin
	(select * from test_result where result_id =
		(select result_id from result where test_id =
			(select test_id from order_test where p_id =
				(select p_id from patient where first_name = f_name and last_name = l_name))));
	end //
delimiter ;

-- (e) List nurses who administered medication to a specific patient at a specified date
delimiter //
create procedure getNurses(in f_name varchar(255), in l_name varchar(255), in meddate date)
	begin
	(select first_name,last_name from nurse where emp_id in
		(select emp_id from medicates where ddate = meddate and p_id = 
			(select p_id from patient where first_name = f_name and last_name = l_name)));
	end //
delimiter ;

-- (f) Find the interns who treated the most patients
delimiter //
create procedure getInterns()
	begin
	(select first_name,last_name from doctor where type = 'intern' and emp_id in
		(select emp_id from prescribe_treatment group by emp_id having count(emp_id) = 
			(select max(dcount) from
				(select count(prescribe_treatment.emp_id) as dcount from prescribe_treatment 
					join doctor on prescribe_treatment.emp_id = doctor.emp_id 
					where type = 'intern' group by prescribe_treatment.emp_id) as new_table)));
	end //
delimiter ;
"""

fil.write(build)
fil.write("\n\n")

# populate employee table
for i in range(10):
	fname = f.first_name()
	lname = f.last_name()
	phone_num = random.randrange(1000000,9999999)
	address = f.address().replace("\n", "")
	dob = f.date()

	stmt = "insert into employee(first_name,last_name,phone_num,address,dob) values('{}','{}','{}','{}','{}');".format(fname,lname,phone_num,address,dob)
	fil.write(stmt+"\n")

fil.write("\n")

# populate patient table
for i in range(10):
	fname = f.first_name()
	lname = f.last_name()
	phone_num = random.randrange(1000000,9999999)
	address = f.address().replace("\n", "")
	sex = random.choice(["male","female"])
	dob = f.date()

	stmt = "insert into patient(first_name,last_name,phone_num,address,sex,dob) values('{}','{}','{}','{}','{}','{}');".format(fname,lname,phone_num,address,sex,dob)
	fil.write(stmt+"\n")

fil.write("\n")

# populate doctor table
for i in range(10):
	fname = f.first_name()
	lname = f.last_name()
	phone_num = random.randrange(1000000,9999999)
	address = f.address().replace("\n", "")
	typ = random.choice(["intern","resident"])
	dob = f.date()

	stmt = "insert into doctor(first_name,last_name,phone_num,address,type,dob) values('{}','{}','{}','{}','{}','{}');".format(fname,lname,phone_num,address,typ,dob)
	fil.write(stmt+"\n")

fil.write("\n")

# populate consultant table
for i in range(10):
	fname = f.first_name()
	lname = f.last_name()
	spec = random.choice(["pediatrician","dermatologist"])
	phone_num = random.randrange(1000000,9999999)
	address = f.address().replace("\n", "")
	dob = f.date()

	stmt = "insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('{}','{}','{}','{}','{}','{}');".format(fname,lname,spec,phone_num,address,dob)
	fil.write(stmt+"\n")

fil.write("\n")

# populate nurse table
for i in range(10):
	fname = f.first_name()
	lname = f.last_name()
	phone_num = random.randrange(1000000,9999999)
	address = f.address().replace("\n", "")
	typ = random.choice(["registered","enrolled","registered_midwife"])
	dob = f.date()

	stmt = "insert into nurse(first_name,last_name,phone_num,address,type,dob) values('{}','{}','{}','{}','{}','{}');".format(fname,lname,phone_num,address,typ,dob)
	fil.write(stmt+"\n")

fil.write("\n")

# populate disease table

disease_list = ["Acute flaccid myelitis","Aquagenic urticaria","Brainerd Diarrhea","Jakob disease",
"Cyclic Vomiting Syndrome","Dancing plague","Ebola","Encephalitis lethargica","Exploding Head Syndrome",
"Gulf War Syndrome","Jumping Frenchmen of Maine","Kuru disease","Lujo","Morgellons Disease",
"Multiple Chemical Sensitivity","Mystery Calf Disease","Nodding disease","Peruvian Meteorite Illness",
"Porphyria disease","Stiff person syndrome"]

for dis in disease_list:

	stmt = "insert into disease(disease_name) values('{}');".format(dis)
	fil.write(stmt+"\n")

fil.write("\n")

# populate diagnosis table
for i in range(5):
	emp_id = random.randint(1,10)
	p_id = random.randint(1,10)
	disease_id = random.randint(1,15)
	date = f.date()

	stmt = "insert into diagnosis(emp_id,p_id,disease_id,ddate) values('{}','{}','{}','{}');".format(emp_id,p_id,disease_id,date)
	fil.write(stmt+"\n")

fil.write("\n")

# populate prescribe_medicine table
for i in range(5):
	emp_id = random.randint(1,10)
	p_id = random.randint(1,10)
	d_id = random.randint(1,20)
	pdate = f.date()

	stmt = "insert into diagnosis(emp_id,p_id,disease_id,ddate) values('{}','{}','{}','{}');".format(emp_id,p_id,d_id,pdate)
	fil.write(stmt+"\n")

# populate medicine table
medicine_list = ["Halciferon","Abrathasol","Alcloprine","Albuvac","Oloprosyn","Acribital","Alsutiza Kanustral",
"Estratant Adreprine","Ambesporine Spiroderal","Crofoxin Pediapirin"]

for med in medicine_list:

	stmt = "insert into medicine(medicine_name) values('{}');".format(med)
	fil.write(stmt+"\n")

fil.write("\n")

# populate test table
tests = ["blood pressure","temperature","eyesight","reflexes","blood sugar","cholestoral"]

for test in tests:

	stmt = "insert into test(test_name) values('{}');".format(test)
	fil.write(stmt+"\n")

# populate allergic table
for i in range(20):
	p_id = i+1
	med_id = random.randint(1,10)
	severity = random.randint(1,10)

	stmt = "insert into allergic(p_id,med_id,severity) values({},{},{});".format(p_id,med_id,severity)
	fil.write(stmt+"\n")

fil.write("\n")

# populate prescribe_treatment table
for i in range(20):
	p_id = random.randint(1,10)
	emp_id = random.randint(1,10)
	t_id = random.randint(1,10)
	tdate = f.date()

	stmt = "insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values({},{},{},'{}');".format(emp_id,p_id,t_id,tdate)
	fil.write(stmt+"\n")

fil.write("\n")

# populate medicates table
for i in range(20):
	emp_id = random.randint(1,10)
	med_id = random.randint(1,10)
	p_id = random.randint(1,10)
	dose = random.randint(10,50)
	ddate = f.date()

	stmt = "insert into medicates(emp_id,med_id,p_id,dose,ddate) values({},{},{},'{}','{}');".format(emp_id,med_id,p_id,dose,ddate)
	fil.write(stmt+"\n")

# populate order_test table
for i in range(20):
	emp_id = random.randint(1,10)
	p_id = random.randint(1,10)
	test_id = random.randint(1,6)
	odate = f.date()

	stmt = "insert into order_test(emp_id,p_id,test_id,odate) values({},{},{},'{}');".format(emp_id,p_id,test_id,odate)
	fil.write(stmt+"\n")

# populate test_result table
for i in range(20):
	result = random.choice(["positive","negative"])
	tdate = f.date()

	stmt = "insert into test_result(result,tdate) values('{}','{}');".format(result,tdate)
	fil.write(stmt+"\n")

# populate result table
for i in range(20):
	stmt = "insert into result(test_id,result_id) values({},{});".format(i+1,i+1)
	fil.write(stmt+"\n")

fil.close()