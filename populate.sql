
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


insert into employee(first_name,last_name,phone_num,address,dob) values('Calvin','Willis','1794914','325 Michelle Glen Apt. 618New Robert, GU 79383','1981-02-16');
insert into employee(first_name,last_name,phone_num,address,dob) values('Tyler','Olson','3697018','49445 Kristen CourtsSouth Kimberly, OR 21189','2006-06-01');
insert into employee(first_name,last_name,phone_num,address,dob) values('Kari','Smith','6134812','44868 Barber CrossroadWallacefurt, PA 32349-7271','1971-03-22');
insert into employee(first_name,last_name,phone_num,address,dob) values('Kevin','Dyer','8130020','3917 Amber BypassPort Dawnmouth, MH 51500','2009-04-28');
insert into employee(first_name,last_name,phone_num,address,dob) values('Kevin','Cameron','5296343','279 Jessica Trail Apt. 992Michelleville, NM 12656','1987-04-22');
insert into employee(first_name,last_name,phone_num,address,dob) values('Dana','Nichols','2117891','44788 Hurst ClubEast Heather, OK 63887-9444','2009-11-29');
insert into employee(first_name,last_name,phone_num,address,dob) values('Hunter','Clay','1257729','970 Scott Glen Apt. 114Turnerbury, OR 92514','1970-05-21');
insert into employee(first_name,last_name,phone_num,address,dob) values('Laura','Barnes','6204319','3793 Bruce Lakes Suite 884Patrickville, KS 24161-0922','1970-02-05');
insert into employee(first_name,last_name,phone_num,address,dob) values('Samantha','Sparks','9459329','48214 Frank StreamLaurenfurt, NY 25266','1986-11-27');
insert into employee(first_name,last_name,phone_num,address,dob) values('Jared','Ferrell','6429374','5064 Melissa FreewayHardymouth, IN 89928','1971-06-30');

insert into patient(first_name,last_name,phone_num,address,sex,dob) values('John','Gomez','7033345','PSC 0199, Box 1767APO AA 11466','male','2013-03-22');
insert into patient(first_name,last_name,phone_num,address,sex,dob) values('Keith','Moore','4510904','25141 Joseph CanyonMartinezland, VA 05814','female','2006-08-27');
insert into patient(first_name,last_name,phone_num,address,sex,dob) values('Benjamin','Thompson','4307352','7160 Ortega Harbors Apt. 244Romanmouth, AR 46595-7115','female','2003-11-06');
insert into patient(first_name,last_name,phone_num,address,sex,dob) values('Denise','Marquez','1630225','952 David Views Apt. 276Port Michaelville, UT 11107-7314','male','1990-04-26');
insert into patient(first_name,last_name,phone_num,address,sex,dob) values('Maria','Cordova','7433820','613 Hall Isle Suite 802Seanburgh, MN 52831','male','1981-02-06');
insert into patient(first_name,last_name,phone_num,address,sex,dob) values('Courtney','Berger','9279232','419 Michael ShoalHollychester, NV 88213','male','2008-11-08');
insert into patient(first_name,last_name,phone_num,address,sex,dob) values('Thomas','Holder','6327843','741 Brandi EstateRobinsonmouth, IL 80109','male','1970-01-01');
insert into patient(first_name,last_name,phone_num,address,sex,dob) values('Victor','Bailey','1650114','Unit 7396 Box 6566DPO AP 46361','female','2007-02-09');
insert into patient(first_name,last_name,phone_num,address,sex,dob) values('Eric','Pope','6792824','704 Sanchez AlleyGarciaborough, NH 75052','female','1975-06-23');
insert into patient(first_name,last_name,phone_num,address,sex,dob) values('Anthony','Porter','2454884','PSC 2370, Box 9940APO AA 45908-2480','male','1996-08-27');

