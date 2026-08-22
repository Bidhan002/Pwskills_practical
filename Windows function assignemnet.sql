SELECT
    customer_id,
    SUM(amount) AS total_rental_amount,
    RANK() OVER (ORDER BY SUM(amount) DESC) AS customer_rank
FROM rentals
GROUP BY customer_id
ORDER BY total_rental_amount DESC;
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(p.amount) DESC) AS rank
FROM customer c
JOIN payment p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_spent DESC;

SELECT
    f.film_id,
    f.title,
    p.payment_date,
    p.amount,
    SUM(p.amount) OVER (
        PARTITION BY f.film_id
        ORDER BY p.payment_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM film f
JOIN inventory i
    ON f.film_id = i.film_id
JOIN rental r
    ON i.inventory_id = r.inventory_id
JOIN payment p
    ON r.rental_id = p.rental_id
ORDER BY f.film_id, p.payment_date;

SELECT f.film_id, f.title, f.length, AVG(DATEDIFF(r.return_date, r.rental_date)) AS avg_rental_duration FROM film f JOIN inventory i ON f.film_id = i.film_id JOIN rental r ON i.inventory_id = r.inventory_id GROUP BY f.film_id, f.title, f.length ORDER BY f.length, avg_rental_duration DESC;

WITH film_rental_counts AS ( SELECT c.name AS category, f.film_id, f.title, COUNT(r.rental_id) AS rental_count FROM category c JOIN film_category fc ON c.category_id = fc.category_id JOIN film f ON fc.film_id = f.film_id JOIN inventory i ON f.film_id = i.film_id JOIN rental r ON i.inventory_id = r.inventory_id GROUP BY c.name, f.film_id, f.title ), ranked_films AS ( SELECT category, film_id, title, rental_count, RANK() OVER ( PARTITION BY category ORDER BY rental_count DESC ) AS category_rank FROM film_rental_counts ) SELECT category, film_id, title, rental_count, category_rank FROM ranked_films WHERE category_rank <= 3 ORDER BY category, category_rank, title;

SELECT
    customer_id,
    total_rentals,
    total_rentals - AVG(total_rentals) OVER () AS difference_from_average
FROM (
    SELECT
        customer_id,
        COUNT(*) AS total_rentals
    FROM rental
    GROUP BY customer_id
) AS customer_rentals
ORDER BY difference_from_average DESC;

SELECT
    DATE_FORMAT(payment_date, '%Y-%m') AS rental_month,
    SUM(amount) AS monthly_revenue
FROM payment
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY rental_month;

WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(amount) AS total_spending
    FROM payment
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        total_spending,
        NTILE(5) OVER (ORDER BY total_spending DESC) AS spending_group
    FROM customer_spending
)
SELECT
    customer_id,
    total_spending
FROM ranked_customers
WHERE spending_group = 1
ORDER BY total_spending DESC;

WITH category_rentals AS (
    SELECT
        c.name AS category,
        COUNT(r.rental_id) AS rental_count
    FROM category c
    JOIN film_category fc
        ON c.category_id = fc.category_id
    JOIN inventory i
        ON fc.film_id = i.film_id
    JOIN rental r
        ON i.inventory_id = r.inventory_id
    GROUP BY c.name
)
SELECT
    category,
    rental_count,
    SUM(rental_count) OVER (
        ORDER BY rental_count DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM category_rentals
ORDER BY rental_count DESC;

WITH film_rentals AS (
    SELECT
        f.film_id,
        f.title,
        c.name AS category,
        COUNT(r.rental_id) AS rental_count
    FROM film f
    JOIN film_category fc
        ON f.film_id = fc.film_id
    JOIN category c
        ON fc.category_id = c.category_id
    LEFT JOIN inventory i
        ON f.film_id = i.film_id
    LEFT JOIN rental r
        ON i.inventory_id = r.inventory_id
    GROUP BY
        f.film_id,
        f.title,
        c.name
),
category_avg AS (
    SELECT
        film_id,
        title,
        category,
        rental_count,
        AVG(rental_count) OVER (
            PARTITION BY category
        ) AS category_avg_rentals
    FROM film_rentals
)
SELECT
    title,
    category,
    rental_count,
    ROUND(category_avg_rentals, 2) AS category_avg_rentals
FROM category_avg
WHERE rental_count < category_avg_rentals
ORDER BY category, rental_count;

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS rental_month,
        SUM(amount) AS revenue
    FROM payment
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT
    rental_month,
    ROUND(revenue, 2) AS revenue
FROM monthly_revenue
ORDER BY revenue DESC
LIMIT 5;