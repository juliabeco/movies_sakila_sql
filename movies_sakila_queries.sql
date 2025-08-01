

-- movies_sakila_queries.sql
-- Author: JBC
-- Description: SQL queries to explore and analyze the Sakila movie rental database
-- Database: Sakila (MySQL)
-- Date: July 2025

-- ----------------------------------------------------------


USE sakila;

-- 1. Select all movie titles without duplicates.

-- First, explore the table of interest and check how many films are there to identify duplicates.
SELECT *
FROM film; -- Output shows 1000 rows

SELECT COUNT(film_id) AS total_movies
FROM film; -- Double-check

-- This query shows all movie titles without duplicates
SELECT DISTINCT title AS movie_title
FROM film;

-- 2. Display the titles of all movies with a "PG-13" rating.
SELECT title AS pg13_title
FROM film
WHERE rating = 'PG-13'; -- 223 movies

-- 3. Find the title and description of all movies that contain the word "amazing" in the description.
SELECT title, description AS amazing_description 
FROM film
WHERE description LIKE '%amazing%'; -- 48 results

-- 4. Find the title of all movies longer than 120 minutes.
SELECT title AS over2h_title
FROM film
WHERE length >120; -- 457 movies

-- 5. Retrieve the names of all actors.

-- 3 OPTIONS TO SOLVE

-- 1. SELECT all first names without removing duplicates
SELECT first_name 
FROM actor; -- 200 rows

-- 2. REMOVE duplicates
SELECT DISTINCT first_name 
FROM actor; -- 128 unique names

-- 3. SELECT full names of all actors
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM actor; -- 200 rows

-- 6. Find the first and last name of actors whose last name includes "Gibson".
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%GIBSON%'; -- 1 actor

-- 7. Find the names of actors with an actor_id between 10 and 20.

-- Include actor_id to confirm we are selecting the correct range (limits included)
SELECT actor_id, first_name 
FROM actor
WHERE actor_id BETWEEN 10 AND 20;

-- 8. Find the titles of the movies that are not rated "R" or "PG-13".

-- 2 EXAMPLES: using != and AND or using NOT IN

-- 1.
SELECT title, rating
FROM film
WHERE rating != 'PG-13' AND rating != 'R'; -- 582 movies

-- 2.
SELECT title, rating
FROM film
WHERE rating NOT IN ('PG-13','R'); -- 582 movies

-- 9. Count the total number of movies by rating and show the rating with the count.

-- 2 interpretations

-- Using the rating column as classification
SELECT COUNT(*) AS total_movies, rating AS classification
FROM film
GROUP BY rating; -- 5 classifications

-- Using the category from the category table
-- Order by total and then alphabetically in case of ties
SELECT c.name AS category, COUNT(f.film_id) AS total_movies
FROM film AS f
LEFT JOIN film_category AS fc USING(film_id)
LEFT JOIN category AS c USING(category_id)
GROUP BY c.name
ORDER BY total_movies DESC, category; -- 16 categories

-- 10. Count the total number of movies rented by each customer and show their ID, first name, and last name.
SELECT c.customer_id AS id, c.first_name, c.last_name, COUNT(r.rental_id) AS total_rented
FROM customer AS c
LEFT JOIN rental AS r USING(customer_id)
GROUP BY id
ORDER BY total_rented DESC; -- 599 customers

-- 11. Count the total number of movies rented by category and show the category name with the count.
SELECT c.name, COUNT(DISTINCT r.rental_id) AS total_rented
FROM category AS c
INNER JOIN film_category AS fc USING(category_id)
INNER JOIN film AS f USING (film_id)
INNER JOIN inventory AS i USING(film_id)
INNER JOIN rental AS r USING(inventory_id)
GROUP BY c.name;

-- 12. Find the average movie duration by rating and show the rating and average duration.

-- Using the rating column as classification
SELECT rating AS classification, ROUND(AVG(length),2) AS avg_duration
FROM film
GROUP BY rating; -- 5 ratings

-- Using the category from the category table
SELECT c.name AS category, ROUND(AVG(f.length),2) AS avg_duration
FROM category AS c
INNER JOIN film_category AS fc USING(category_id)
INNER JOIN film AS f USING (film_id)
INNER JOIN inventory AS i USING(film_id)
INNER JOIN rental AS r USING(inventory_id)
GROUP BY category; -- 16 categories

