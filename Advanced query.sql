SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM members;
SELECT * FROM issued_status;
SELECT * FROM return_status;

-- Project TASK


-- ### 2. CRUD Operations


-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS104';

SELECT * FROM issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E102';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT i.issued_emp_id, e.emp_name
FROM issued_status i 
JOIN employees e ON i.issued_emp_id = e.emp_id
GROUP BY i.issued_emp_id, e.emp_name
HAVING COUNT(i.issued_emp_id)>1;


-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE book_cnt AS
SELECT i.issued_book_name, i.issued_book_isbn, COUNT(i.issued_id) AS book_count FROM issued_status i 
JOIN books b ON i.issued_book_isbn = b.isbn
GROUP BY i.issued_book_name,i.issued_book_isbn;

SELECT * FROM book_cnt;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'fantasy';

-- Task 8: Find Total Rental Income by Category:
SELECT b.category, SUM(b.rental_price) AS total_rental_income, COUNT(*)
FROM books b
JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY category;


-- Task 9. **List Members Who Registered in the Last 980 Days**:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 980 DAY;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:
SELECT 
e1.emp_id,
e1.emp_name AS emp_name,
e2.emp_name AS manager,
b.branch_id
 FROM employees e1
JOIN branch b ON b.branch_id = e1.branch_id
JOIN employees e2 ON b.manager_id = e2.emp_id
;


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
CREATE TABLE books_price_greater_than_seven AS
SELECT * FROM books
WHERE rental_price>7;

SELECT * FROM books_price_greater_than_seven;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT 
DISTINCT i.issued_book_name
FROM issued_status i 
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL
;

/*
### Advanced SQL Operations

Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's name, book title, issue date, and days overdue.*/

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

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "available" when they are returned
--  (based on entries in the return_status table).
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

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, 
-- the number of books returned, and the total revenue generated from book rentals.
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

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least 
one book in the last 6 months.*/
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN(
SELECT DISTINCT issued_member_id FROM issued_status
WHERE issued_date >= CURRENT_DATE - INTERVAL 2 MONTH
)
;

SELECT * FROM active_members;

/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.*/

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

/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books. */

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






/*Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.*/
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
    

/*Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued 
	but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/

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