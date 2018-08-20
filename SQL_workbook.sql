-- Part I – Working with an existing database

-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
SELECT * FROM employee;
-- Task – Select all records from the Employee table where last name is King.
SELECT * FROM employee WHERE lastname = 'King';
-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * FROM employee WHERE firstname = 'Andrew' AND reportsto IS NULL;
-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM album ORDER BY title DESC;
-- Task – Select first name from Customer and sort result set in ascending order by city
SELECT firstname FROM customer ORDER BY city ASC;
-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
INSERT INTO genre (genreid, name) VALUES (26, 'Bluegrass'), (27, 'VGM');
-- Task – Insert two new records into Employee table
INSERT INTO employee (employeeid, lastname, firstname, title, reportsto, birthdate,
hiredate, address, city, state, country, postalcode, phone, fax, email)
VALUES (9, 'Rees', 'Jameson', 'IT Staff', 6, '1995-05-04 00:00:00', '2018-06-06 00:00:00', '2680 Lamar Poss Road',
		'Good Hope', 'GA', 'USA', '30641', '+1 (706) 995-6336', '+1 (706) 995-6336', 'jamiejunobug@juno.com'),
		(10, 'Jones', 'Blankie', 'Sales Support Agent', 2, '1991-04-21 00:00:00', '2013-08-14 00:00:00', '4320 Main Avenue',
		'Springville', 'NY', 'USA', '78945', '+1 (214) 123-4567', '+1 (214) 123-4567', 'blankie@chinookcorp.com');
-- Task – Insert two new records into Customer table
INSERT INTO customer (customerid, firstname, lastname, company, address, city, state, country, postalcode, phone,
	fax, email, supportrepid)
VALUES (60, 'Joe', 'Cool', 'Snoopy Enterprises', '2109 Brown Street', 'Charleston', 'SC', 'USA', '98765', '+1 (999) 876-5432',
		   '+1 (999) 876-5432', 'joe.cool@snoopy.dog', 5),
		   (61, 'Hans', 'Schultz', 'Luft-Stalag 13', '1234 Main Street', 'Dusseldorf', 'AB', 'Germany', '43210', '+49 (0722) 315-4628',
		   '+49 (0722) 315-4628', 'hans.schultz@stalag.de', 4);
-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
UPDATE customer SET firstname = 'Robert', lastname = 'Walter'
WHERE firstname = 'Aaron' AND lastname = 'Mitchell';
-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
UPDATE artist SET name = 'CCR'
WHERE name = 'Creedence Clearwater Revival';
-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
SELECT *
FROM invoice
WHERE billingaddress LIKE 'T%';
-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
SELECT *
FROM invoice
WHERE total BETWEEN 15 AND 50;
-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004
SELECT *
FROM employee
WHERE hiredate BETWEEN '2003-06-01 00:00:00' AND '2004-03-01 00:00:00';
-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).
DELETE
FROM invoiceline
WHERE invoiceid IN (SELECT invoiceid
				  FROM invoice
				  WHERE customerid = (SELECT customerid
									 FROM customer
									 WHERE firstname = 'Robert' AND lastname = 'Walter') );
DELETE
FROM invoice
WHERE customerid = (SELECT customerid
				   FROM customer
				   WHERE firstname = 'Robert' AND lastname = 'Walter');
DELETE
FROM customer
WHERE firstname = 'Robert' AND lastname = 'Walter';
-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
CREATE OR REPLACE FUNCTION time_now()
RETURNS time AS $$
	BEGIN
		RETURN CURRENT_TIME;
	END;
$$ LANGUAGE plpgsql
-- Task – create a function that returns the length of a mediatype from the mediatype table
CREATE OR REPLACE FUNCTION media_type_length(media_type_name VARCHAR)
RETURNS INTEGER AS $$
	BEGIN
		RETURN LENGTH(media_type_name);
	END;
$$ LANGUAGE plpgsql
-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
CREATE OR REPLACE FUNCTION find_inv_total_avg()
RETURNS DECIMAL(10) AS $$
	BEGIN
		RETURN AVG (total)
		FROM invoice;
	END;
$$ LANGUAGE plpgsql
-- Task – Create a function that returns the most expensive track
CREATE OR REPLACE FUNCTION find_max_price_track(max_track refcursor)
RETURNS refcursor AS $$
		BEGIN
		OPEN max_track FOR SELECT MAX (unitprice) FROM track;
		RETURN max_track;
		END;
$$ LANGUAGE plpgsql
-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
CREATE OR REPLACE FUNCTION find_avg_invline_price()
RETURNS DECIMAL(3) AS $$
	BEGIN
		RETURN AVG (unitprice)
		FROM invoiceline;
	END;
$$ LANGUAGE plpgsql
-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
CREATE OR REPLACE FUNCTION find_emp_born_after_1968(younguns refcursor)
RETURNS refcursor AS $$
		BEGIN
		OPEN younguns FOR SELECT * FROM employee
		WHERE birthdate > '1969-01-01 00:00:00';
		RETURN younguns;
		END;
$$ LANGUAGE plpgsql
-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.
CREATE OR REPLACE FUNCTION find_emp_names(first_last_name refcursor)
RETURNS refcursor AS $$
		BEGIN
		OPEN first_last_name FOR SELECT firstname, lastname FROM employee;
		RETURN first_last_name;
		END;
