-- Question 1: Which staff members made the highest revenue for each store and deserve a bonus for the year 2017?

-- Solution 1:
WITH RankedRevenue AS (
    SELECT 
        s.staff_id,
        s.store_id,
        SUM(p.amount) AS total_revenue,
        RANK() OVER (PARTITION BY s.store_id ORDER BY SUM(p.amount) DESC) AS revenue_rank
    FROM 
        payment p
    JOIN staff s ON p.staff_id = s.staff_id
    WHERE 
        p.payment_date >= '2017-01-01' AND p.payment_date <= '2017-12-31'
    GROUP BY 
        s.staff_id, s.store_id
)
SELECT 
    staff_id, store_id, total_revenue
FROM 
    RankedRevenue
WHERE revenue_rank = 1;


-- Solution 2:
SELECT 
    s.staff_id, 
    s.store_id, 
    SUM(p.amount) AS total_revenue
FROM 
    payment p
JOIN staff s ON p.staff_id = s.staff_id
WHERE 
    p.payment_date >= '2017-01-01' AND p.payment_date <= '2017-12-31'
GROUP BY 
    s.staff_id, s.store_id
HAVING 
    SUM(p.amount) = (SELECT MAX(total_revenue)
                        FROM (SELECT store_id, staff_id, SUM(amount) AS total_revenue
                                FROM payment
                                WHERE YEAR(payment_date) = 2017
                                GROUP BY store_id, staff_id) AS temp
                    WHERE temp.store_id = s.store_id);


-- Question 2: Which five movies were rented more than the others, and what is the expected age of the audience for these movies?

-- Solution 1:
SELECT 
    f.film_id, 
    f.title AS movie_title, 
    COUNT(r.rental_id) AS rental_count, 
    AVG(f.length) AS expected_age
FROM 
    film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 
    f.film_id, f.title
ORDER BY 
    rental_count DESC
LIMIT 5;


-- Solution 2:
SELECT 
    f.film_id, 
    f.title AS movie_title, 
    COUNT(r.rental_id) AS rental_count, 
    AVG(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM c.birth_date)) AS expected_age
FROM 
    film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id
GROUP BY 
    f.film_id, f.title
ORDER BY 
    rental_count DESC
LIMIT 5;


-- Question 3: Which actors/actresses didn't act for a longer period of time than the others?

-- Solution 1:
SELECT 
    a.actor_id, 
    a.first_name, 
    a.last_name, 
    MAX(IFNULL(r.return_date, CURRENT_DATE)) AS last_return_date
FROM 
    actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
LEFT JOIN inventory i ON fa.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 
    a.actor_id, a.first_name, a.last_name
ORDER BY 
    last_return_date ASC;


-- Solution 2:
SELECT 
    a.actor_id, 
    a.first_name, 
    a.last_name, 
    DATEDIFF(COALESCE(MAX(r.return_date), CURRENT_DATE), COALESCE(MIN(r.rental_date), CURRENT_DATE)) AS inactive_period
FROM 
    actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
LEFT JOIN inventory i ON fa.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 
    a.actor_id, a.first_name, a.last_name
ORDER BY 
    inactive_period DESC;
