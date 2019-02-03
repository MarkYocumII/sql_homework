#Mark Yocum
#SQL Homework

USE sakila;

SET SQL_SAFE_UPDATES = 0;

#1a Display first and last name of all actors in the table

SELECT first_name, last_name
FROM actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT concat(first_name, " ", last_name)
AS "Actor Name"
FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * 
FROM actor
WHERE last_name LIKE "%GEN%";

# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order

SELECT * 
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

#  2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country 
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

# 3a. You want to keep a description of each actor. 
# You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` 
# (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

ALTER TABLE actor
ADD description BLOB;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

ALTER TABLE actor
DROP COLUMN description;

# 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, 
COUNT(last_name)
AS "Last Name Count"
FROM actor
GROUP BY last_name;

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, 
COUNT(last_name)
AS Last_Name_Count
FROM actor
GROUP BY last_name
HAVING Last_Name_Count >= 2 ;

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
# In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT staff.first_name, staff.last_name, address.address
FROM address
INNER JOIN staff
ON staff.address_id=address.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT staff.first_name, staff.last_name, month(payment.payment_date) as month_pay, year(payment.payment_date) as year_pay, sum(payment.amount) as sum_payments
FROM payment
LEFT JOIN staff
ON staff.staff_id=payment.staff_id
GROUP BY staff.last_name, month_pay, year_pay
HAVING month_pay = 8 AND year_pay = 2005;

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT title, COUNT(actor_id) as actor_count
FROM(
	SELECT film.title, film_actor.actor_id
	FROM film_actor
	INNER JOIN film
	ON film.film_id = film_actor.film_id) AS film_summary
GROUP BY title;
    
# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT title, COUNT(inventory_id) as inventory_count
FROM(
	SELECT inventory.inventory_id, film.title
	FROM inventory
	INNER JOIN film
	ON film.film_id = inventory.film_id) AS inventory_summary
GROUP BY title
HAVING title = "HUNCHBACK IMPOSSIBLE";

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT first_name, last_name, SUM(amount) as total_amount_paid
FROM(
	SELECT customer.first_name, customer.last_name, payment.amount
	FROM payment
	INNER JOIN customer
	ON customer.customer_id = payment.customer_id) as payment_summary
GROUP BY last_name;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
# As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
# Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title
FROM(
	SELECT film.title, language.name 
	FROM language
	INNER JOIN film
	ON film.language_id = language.language_id) as language_summary
WHERE title LIKE "K%" 
OR title LIKE "Q%";

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
FROM actor
WHERE actor_id
IN(
	SELECT actor_id
	FROM film_actor
	WHERE film_id
	IN(
		SELECT film_id
		FROM film
		WHERE title = "ALONE TRIP"
		)
	);

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.

SELECT first_name, last_name, email, country
FROM(
	SELECT customer.first_name, customer.last_name, customer.email, country.country
	FROM (((address
	INNER JOIN customer ON customer.address_id = address.address_id)
	INNER JOIN city on address.city_id = city.city_id)
	INNER JOIN country on city.country_id = country.country_id)) AS country_emails
WHERE country = "Canada";

#* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

SELECT title, name
FROM(
	SELECT film.title, film_category.category_id, category.name
	FROM ((film_category
	INNER JOIN film ON film.film_id = film_category.film_id)
	INNER JOIN category ON category.category_id = film_category.category_id)) as film_categories
WHERE name = "Family";

# 7e. Display the most frequently rented movies in descending order.

SELECT title, COUNT(rental_id) AS rental_count
FROM(
	SELECT film.title, rental.rental_id
	FROM (film
	LEFT JOIN inventory ON film.film_id = inventory.film_id)
	INNER JOIN rental ON rental.inventory_id = inventory.inventory_id) as total_rentals
GROUP BY title
ORDER BY rental_count DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.


SELECT store_id, SUM(amount) as total_sales
FROM(
	SELECT store.store_id, staff.staff_id, payment.amount
	FROM (staff
	LEFT JOIN store ON store.store_id = staff.store_id)
	LEFT JOIN payment ON payment.staff_id = staff.staff_id) as store_sales_totals
GROUP BY store_id;

# 7g. Write a query to display for each store its store ID, city, and country.

SELECT store_id, city, country
FROM ((address
JOIN store on store.address_id = address.address_id)
JOIN city on address.city_id = city.city_id)
JOIN country on city.country_id = country.country_id;

# 7h. List the top five genres in gross revenue in descending order. 
#(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT name, SUM(amount) as category_sales
FROM(
	SELECT name, amount
	FROM (((payment
	INNER JOIN rental ON payment.rental_id = rental.rental_id)
	INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id)
	INNER JOIN film_category ON inventory.film_id = film_category.film_id)
	INNER JOIN category ON film_category.category_id = category.category_id) as category_sales_summary
GROUP BY name
ORDER BY category_sales DESC limit 5;

#* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five AS
SELECT name, SUM(amount) as category_sales
FROM(
	SELECT name, amount
	FROM (((payment
	INNER JOIN rental ON payment.rental_id = rental.rental_id)
	INNER JOIN inventory ON inventory.inventory_id = rental.inventory_id)
	INNER JOIN film_category ON inventory.film_id = film_category.film_id)
	INNER JOIN category ON film_category.category_id = category.category_id) as category_sales_summary
GROUP BY name
ORDER BY category_sales DESC;

# 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five limit 5;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_five;