insert into doctor(first_name,last_name,phone_num,address,type,dob) values('Holly','Jones','2433126','06837 Levy Loaf Apt. 349Jasonstad, MO 32815-4790','resident','1992-08-11');
insert into doctor(first_name,last_name,phone_num,address,type,dob) values('James','Logan','6346240','91647 Alexander Centers Suite 170Davisborough, OR 81865','intern','2006-08-27');
insert into doctor(first_name,last_name,phone_num,address,type,dob) values('Kimberly','Price','3808711','411 Sandra Curve Suite 640Johnland, AK 57123','resident','1975-02-17');
insert into doctor(first_name,last_name,phone_num,address,type,dob) values('Marcus','Fuller','8477555','754 Christian Ville Apt. 700South Deborah, AZ 95885-8383','intern','2003-06-09');
insert into doctor(first_name,last_name,phone_num,address,type,dob) values('William','Zimmerman','1467899','01692 Hudson PointWest Sarah, VA 19893','resident','1973-07-25');
insert into doctor(first_name,last_name,phone_num,address,type,dob) values('Stacey','Clements','2887713','Unit 3102 Box 3172DPO AE 57637-4208','resident','2000-11-20');
insert into doctor(first_name,last_name,phone_num,address,type,dob) values('Alex','Krause','6047528','918 Cunningham Port Suite 241Erinville, SC 78633','resident','1975-12-28');
insert into doctor(first_name,last_name,phone_num,address,type,dob) values('Tracey','Brown','7024628','2395 Turner Ramp Suite 824East Bryanton, NJ 42060-5436','resident','2010-09-24');
insert into doctor(first_name,last_name,phone_num,address,type,dob) values('Zachary','Mullins','8171285','252 Karen DamSharpmouth, GU 06950','intern','1992-06-07');
insert into doctor(first_name,last_name,phone_num,address,type,dob) values('Tracie','Wright','2736289','Unit 7222 Box 3864DPO AE 19227','intern','1979-12-26');

insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('Summer','Johnson','pediatrician','2602405','0711 Brooks Manors Suite 681Millerhaven, MA 51161-6993','2001-06-28');
insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('Jessica','Higgins','dermatologist','8472983','9607 Johnson Pike Apt. 755Chamberstown, UT 77219-5875','1971-11-02');
insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('Angel','Robinson','pediatrician','6048080','731 Reyes Hills Apt. 812East Steven, RI 10108-8226','1992-12-17');
insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('Kenneth','Allen','dermatologist','6587827','2408 Robinson Haven Apt. 783Mcfarlandburgh, ME 16694-0117','1981-12-24');
insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('Jasmine','Mitchell','dermatologist','4902240','558 Spears MountainsLake Timothyfurt, NY 74935','1986-04-06');
insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('Jonathan','Guzman','pediatrician','4994802','5371 Debra Dale Suite 261North Lisamouth, KS 38252-0809','2001-08-04');
insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('Charles','Christian','pediatrician','1839310','70842 Adams Flat Apt. 669Hollyville, MI 24084','2004-02-04');
insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('Sabrina','Roberts','dermatologist','4923133','533 May Trafficway Apt. 601Danielleborough, IA 12745','1997-05-07');
insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('Stephanie','Gonzales','dermatologist','4180360','900 Ross TrailHaleville, AZ 12386-9793','2016-12-04');
insert into consultant(first_name,last_name,specialization,phone_num,address,dob) values('Kristy','Delacruz','dermatologist','9529770','277 Evan Brooks Suite 878North Cassandraview, OR 52979','1981-10-02');

