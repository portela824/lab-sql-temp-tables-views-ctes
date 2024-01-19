USE sakila;

/* Step 1: Create a view*/
CREATE VIEW rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM
    customer c
    JOIN rental r ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id, customer_name, c.email;

/*Step 2: Create a Temporary Table*/
CREATE TEMPORARY TABLE temp_total_paid AS
SELECT
    rs.customer_id,
    SUM(p.amount) AS total_paid
FROM
    rental_summary rs
    JOIN payment p ON rs.customer_id = p.customer_id
GROUP BY
    rs.customer_id;

/*Step 3: Create a CTE and the Customer Summary Report*/
WITH customer_summary_cte AS (
    SELECT
        rs.customer_id,
        rs.customer_name,
        rs.email,
        rs.rental_count,
        ttp.total_paid
    FROM
        rental_summary rs
        JOIN temp_total_paid ttp ON rs.customer_id = ttp.customer_id
)
SELECT
    customer_id,
    customer_name,
    email,
    rental_count,
    total_paid,
    total_paid / rental_count AS average_payment_per_rental
FROM
    customer_summary_cte;
