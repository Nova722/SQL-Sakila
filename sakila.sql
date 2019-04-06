USE sakila;
SELECT * FROM sakila.actor;
USE sakila;
-- 1a show first and last names
SELECT first_name, last_name
FROM actor;

-- 1b column with first and last name combined
SELECT CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS 'Actor Name'
FROM actor;

-- 2a You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id,first_name, last_name
FROM actor
WHERE first_name = 'JOE';

-- 2b. Find all actors whose last name contain the letters GEN
SELECT *
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country = 'Afghanistan' OR country = 'Bangladesh' OR country = 'China';

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
-- as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(actor_id) as 'lastnames_count' FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(actor_id) as 'lastnames_count' FROM actor
GROUP BY last_name
HAVING lastnames_count > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS'; -- it appears there was no HARPO in the dataset, it was listed correctly

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
SELECT *
FROM actor
WHERE last_name = 'WILLIAMS'; -- there are no harpo williams, the table is correct

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
-- Or you could also
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'address'; -- Entire table is recreated

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT first_name, last_name, address 
FROM staff
JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.staff_id, staff.first_name, staff.last_name, sum(payment.amount) as 'total_amount'
FROM staff
JOIN payment
ON staff.staff_id = payment.staff_id
WHERE payment.payment_date like '2005-08%'
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) AS actor_count
FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film.title
ORDER BY actor_count desc; -- listed in descending order for useability

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, COUNT(inventory.film_id) AS inventory_count
FROM film
JOIN inventory
ON film.film_id = inventory.film_id
WHERE film.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
--  List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name,  SUM(payment.amount) AS total_amount_paid
FROM customer
JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of 
-- movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE language_id = (SELECT language_id FROM language WHERE name = 'English')
AND title LIKE 'K%' OR title LIKE 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor WHERE film_id =  (SELECT film_id FROM film WHERE title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
-- Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email FROM customer
JOIN address
ON address.address_id = customer.address_id
JOIN city
ON city.city_id = address.city_id
JOIN country
ON city.country_id = country.country_id
WHERE country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT title
FROM film
WHERE film_id IN (SELECT film_id FROM  film_category WHERE category_id IN 
(SELECT category_ID FROM category WHERE name = 'family'));

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(film.title) AS 'Rental Frequency'
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id 
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
GROUP BY film.film_id
ORDER BY frequency desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT staff.store_id, SUM(payment.amount) AS store_revenue
FROM staff
INNER JOIN payment
ON staff.staff_id = payment.staff_id
GROUP BY staff.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address
ON store.address_id = address.address_id
INNER JOIN city
ON city.city_id = address.city_id
INNER JOIN country
ON country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
-- category, film_category, inventory, payment, and rental.)
SELECT category.name, SUM(payment.amount) AS 'Top_Grossing_Genres'
FROM category
JOIN film_category
ON category.category_id = film_category.category_id 
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON rental.inventory_id = inventory.inventory_id
JOIN payment
ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY Top_Grossing_Genres desc
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view top_five as
	SELECT category.name, SUM(payment.amount) AS 'Top_Grossing_Genres'
FROM category
JOIN film_category
ON category.category_id = film_category.category_id 
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON rental.inventory_id = inventory.inventory_id
JOIN payment
ON payment.rental_id = rental.rental_id
GROUP BY category.name
ORDER BY Top_Grossing_Genres desc
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_five;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five;