insert into nurse(first_name,last_name,phone_num,address,type,dob) values('Patricia','Oliver','6464783','026 Andre PlainBryceville, RI 83291','registered_midwife','1987-05-27');
insert into nurse(first_name,last_name,phone_num,address,type,dob) values('Angela','Garcia','7477074','0862 Williams Keys Apt. 845East Michael, IN 44701-2873','enrolled','1978-03-15');
insert into nurse(first_name,last_name,phone_num,address,type,dob) values('Paul','Lucero','6341599','6984 Acevedo UnderpassNew Brenda, VI 15120-5593','registered_midwife','1983-07-14');
insert into nurse(first_name,last_name,phone_num,address,type,dob) values('Brian','Ward','2570706','9060 Richard Center Apt. 162Davisfort, OK 38820-3132','registered_midwife','2001-10-30');
insert into nurse(first_name,last_name,phone_num,address,type,dob) values('Michael','Rogers','6019256','074 James Hill Suite 189South Deanmouth, PW 47122','registered','2014-06-03');
insert into nurse(first_name,last_name,phone_num,address,type,dob) values('Kelli','Bell','6858878','33023 Denise Trail Suite 801New Kristopherstad, NE 11553-6091','registered_midwife','1970-04-24');
insert into nurse(first_name,last_name,phone_num,address,type,dob) values('Karen','Kramer','8509911','92184 Jeffrey CornerMarquezshire, NE 13944-1212','enrolled','2000-03-20');
insert into nurse(first_name,last_name,phone_num,address,type,dob) values('Daniel','Smith','3560632','260 Martinez PrairieTheodorefort, PW 85628','registered_midwife','1998-06-24');
insert into nurse(first_name,last_name,phone_num,address,type,dob) values('Elizabeth','Ross','5585936','78488 Justin ForksWest Amychester, VT 12132-2185','registered_midwife','1996-09-23');
insert into nurse(first_name,last_name,phone_num,address,type,dob) values('Miranda','Potts','7233493','51973 Harris Springs Apt. 843East Williamfort, WV 31339','registered','1982-02-05');

insert into disease(disease_name) values('Acute flaccid myelitis');
insert into disease(disease_name) values('Aquagenic urticaria');
insert into disease(disease_name) values('Brainerd Diarrhea');
insert into disease(disease_name) values('Jakob disease');
insert into disease(disease_name) values('Cyclic Vomiting Syndrome');
insert into disease(disease_name) values('Dancing plague');
insert into disease(disease_name) values('Ebola');
insert into disease(disease_name) values('Encephalitis lethargica');
insert into disease(disease_name) values('Exploding Head Syndrome');
insert into disease(disease_name) values('Gulf War Syndrome');
insert into disease(disease_name) values('Jumping Frenchmen of Maine');
insert into disease(disease_name) values('Kuru disease');
insert into disease(disease_name) values('Lujo');
insert into disease(disease_name) values('Morgellons Disease');
insert into disease(disease_name) values('Multiple Chemical Sensitivity');
insert into disease(disease_name) values('Mystery Calf Disease');
insert into disease(disease_name) values('Nodding disease');
insert into disease(disease_name) values('Peruvian Meteorite Illness');
insert into disease(disease_name) values('Porphyria disease');
insert into disease(disease_name) values('Stiff person syndrome');

insert into diagnosis(emp_id,p_id,disease_id,ddate) values('8','10','9','1971-08-09');
insert into diagnosis(emp_id,p_id,disease_id,ddate) values('6','2','8','2008-05-18');
insert into diagnosis(emp_id,p_id,disease_id,ddate) values('1','10','4','1975-08-01');
insert into diagnosis(emp_id,p_id,disease_id,ddate) values('8','10','10','2011-09-22');
insert into diagnosis(emp_id,p_id,disease_id,ddate) values('4','6','6','1971-12-06');

insert into diagnosis(emp_id,p_id,disease_id,ddate) values('7','2','12','1982-12-01');
insert into diagnosis(emp_id,p_id,disease_id,ddate) values('8','4','17','1989-10-18');
insert into diagnosis(emp_id,p_id,disease_id,ddate) values('9','9','17','1991-04-12');
insert into diagnosis(emp_id,p_id,disease_id,ddate) values('5','2','11','2017-03-17');
insert into diagnosis(emp_id,p_id,disease_id,ddate) values('3','8','14','1984-02-08');
insert into medicine(medicine_name) values('Halciferon');
insert into medicine(medicine_name) values('Abrathasol');
insert into medicine(medicine_name) values('Alcloprine');
insert into medicine(medicine_name) values('Albuvac');
insert into medicine(medicine_name) values('Oloprosyn');
insert into medicine(medicine_name) values('Acribital');
insert into medicine(medicine_name) values('Alsutiza Kanustral');
insert into medicine(medicine_name) values('Estratant Adreprine');
insert into medicine(medicine_name) values('Ambesporine Spiroderal');
insert into medicine(medicine_name) values('Crofoxin Pediapirin');