-- 13. Find the full name of actors appearing in the movie "Indian Love".

-- Optionally include the movie title in the result to verify
SELECT DISTINCT CONCAT(a.first_name, ' ', a.last_name) AS full_name, f.title
FROM actor AS a
INNER JOIN film_actor AS fa USING(actor_id)
INNER JOIN film AS f ON fa.film_id = f.film_id
WHERE f.title = 'Indian Love'; -- 199 actors

-- 14. Show movie titles with "dog" or "cat" in the description.

-- Using LIKE
SELECT title, description
FROM film
WHERE description LIKE '%dog%' OR description LIKE '%cat%'; -- 167 results

-- Using REGEXP
SELECT title, description
FROM film
WHERE description REGEXP 'dog|cat'; -- 167 results

-- 15. Find all movies released between 2005 and 2010.
SELECT title, release_year AS year
FROM film
WHERE release_year BETWEEN 2005 AND 2010;
-- Seems like the DB only contains movies from 2006

-- 16. Find all movies in the same category as "Family".
SELECT f.title, c.name AS category
FROM film AS f
LEFT JOIN film_category AS fc USING(film_id)
LEFT JOIN category AS c USING(category_id)
WHERE c.name = 'Family'; -- 69 movies

-- 17. Find all movies rated "R" and longer than 2 hours.
SELECT title, rating, length AS duration
FROM film
WHERE rating ='R' AND length > 120
ORDER BY length; -- 90 movies

-- BONUS --

-- 18. Show the full names of actors who appeared in more than 10 movies.

-- Only name and surname
SELECT first_name, last_name
FROM actor AS a
LEFT JOIN film_actor AS fa USING(actor_id)
GROUP BY actor_id
HAVING COUNT(fa.film_id) > 10
ORDER BY COUNT(fa.film_id) DESC;

-- Also show the number of movies
SELECT first_name, last_name, COUNT(fa.film_id) AS total_movies
FROM actor AS a
LEFT JOIN film_actor AS fa USING(actor_id)
GROUP BY actor_id
HAVING total_movies > 10
ORDER BY total_movies DESC;

-- 19. Is there any actor/actress who hasn’t appeared in any movie?
SELECT a.actor_id, COUNT(fa.film_id) AS total_movies
FROM actor AS a
LEFT JOIN film_actor AS fa USING(actor_id)
GROUP BY a.actor_id
HAVING total_movies < 1; -- NONE

-- Check who has the fewest appearances
SELECT a.actor_id, COUNT(fa.film_id) AS total_movies
FROM actor AS a
LEFT JOIN film_actor AS fa USING(actor_id)
GROUP BY a.actor_id
ORDER BY total_movies
LIMIT 1; 

-- Alternative using MIN in a subquery
SELECT a.actor_id AS id, COUNT(fa.film_id) AS total_movies
FROM actor AS a
LEFT JOIN film_actor AS fa USING(actor_id)
GROUP BY a.actor_id
HAVING COUNT(fa.film_id) = 
	(SELECT MIN(total_movies)    
	FROM (  SELECT COUNT(fa.film_id) AS total_movies
			FROM actor AS a
			LEFT JOIN film_actor AS fa USING(actor_id)
			GROUP BY a.actor_id) AS min_movies);

-- 20. Show movie categories with an average duration over 120 minutes.
SELECT c.name AS category, ROUND(AVG(f.length),2) AS avg_duration
FROM category AS c
INNER JOIN film_category AS fc USING(category_id)
INNER JOIN film AS f USING(film_id)
INNER JOIN inventory AS i USING(film_id)
INNER JOIN rental AS r USING(inventory_id)
GROUP BY c.name
HAVING avg_duration > 120; -- 4 categories

-- 21. Find actors who appeared in at least 5 movies and show their name and total count.
SELECT first_name AS name, COUNT(DISTINCT fa.film_id) AS total_movies
FROM actor AS a
LEFT JOIN film_actor AS fa USING(actor_id)
GROUP BY actor_id
HAVING total_movies > 5
ORDER BY total_movies DESC;

