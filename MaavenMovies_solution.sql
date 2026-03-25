USE mavenmovies; 

/*
1. Identify the primary keys and foreign keys in maven movies db. Discuss the differences
*/
-- Solution:
-- The major difference between Primary key and foreign key is Primary keys uniquely identify a record in a table, while foreign keys establish a link between tables. 
SELECT * FROM information_schema.key_column_usage;


/*
2. List all details of actors
*/
-- Solution:
SELECT * FROM actor;


/*
3. List all customer information from DB.
*/
-- Solution:
SELECT * FROM customer;

/*
4. List different countries.
*/
-- Solution:
SELECT DISTINCT country FROM country;

/*
5. Display all active customers.
*/
-- Solution:
SELECT customer_id, first_name, last_name, email FROM customer WHERE `active`=1;


/*
6. List of all rental IDs for customer with ID 1.
*/
-- Solution:
SELECT rental_id FROM rental WHERE customer_id=1;


/*
7. Display all the films whose rental duration is greater than 5.
*/
-- Solution:
SELECT film_id, title FROM film WHERE rental_duration > 5;


/*
8. List the total number of films whose replacemnet cost is greater than $15 and less than  $20.
*/
-- Solution:
SELECT COUNT(*) FROM film WHERE replacement_cost > 15 AND replacement_cost < 20;


/*
9. Display the count of unique first names of actors.
*/
-- Solution:
SELECT COUNT(DISTINCT first_name) FROM actor;


/*
10. Display the first 10 recods from the customer table
*/
-- Solution:
SELECT * FROM customer LIMIT 10;


/*
11. Display the first 3 records from the customer table whose first name starts with 'b'
*/
-- Solution:
SELECT * FROM customer WHERE first_name LIKE 'b%' LIMIT 3;


/*
12.  Display the names of first 5 movies which are rated as G.
*/
-- Solution:
SELECT title FROM film WHERE rating = 'G' LIMIT 5;


/*
13. Find all customers whose first name starts with "a".
*/
-- Solution:
SELECT * FROM customer WHERE first_name LIKE "a%";


/*
14. Find all customers whose first name ends with "a".
*/
-- Solution:
SELECT * FROM customer WHERE first_name LIKE "%a";


/*
15. Display the list of first 4 cities which start and end with ‘a’.
*/
-- Solution:
SELECT city FROM city WHERE city LIKE 'a%%a' LIMIT 4;


/*
Find all customers whose first name have "NI" in any position.
*/
-- Solution:
SELECT first_name FROM customer WHERE first_name LIKE '%ni%';


/*
Find all customers whose first name have "r" in the second position .
*/
-- Solution:
SELECT first_name FROM customer WHERE first_name LIKE '_r%';


/*
Find all customers whose first name starts with "a" and are at least 5 characters in length.
*/
-- Solution:
SELECT first_name FROM customer WHERE first_name LIKE 'a____%';

/*
Find all customers whose first name starts with "a" and ends with "o".
*/
-- Solution:
SELECT first_name FROM customer WHERE first_name LIKE 'a%o';


/*
Get the films with pg and pg-13 rating using IN operator.
*/
-- Solution:
SELECT title FROM film WHERE rating IN ('PG', 'PG-13');


/*
Get the films with length between 50 to 100 using between operator.
*/
-- Solution:
SELECT * FROM film WHERE length BETWEEN 50 AND 100;


/*
Get the top 50 actors using limit operator.
*/
-- Solution:
SELECT * FROM actor LIMIT 50;


/*
Get the distinct film ids from inventory table.
*/
-- Solution:
SELECT DISTINCT film_id FROM inventory;