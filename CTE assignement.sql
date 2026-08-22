CREATE TABLE film_special_features (
    film_id INT,
    special_feature VARCHAR(50),
    PRIMARY KEY (film_id, special_feature),
    FOREIGN KEY (film_id) REFERENCES film(film_id)
    
    1. Structure of film_category

The table contains:

Column	Description
film_id	ID of the film
category_id	ID of the category
last_update	Last update timestamp

The primary key is a composite key:

PRIMARY KEY (film_id, category_id)
2. How to determine whether it is in 2NF

A table is in 2NF if:

It is already in 1NF.
Every non-key attribute is fully dependent on the entire primary key, not just part of it.

Here, the composite key is:

(film_id, category_id)

The only non-key attribute is:

last_update

We need to check whether last_update depends on both film_id and category_id, rather than only one of them.

Since there is no obvious partial dependency of last_update on just film_id or just category_id, the film_category table satisfies 2NF.

3. What if it violated 2NF?

Suppose we had a table like this:

film_id	category_id	film_title	category_name
1	6	Academy Dinosaur	Documentary
1	7	Academy Dinosaur	Drama
2	6	Ace Goldfinger	Documentary

The primary key is:

(film_id, category_id)

But:

film_title depends only on film_id.
category_name depends only on category_id.

These are partial dependencies, so the table violates 2NF.

4. Normalize it to 2NF

Split the table into separate tables:

Film table

film_id → film_title

Category table

category_id → category_name

Film_Category table

film_id + category_id

The resulting structure is:

film
---------
film_id (PK)
title
...

category
---------
category_id (PK)
name
...

film_category
---------
film_id (FK)
category_id (FK)
PRIMARY KEY (film_id, category_id)

It is already in 2NF.
There are no transitive dependencies.

In simple terms, a non-key column should depend directly on the primary key, not on another non-key column.

2. Example of a 3NF violation

Consider a hypothetical version of the Sakila customer table:

customer_id	first_name	last_name	address_id	city_id	city	country_id	country
1	Mary	Smith	5	300	Lethbridge	20	Canada
2	John	Doe	6	301	Woodridge	20	Canada

The primary key is:

customer_id

There are transitive dependencies such as:

customer_id → address_id → city_id → city → country_id → country

For example:

customer_id determines address_id.
address_id determines city_id.
city_id determines city and country_id.
country_id determines country.

Therefore, information such as city and country does not depend directly on customer_id. It depends on other non-key attributes. This creates transitive dependencies and violates 3NF.

3. How Sakila actually handles this

Interestingly, the actual Sakila database is already designed to avoid this problem. It separates this information into related tables:

customer
---------
customer_id (PK)
first_name
last_name
address_id (FK)

address
---------
address_id (PK)
address
district
city_id (FK)

city
---------
city_id (PK)
city
country_id (FK)

country
---------
country_id (PK)
country
4. Steps to normalize to 3NF

If all this information were stored in one customer table, we would:

Step 1 — Keep customer-specific information

customer_id
first_name
last_name
address_id

Step 2 — Move address information

address_id
address
district
city_id

Step 3 — Move city information

city_id
city
country_id

Step 4 — Move country information

country_id
country
Final answer

The actual Sakila customer table does not violate 3NF because Sakila separates customer, address, city, and country information into different tables. A denormalized customer table containing all these attributes would have transitive dependencies, such as customer_id → address_id → city_id → country_id. To achieve 3NF, these dependencies are separated into the customer, address, city, and country tables.

Step 1: Unnormalized Form (UNF)

Suppose we store film information and all its categories in one table:

film_id	film_title	categories
1	Academy Dinosaur	Documentary, Family
2	Ace Goldfinger	Action
3	Adaptation Holes	Documentary, Drama

The problem is that categories contains multiple values in one cell.

This violates 1NF, because each field should contain a single atomic value.

Step 2: Convert UNF → 1NF

Separate the multiple categories into individual rows:

film_id	film_title	category
1	Academy Dinosaur	Documentary
1	Academy Dinosaur	Family
2	Ace Goldfinger	Action
3	Adaptation Holes	Documentary
3	Adaptation Holes	Drama

Now each cell contains a single value.

The natural composite key is:

(film_id, category)

However, we have a problem:

film_id → film_title

film_title depends only on part of the composite key (film_id), not the complete key.

Therefore, the table is in 1NF but not 2NF.

Step 3: Convert 1NF → 2NF

We remove the partial dependency by separating film information from the film-category relationship.

Film table
film_id	film_title
1	Academy Dinosaur
2	Ace Goldfinger
3	Adaptation Holes
CREATE TABLE film (
    film_id INT PRIMARY KEY,
    title VARCHAR(255)
);
Film_Category table
film_id	category
1	Documentary
1	Family
2	Action
3	Documentary
3	Drama
CREATE TABLE film_category (
    film_id INT,
    category VARCHAR(50),
    PRIMARY KEY (film_id, category),
    FOREIGN KEY (film_id) REFERENCES film(film_id)
);

Now:

film_id → film_title exists only in the film table.
(film_id, category) identifies each relationship in film_category.
There are no partial dependencies in film_category.

Therefore, the structure has reached 2NF.

Normalization Summary
UNF
 ↓
Multiple categories stored in one cell
 ↓
1NF
 ↓
Each category stored in a separate row
 ↓
Partial dependency: film_id → film_title
 ↓
2NF
 ↓
Separate film information from film-category relationships

WITH actor_film_count AS (
    SELECT
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        COUNT(fa.film_id) AS film_count
    FROM actor a
    JOIN film_actor fa
        ON a.actor_id = fa.actor_id
    GROUP BY
        a.actor_id,
        a.first_name,
        a.last_name
)
SELECT DISTINCT
    actor_name,
    film_count
FROM actor_film_count
ORDER BY film_count DESC, actor_name;

WITH RECURSIVE category_hierarchy AS (
    -- Anchor: top-level categories
    SELECT
        category_id,
        name,
        parent_category_id,
        0 AS level,
        CAST(name AS CHAR(500)) AS category_path
    FROM category
    WHERE parent_category_id IS NULL

    UNION ALL

    -- Recursive: find subcategories
    SELECT
        c.category_id,
        c.name,
        c.parent_category_id,
        ch.level + 1,
        CONCAT(ch.category_path, ' > ', c.name)
    FROM category c
    JOIN category_hierarchy ch
        ON c.parent_category_id = ch.category_id
)
SELECT
    category_id,
    name,
    parent_category_id,
    level,
    category_path
FROM category_hierarchy
ORDER BY category_path;
WITH film_details AS (
    SELECT
        f.title AS film_title,
        l.name AS language_name,
        f.rental_rate
    FROM film f
    JOIN language l
        ON f.language_id = l.language_id
)
SELECT
    film_title,
    language_name,
    rental_rate
FROM film_details
ORDER BY film_title;

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(p.amount) AS total_revenue
    FROM customer c
    JOIN payment p
        ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(total_revenue, 2) AS total_revenue
FROM customer_revenue
ORDER BY total_revenue DESC;

WITH ranked_films AS (
    SELECT
        film_id,
        title,
        length AS rental_duration,
        RANK() OVER (
            ORDER BY length DESC
        ) AS rental_duration_rank
    FROM film
)
SELECT
    film_id,
    title,
    rental_duration,
    rental_duration_rank
FROM ranked_films
ORDER BY rental_duration_rank, title;

WITH frequent_customers AS (
    SELECT
        customer_id,
        COUNT(rental_id) AS total_rentals
    FROM rental
    GROUP BY customer_id
    HAVING COUNT(rental_id) > 2
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.active,
    fc.total_rentals
FROM customer c
JOIN frequent_customers fc
    ON c.customer_id = fc.customer_id
ORDER BY fc.total_rentals DESC;

WITH monthly_rentals AS (
    SELECT
        DATE_FORMAT(rental_date, '%Y-%m') AS rental_month,
        COUNT(rental_id) AS total_rentals
    FROM rental
    GROUP BY DATE_FORMAT(rental_date, '%Y-%m')
)
SELECT
    rental_month,
    total_rentals
FROM monthly_rentals
ORDER BY rental_month;

WITH customer_payments AS (
    SELECT
        customer_id,
        payment_method,
        SUM(amount) AS total_payment
    FROM payment
    GROUP BY
        customer_id,
        payment_method
)
SELECT
    customer_id,
    COALESCE(SUM(CASE
        WHEN payment_method = 'Credit Card'
        THEN total_payment ELSE 0
    END), 0) AS credit_card_payment,
    COALESCE(SUM(CASE
        WHEN payment_method = 'Cash'
        THEN total_payment ELSE 0
    END), 0) AS cash_payment,
    COALESCE(SUM(CASE
        WHEN payment_method = 'Online'
        THEN total_payment ELSE 0
    END), 0) AS online_payment
FROM customer_payments
GROUP BY customer_id
ORDER BY customer_id;


    SELECT
        fa1.film_id,
        fa1.actor_id AS actor1_id,
        fa2.actor_id AS actor2_id
    FROM film_actor fa1
    JOIN film_actor fa2
        ON fa1.film_id = fa2.film_id
       AND fa1.actor_id < fa2.actor_id
)
SELECT
    f.title AS film_title,
    CONCAT(a1.first_name, ' ', a1.last_name) AS actor_1,
    CONCAT(a2.first_name, ' ', a2.last_name) AS actor_2
FROM actor_pairs ap
JOIN film f
    ON ap.film_id = f.film_id
JOIN actor a1
    ON ap.actor1_id = a1.actor_id
JOIN actor a2
    ON ap.actor2_id = a2.actor_id
ORDER BY f.title, actor_1, actor_2;

ITH RECURSIVE staff_hierarchy AS (
    -- Start with the specific manager
    SELECT
        staff_id,
        first_name,
        last_name,
        manager_id,
        0 AS hierarchy_level
    FROM staff
    WHERE staff_id = 1

    UNION ALL

    -- Find employees who report to the manager
    SELECT
        s.staff_id,
        s.first_name,
        s.last_name,
        s.manager_id,
        sh.hierarchy_level + 1
    FROM staff s
    JOIN staff_hierarchy sh
        ON s.manager_id = sh.staff_id
)
SELECT
    staff_id,
    first_name,
    last_name,
    manager_id,
    hierarchy_level
FROM staff_hierarchy
WHERE hierarchy_level > 0
ORDER BY hierarchy_level, last_name;
How it works

Anchor query starts with the specific manager:

WHERE staff_id = 1

Recursive part finds employees whose manager_id matches the current employee's staff_id:

ON s.manager_id = sh.staff_id