CREATE DATABASE library_project;
USE library_project;

-- Library Project
-- Creating branch table
CREATE TABLE branch(
branch_id VARCHAR(10) PRIMARY KEY,
manager_id VARCHAR(10),
branch_address VARCHAR(55),
contact_no VARCHAR(15)
);

-- Creating employees table
CREATE TABLE employees(
emp_id VARCHAR(10) PRIMARY KEY,
emp_name VARCHAR(25),
position VARCHAR(25),
salary INT,
branch_id VARCHAR(25),
FOREIGN KEY(branch_id) REFERENCES branch(branch_id)
);

-- Creating books table
CREATE TABLE books(
isbn VARCHAR(20) PRIMARY KEY,
book_title VARCHAR(80),
category VARCHAR(10),
rental_price DECIMAL(10,2),
status VARCHAR(15),
author VARCHAR(35),
publisher VARCHAR(55)
);
ALTER TABLE books
MODIFY column category VARCHAR(30);

-- Creating members table
CREATE TABLE members(
member_id VARCHAR(10) PRIMARY KEY,
member_name VARCHAR(25),
member_address VARCHAR(75),
reg_date DATE
);

-- Creating issued status table
CREATE TABLE issued_status(
issued_id VARCHAR(10) PRIMARY KEY,
issued_member_id VARCHAR(30),
issued_book_name VARCHAR(75),
issued_date DATE,
issued_book_isbn VARCHAR(50),
issued_emp_id VARCHAR(10),
FOREIGN KEY(issued_member_id) REFERENCES members(member_id),
FOREIGN KEY(issued_book_isbn) REFERENCES books(isbn),
FOREIGN KEY(issued_emp_id) REFERENCES employees(emp_id)
);

-- Creating return status table
CREATE TABLE return_status(
return_id VARCHAR(15) PRIMARY KEY,
issued_id VARCHAR(30),
return_book_name VARCHAR(75),
return_date DATE,
return_book_isbn VARCHAR(50),
FOREIGN KEY(return_book_isbn) REFERENCES books(isbn)
);