$$ LANGUAGE plpgsql
-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.
CREATE OR REPLACE FUNCTION update_emp_address(
	e_id INTEGER,
	new_addr VARCHAR)
	RETURNS void AS $$
BEGIN
	UPDATE employee
	SET address = new_addr
	WHERE employeeid = e_id;
END;
$$ LANGUAGE plpgsql;
-- Task – Create a stored procedure that returns the managers of an employee.
CREATE OR REPLACE FUNCTION find_manager(
	e_id INTEGER)
	RETURNS INTEGER AS $$
	BEGIN
	RETURN reportsto FROM employee
	WHERE employeeid = e_id;
	END;
$$ LANGUAGE plpgsql;
-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
CREATE OR REPLACE FUNCTION find_name_plus_comp(
	c_id INTEGER)
	RETURNS TABLE(name1 VARCHAR, name2 VARCHAR, comp VARCHAR) AS $$
	BEGIN
	RETURN QUERY SELECT firstname, lastname, company FROM customer WHERE customerid = c_id;
	END;
$$ LANGUAGE plpgsql;
-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
CREATE OR REPLACE FUNCTION delete_invoice(
	inv_id INTEGER)
	RETURNS void AS $$
	BEGIN
	DELETE FROM invoiceline 
	WHERE invoiceid = inv_id;

	DELETE FROM invoice
	WHERE invoiceid = inv_id;
	END;
$$ LANGUAGE plpgsql;
-- Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
CREATE OR REPLACE FUNCTION add_customer(
	c_id INTEGER,
	f_name VARCHAR,
	l_name VARCHAR,
	comp VARCHAR,
	addr VARCHAR,
	cit VARCHAR,
	stt VARCHAR,
	cntry VARCHAR,
	post_code VARCHAR,
	phone_num VARCHAR,
	fax_num VARCHAR,
	email_addr VARCHAR,
	support_rep INTEGER
	)
	RETURNS void AS $$
	BEGIN
	INSERT INTO customer(
		customerid,
		firstname,
		lastname,
		company,
		address,
		city,
		state,
		country,
		postalcode,
		phone,
		fax,
		email,
		supportrepid
	)
	VALUES (
		c_id,
		f_name,
		l_name,
		comp,
		addr,
		cit,
		stt,
		cntry,
		post_code,
		phone_num,
		fax_num,
		email_addr,
		support_rep
	);
	END;
$$ LANGUAGE plpgsql;
-- 6.0 Triggers
-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.

-- Trigger:
CREATE TRIGGER after_new_employee
AFTER INSERT ON employee
FOR EACH ROW
EXECUTE PROCEDURE name_prank();
-- Function called by trigger
CREATE OR REPLACE FUNCTION name_prank()
RETURNS TRIGGER AS $$
BEGIN
	IF (TG_OP = 'INSERT') THEN
	    	UPDATE employee
	   		SET firstname = 'newguy'
	   		WHERE employeeid = 11;
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
CREATE TRIGGER after_album_update
AFTER UPDATE ON album
FOR EACH ROW
EXECUTE PROCEDURE update_album_fake_log();

CREATE OR REPLACE FUNCTION update_album_fake_log()
RETURNS TRIGGER AS $$
BEGIN
	IF (TG_OP = 'UPDATE') THEN
	    	INSERT INTO album (
				albumid,
				title,
				artistid
			)
	   		VALUES (
				348,
				'album updated',
				1
			);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
CREATE TRIGGER after_cust_delete
AFTER DELETE ON customer
FOR EACH ROW
EXECUTE PROCEDURE add_placeholder_row();

CREATE OR REPLACE FUNCTION add_placeholder_row()
RETURNS TRIGGER AS $$
BEGIN
	IF (TG_OP = 'DELETE') THEN
  	INSERT INTO customer (
		customerid,
		firstname,
		lastname,
		company,
		address,
		city,
		state,
		country,
		postalcode,
		phone,
		fax,
		email,
		supportrepid
		)
	VALUES (
		OLD.customerid,
		'placeholder',
		'placeholder',
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		'placeholder',
		3
	);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6.2 INSTEAD OF
-- Task – Create an instead of trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE TRIGGER prevent_lrg_inv_delete
BEFORE DELETE ON invoice
FOR EACH ROW EXECUTE PROCEDURE check_inv_amt();

CREATE FUNCTION check_inv_amt() RETURNS trigger AS $check_inv_amt$
    BEGIN            
        IF OLD.total >= 50 THEN
            RAISE EXCEPTION 'cannot delete invoices over $50';
		ELSE RETURN null;
        END IF;

    END;
$check_inv_amt$ LANGUAGE plpgsql;
-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
SELECT firstname, lastname, invoiceid
FROM customer INNER JOIN invoice
ON (customer.customerid = invoice.customerid);
-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table,
-- specifying the CustomerId, firstname, lastname, invoiceId, and total.
SELECT customer.customerid, firstname, lastname, invoiceid, total
FROM customer FULL JOIN invoice
ON (customer.customerid = invoice.customerid);
-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
SELECT name, title
FROM album RIGHT JOIN artist
ON (album.artistid = artist.artistid);
-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
SELECT *
FROM album CROSS JOIN artist
ORDER BY name ASC;
-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.
SELECT *
FROM employee e1, employee e2
WHERE e1.reportsto = e2.employeeid;