insert into test(test_name) values('blood pressure');
insert into test(test_name) values('temperature');
insert into test(test_name) values('eyesight');
insert into test(test_name) values('reflexes');
insert into test(test_name) values('blood sugar');
insert into test(test_name) values('cholestoral');
insert into allergic(p_id,med_id,severity) values(1,3,5);
insert into allergic(p_id,med_id,severity) values(2,3,3);
insert into allergic(p_id,med_id,severity) values(3,2,9);
insert into allergic(p_id,med_id,severity) values(4,1,1);
insert into allergic(p_id,med_id,severity) values(5,2,10);
insert into allergic(p_id,med_id,severity) values(6,6,3);
insert into allergic(p_id,med_id,severity) values(7,2,6);
insert into allergic(p_id,med_id,severity) values(8,9,3);
insert into allergic(p_id,med_id,severity) values(9,4,9);
insert into allergic(p_id,med_id,severity) values(10,4,3);
insert into allergic(p_id,med_id,severity) values(11,2,3);
insert into allergic(p_id,med_id,severity) values(12,8,2);
insert into allergic(p_id,med_id,severity) values(13,9,3);
insert into allergic(p_id,med_id,severity) values(14,5,1);
insert into allergic(p_id,med_id,severity) values(15,5,8);
insert into allergic(p_id,med_id,severity) values(16,8,1);
insert into allergic(p_id,med_id,severity) values(17,9,3);
insert into allergic(p_id,med_id,severity) values(18,4,8);
insert into allergic(p_id,med_id,severity) values(19,10,6);
insert into allergic(p_id,med_id,severity) values(20,1,2);

insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(5,7,10,'2013-09-17');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(10,3,7,'2008-03-15');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(6,5,10,'1988-06-27');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(1,4,3,'1975-02-28');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(6,5,7,'1999-12-02');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(5,9,5,'1989-01-07');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(3,9,9,'1981-02-22');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(4,1,6,'1990-08-30');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(9,4,8,'1977-03-31');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(7,1,1,'1970-03-31');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(3,3,8,'1974-01-12');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(10,5,3,'1971-09-25');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(8,3,9,'1976-01-10');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(5,10,6,'1977-10-01');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(1,9,7,'2014-07-27');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(4,7,1,'2014-12-03');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(2,8,5,'1995-04-19');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(5,1,1,'2005-07-23');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(3,10,9,'1983-05-10');
insert into prescribe_treatment(emp_id,p_id,treatment_id,tdate) values(6,4,9,'1998-10-22');