-- 22. Show titles of all movies rented for more than 5 days. Use a subquery to find rental_ids with a rental period longer than 5 days.

SELECT DISTINCT f.title 
FROM film AS f
JOIN inventory AS i USING(film_id)
JOIN rental AS r USING(inventory_id)
WHERE rental_id IN
(SELECT rental_id
	FROM rental AS r
	WHERE DATEDIFF(return_date, rental_date) > 5)
ORDER BY f.title; -- 955 unique titles

-- Without subquery (simpler version)
SELECT DISTINCT f.title 
FROM film AS f
JOIN inventory AS i USING(film_id)
JOIN rental AS r USING(inventory_id)
WHERE DATEDIFF(r.return_date, r.rental_date) > 5
ORDER BY f.title;


-- 23. Find the first and last names of actors who have not acted in any movie in the "Horror" category.
-- Use a subquery to find the actors who have acted in "Horror" films and then exclude them from the list of actors.

SELECT a.actor_id, a.first_name, a.last_name 
FROM actor AS a
WHERE NOT EXISTS (
    SELECT 1
    FROM film_actor AS fa
    JOIN film AS f USING (film_id)
    JOIN film_category AS fc USING (film_id)
    JOIN category AS c USING (category_id)
    WHERE fa.actor_id = a.actor_id AND c.name = 'Horror'); -- 44 actors

-- 24. Find the titles of movies that are comedies and have a duration longer than 180 minutes in the film table.

SELECT f.title -- , c.name AS category , f.length AS duration
FROM film AS f
LEFT JOIN film_category AS fc USING (film_id)
LEFT JOIN category AS c USING (category_id)
WHERE c.name = 'Comedy' AND f.length > 180;  -- 3 movies

-- 25. Find all actors who have acted together in at least one movie. 
-- Option 1: The query should display the first and last names of the actors and the number of movies they appeared in together.

SELECT 
    a1.actor_id AS actor1_id, -- ID of the first actor
    a1.first_name AS actor1_first_name, 
    a1.last_name AS actor1_last_name,
    a2.actor_id AS actor2_id, -- ID of the second actor
    a2.first_name AS actor2_first_name, 
    a2.last_name AS actor2_last_name,
    COUNT(*) AS movies_together -- number of movies they appeared in together
FROM film_actor fa1
JOIN film_actor fa2 
    ON fa1.film_id = fa2.film_id 
    AND fa1.actor_id < fa2.actor_id 
    -- pair different actors who acted in the same movie,
    -- and use < instead of <> to avoid duplicates (e.g., avoid counting 1-3 and 3-1 as two different pairs)
JOIN actor a1 ON fa1.actor_id = a1.actor_id
JOIN actor a2 ON fa2.actor_id = a2.actor_id
GROUP BY a1.actor_id, a2.actor_id
HAVING COUNT(*) >= 1
ORDER BY movies_together DESC;

-- Option 2: Find all actors who have acted together in at least one movie, using a CTE (Common Table Expression).

WITH actor_pairs AS (
    SELECT
        fa1.actor_id AS actor1_id,
        fa2.actor_id AS actor2_id,
        COUNT(*) AS movies_together
    FROM film_actor fa1
    JOIN film_actor fa2
        ON fa1.film_id = fa2.film_id
        AND fa1.actor_id < fa2.actor_id
    GROUP BY fa1.actor_id, fa2.actor_id
)
SELECT
    ap.actor1_id,
    a1.first_name AS actor1_first_name,
    a1.last_name AS actor1_last_name,
    ap.actor2_id,
    a2.first_name AS actor2_first_name,
    a2.last_name AS actor2_last_name,
    ap.movies_together
FROM actor_pairs ap
JOIN actor a1 ON ap.actor1_id = a1.actor_id
JOIN actor a2 ON ap.actor2_id = a2.actor_id
ORDER BY ap.movies_together DESC;


-- 26. Find the titles of movies that have been rented more than 30 times.
SELECT f.title AS title, COUNT(r.rental_id) AS total_rentals
FROM film AS f
JOIN inventory AS i USING(film_id)
JOIN rental AS r USING(inventory_id)
GROUP BY f.title
HAVING total_rentals > 30
ORDER BY total_rentals DESC; -- 16 movies

-- End of movies_sakila_queries.sql