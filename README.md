# Library Management System using SQL

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_project`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.


## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup

- **Database Creation**: Created a database named `library_project`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
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

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS104';

SELECT * FROM issued_status;
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E102'.
```sql

SELECT * FROM issued_status
WHERE issued_emp_id = 'E102';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT i.issued_emp_id, e.emp_name
FROM issued_status i 
JOIN employees e ON i.issued_emp_id = e.emp_id
GROUP BY i.issued_emp_id, e.emp_name
HAVING COUNT(i.issued_emp_id)>1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_cnt AS
SELECT i.issued_book_name, i.issued_book_isbn, COUNT(i.issued_id) AS book_count FROM issued_status i 
JOIN books b ON i.issued_book_isbn = b.isbn
GROUP BY i.issued_book_name,i.issued_book_isbn;

SELECT * FROM book_cnt;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'fantasy';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT b.category, SUM(b.rental_price) AS total_rental_income, COUNT(*)
FROM books b
JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY category;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 980 DAY;

```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
e1.emp_id,
e1.emp_name AS emp_name,
e2.emp_name AS manager,
b.branch_id
 FROM employees e1
JOIN branch b ON b.branch_id = e1.branch_id
JOIN employees e2 ON b.manager_id = e2.emp_id
;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE books_price_greater_than_seven AS
SELECT * FROM books
WHERE rental_price>7;

SELECT * FROM books_price_greater_than_seven;

```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT 
DISTINCT i.issued_book_name
FROM issued_status i 
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL
;

```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT m.member_name, i.issued_book_name, i.issued_date, -- r.return_date,
DATEDIFF(CURRENT_DATE, i.issued_date) AS overdue
FROM issued_status i 
JOIN members m 
    ON i.issued_member_id = m.member_id
JOIN books b 
    ON b.isbn = i.issued_book_isbn
LEFT JOIN return_status r 
    ON i.issued_id = r.issued_id
WHERE r.return_date IS NULL
AND DATEDIFF(CURRENT_DATE, i.issued_date)>30
ORDER BY i.issued_date
;

SELECT CURRENT_DATE;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

SELECT * FROM return_status;
-- Stored Procedure
DELIMITER //
CREATE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
BEGIN
     DECLARE v_isbn VARCHAR(50);
	 DECLARE v_book_name VARCHAR(50);
     
     SELECT
         issued_book_isbn, issued_book_name
         INTO v_isbn, v_book_name
	 FROM issued_status
     WHERE issued_id = p_issued_id;
     
     INSERT INTO return_status(return_id, issued_id, return_book_name, return_date, return_book_isbn, book_quality)
     VALUES(p_return_id, p_issued_id,v_book_name, CURRENT_DATE(), v_isbn, p_book_quality);
     
     UPDATE books
     SET status = 'yes'
     WHERE isbn = v_isbn;
     
     SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
     
END //
DELIMITER ;
-- Function Calling
SELECT * FROM books;

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-375-41398-8';

SELECT * FROM return_status
WHERE issued_id = 'IS134'; -- RS140

DELETE FROM return_status
WHERE return_id = 'RS140';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-375-41398-8';

ROLLBACK;

CALL add_return_records('RS140', 'IS134', 'Good');

```

**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
SELECT b.branch_id, b.branch_address, COUNT(i.issued_id) AS No_of_books_issued, 
COUNT(r.return_id) AS No_of_books_returned, SUM(bo.rental_price) AS total_revenue
FROM issued_status i
JOIN employees e ON i.issued_emp_id = e.emp_id
JOIN branch b ON e.branch_id = b.branch_id
JOIN books bo ON i.issued_book_isbn = bo.isbn
LEFT JOIN return_status r ON i.issued_id = r.issued_id
GROUP BY b.branch_id
;
SELECT * FROM branch_reports;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN(
SELECT DISTINCT issued_member_id FROM issued_status
WHERE issued_date >= CURRENT_DATE - INTERVAL 2 MONTH
)
;

SELECT * FROM active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT
    e.emp_name,
    b.branch_id,
    b.branch_address,
    COUNT(ist.issued_id) AS no_book_issued
FROM issued_status ist
JOIN employees e
    ON e.emp_id = ist.issued_emp_id
JOIN branch b
    ON e.branch_id = b.branch_id
GROUP BY
    e.emp_id,
    e.emp_name,
    b.branch_id,
    b.branch_address
ORDER BY no_book_issued DESC
LIMIT 3;

```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.   
```sql
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

SELECT m.member_name, 
GROUP_CONCAT(i.issued_book_name) AS book_titles,COUNT(i.issued_id) AS Damaged_books_count
 FROM issued_status i
JOIN return_status r ON i.issued_id = r.issued_id
JOIN members m ON i.issued_member_id = m.member_id
WHERE r.book_quality = 'Damaged'
GROUP BY m.member_name
HAVING COUNT(i.issued_id) > 2
;
```

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

SELECT * FROM books;
SELECT * FROM issued_status;

DELIMITER //
CREATE PROCEDURE issue_book(p_issued_id VARCHAR(15), p_issued_member_id VARCHAR(15), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))

BEGIN
     DECLARE v_status VARCHAR(15);
     
     SELECT status
     INTO
     v_status
     FROM books
     WHERE isbn = p_issued_book_isbn;
     
     IF v_status = 'yes' THEN
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);
        
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;
     
        SELECT CONCAT('Book records added succesfully for isbn: ', p_issued_book_isbn) AS message;
	 ELSE
        SELECT CONCAT('Sorry, the book you have requested is currently unavailable: ', p_issued_book_isbn) AS message;
	 END IF;
    END //
    DELIMITER ;
    
    
-- isbn = 978-0-06-025492-6 yes
CALL issue_book('IS165', 'C119', '978-0-06-025492-6', 'E109');
CALL issue_book('IS165', 'C119', '978-0-06-025492-6', 'E109');
    
```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
```sql
SELECT * FROM issued_status;
SELECT * FROM return_status;

SELECT i.issued_member_id AS member_id,
COUNT(*) AS overdue_books,
COUNT(i.issued_id) AS total_books_issued,
SUM(DATEDIFF(CURRENT_DATE, i.issued_date)-30 * 0.50) AS Fine_Amount
FROM issued_status i 
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL
    AND DATEDIFF(CURRENT_DATE, i.issued_date) >30
GROUP BY i.issued_member_id;
```
## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