insert into medicates(emp_id,med_id,p_id,dose,ddate) values(5,3,3,'44','1993-03-31');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(4,9,3,'45','2003-09-09');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(1,5,2,'47','1976-08-10');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(8,8,2,'48','1975-09-15');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(2,7,4,'35','2000-09-17');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(5,2,10,'50','1989-12-21');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(9,8,7,'47','2003-12-10');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(10,8,5,'13','2001-11-05');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(5,1,6,'27','2016-09-16');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(1,2,8,'24','1992-11-26');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(10,6,2,'13','1991-08-20');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(1,2,2,'50','2006-03-05');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(9,2,6,'25','1993-08-10');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(8,3,4,'17','2002-07-08');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(2,7,6,'34','2000-06-30');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(10,6,2,'17','2009-08-31');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(3,6,4,'37','2014-08-06');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(5,4,3,'16','1992-03-26');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(9,4,1,'31','1972-04-02');
insert into medicates(emp_id,med_id,p_id,dose,ddate) values(6,6,3,'24','1988-11-27');
insert into order_test(emp_id,p_id,test_id,odate) values(9,3,5,'2015-12-05');
insert into order_test(emp_id,p_id,test_id,odate) values(7,8,4,'2011-02-11');
insert into order_test(emp_id,p_id,test_id,odate) values(3,9,6,'1995-10-04');
insert into order_test(emp_id,p_id,test_id,odate) values(7,2,1,'2004-07-01');
insert into order_test(emp_id,p_id,test_id,odate) values(8,7,4,'1991-05-29');
insert into order_test(emp_id,p_id,test_id,odate) values(8,1,2,'1992-10-07');
insert into order_test(emp_id,p_id,test_id,odate) values(6,5,4,'2016-12-28');
insert into order_test(emp_id,p_id,test_id,odate) values(8,8,4,'1995-12-07');
insert into order_test(emp_id,p_id,test_id,odate) values(8,5,1,'1977-04-27');
insert into order_test(emp_id,p_id,test_id,odate) values(2,3,2,'1999-01-26');
insert into order_test(emp_id,p_id,test_id,odate) values(5,5,5,'2007-02-25');
insert into order_test(emp_id,p_id,test_id,odate) values(7,9,2,'1980-02-01');
insert into order_test(emp_id,p_id,test_id,odate) values(7,7,4,'1994-05-08');
insert into order_test(emp_id,p_id,test_id,odate) values(5,9,4,'1986-11-02');
insert into order_test(emp_id,p_id,test_id,odate) values(4,6,2,'1982-10-06');
insert into order_test(emp_id,p_id,test_id,odate) values(5,7,3,'1993-07-18');
insert into order_test(emp_id,p_id,test_id,odate) values(4,2,3,'1973-07-31');
insert into order_test(emp_id,p_id,test_id,odate) values(5,7,3,'2009-03-30');
insert into order_test(emp_id,p_id,test_id,odate) values(6,10,6,'1999-07-29');
insert into order_test(emp_id,p_id,test_id,odate) values(6,10,6,'2004-11-09');
insert into test_result(result,tdate) values('positive','2009-08-18');
insert into test_result(result,tdate) values('positive','2002-06-07');
insert into test_result(result,tdate) values('positive','1983-12-12');
insert into test_result(result,tdate) values('negative','2000-10-01');
insert into test_result(result,tdate) values('positive','2002-11-28');
insert into test_result(result,tdate) values('negative','2003-10-22');
insert into test_result(result,tdate) values('negative','2006-08-11');
insert into test_result(result,tdate) values('negative','1993-01-21');
insert into test_result(result,tdate) values('positive','2002-04-01');
insert into test_result(result,tdate) values('positive','1999-05-20');
insert into test_result(result,tdate) values('negative','1979-03-07');
insert into test_result(result,tdate) values('negative','1971-07-17');
insert into test_result(result,tdate) values('positive','1983-02-06');
insert into test_result(result,tdate) values('negative','1994-12-03');
insert into test_result(result,tdate) values('positive','1988-02-24');
insert into test_result(result,tdate) values('negative','2000-06-04');
insert into test_result(result,tdate) values('positive','1997-11-23');
insert into test_result(result,tdate) values('negative','1994-07-21');
insert into test_result(result,tdate) values('positive','1989-06-14');
insert into test_result(result,tdate) values('negative','1973-05-05');
insert into result(test_id,result_id) values(1,1);
insert into result(test_id,result_id) values(2,2);
insert into result(test_id,result_id) values(3,3);
insert into result(test_id,result_id) values(4,4);
insert into result(test_id,result_id) values(5,5);
insert into result(test_id,result_id) values(6,6);
insert into result(test_id,result_id) values(7,7);
insert into result(test_id,result_id) values(8,8);
insert into result(test_id,result_id) values(9,9);
insert into result(test_id,result_id) values(10,10);
insert into result(test_id,result_id) values(11,11);
insert into result(test_id,result_id) values(12,12);
insert into result(test_id,result_id) values(13,13);
insert into result(test_id,result_id) values(14,14);
insert into result(test_id,result_id) values(15,15);
insert into result(test_id,result_id) values(16,16);
insert into result(test_id,result_id) values(17,17);
insert into result(test_id,result_id) values(18,18);
insert into result(test_id,result_id) values(19,19);
insert into result(test_id,result_id) values(20,20);
