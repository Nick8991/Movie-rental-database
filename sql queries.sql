/*
Question 1

Query the database to list all films and the number of times that each film has been rented
*/


WITH t1 AS(SELECT cat.name category,
                  f.title film_title,
                  r.rental_id count_rent
           FROM category cat
           JOIN film_category fcat
           ON cat.category_id = fcat.category_id
           JOIN film f
           ON f.film_id = fcat.film_id
           JOIN inventory inv
           ON f.film_id = inv.film_id
           JOIN rental r
           ON r.inventory_id = inv.inventory_id),

      t2 AS(SELECT film_title, category, count_rent,
                    CASE WHEN category IN ('Animation', 'Children', 'Classics',
                                           'Comedy', 'Family', 'Music') THEN '1'
                    ELSE '2' END AS category_type
            FROM t1
                    )

SELECT DISTINCT(film_title), category,
       COUNT(count_rent) OVER (PARTITION BY film_title ORDER BY category) count_rented
FROM t2
WHERE category_type = '1'
ORDER BY 2,1;






/*
Question 2

Query that counts the number of films in each category

*/


SELECT "category name", COUNT(film_id) "Count category"
FROM
      (
          SELECT cat.name "category name", cat.category_id, f.film_id,
                 f.title, f.release_year
          FROM category cat
          JOIN film_category fcat
          ON cat.category_id = fcat.category_id
          JOIN film f
          ON fcat.film_id = f.film_id
      ) t1
GROUP BY 1
ORDER BY 2 DESC;







/*
Question 3

Who are the top 10 paying customers and the amount they each paid
*/

SELECT full_name, DATE_PART('year',monthly),
       SUM(amount) total_yearly_payment
FROM   (
          SELECT c.first_name || ' ' || c.last_name full_name,
                 p.amount, DATE_TRUNC('day', p.payment_date) monthly
          FROM customer c
          JOIN payment p
          ON c.customer_id = p.customer_id
          WHERE active = 1
      )sub1
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;









/*
Question 4

What are the monthly rentals  for staff with highest number of total rentals

*/





SELECT sub2."full name",  DATE_PART('month', sub3.rental_date)  "Monthly count", COUNT(sub3.rental_id)

FROM   (
        SELECT sub1."full name", "rent month", country, COUNT(rental_id)
        FROM  (
                SELECT stf.first_name || ' ' || stf.last_name "full name", DATE_PART('year', r.rental_date) "rent month",
                 r.rental_id, ctry.country country
                FROM  country ctry
                JOIN city ct
                ON ctry.country_id = ct.country_id
                JOIN address ad
            ON ct.city_id = ad.city_id
            JOIN staff stf
            ON ad.address_id = stf.address_id
            JOIN rental r
            ON r.staff_id = stf.staff_id

) sub1
WHERE "rent month" = '2005'
GROUP BY 1,2,3
ORDER BY 4 DESC
LIMIT 1
)sub2
JOIN (
  SELECT stf.first_name || ' ' || stf.last_name "full name", r.rental_date,
         r.rental_id, ctry.country country
  FROM  country ctry
  JOIN city ct
  ON ctry.country_id = ct.country_id
  JOIN address ad
  ON ct.city_id = ad.city_id
  JOIN staff stf
  ON ad.address_id = stf.address_id
  JOIN rental r
  ON r.staff_id = stf.staff_id
) sub3
ON sub2."full name" = sub3."full name"
GROUP BY 1,2
ORDER BY 3;
