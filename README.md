# IMDB Movies SQL Analysis

A hands-on SQL practice project exploring relational database concepts using a movies database containing Bollywood and Hollywood films, actors, financials, and languages.

---

## Database Schema

The database (`moviesdb`) consists of five related tables:

```
movies        — movie_id, title, industry, release_year, imdb_rating, studio, language_id
financials    — movie_id, budget, revenue, unit, currency
actors        — actor_id, name, birth_year
movie_actor   — movie_id, actor_id  (junction/link table)
languages     — language_id, name
```

**Entity Relationship:**
- Each movie can have multiple actors (via `movie_actor` link table)
- Each movie belongs to one language
- Each movie has one financial record

---

## Concepts Covered

| Concept | Description |
|---|---|
| INNER JOIN | Return rows common to both tables |
| LEFT / RIGHT JOIN | Include unmatched rows from one side |
| FULL JOIN | Union of LEFT and RIGHT joins using `UNION` |
| CROSS JOIN | Cartesian product of two tables |
| `USING` clause | Cleaner join syntax when column names match |
| Subqueries | Single value, list (`IN`), and table subqueries |
| `ANY` / `ALL` / `SOME` | Scalar comparisons against a list |
| Correlated Subqueries | Subquery referencing the outer query |
| CTEs | `WITH` clause for readable, reusable query blocks |
| `GROUP_CONCAT` | Aggregate multiple rows into a single string |
| `CASE` statements | Conditional logic inside SELECT |
| `CONCAT` | String concatenation across columns |

---

## Example Queries

### 1. Bollywood profit analysis (normalised to millions)
Budgets and revenues are stored in mixed units (Thousands / Millions / Billions).
Used `CASE` to normalise everything to millions for a fair comparison.

```sql
SELECT
    title,
    budget,
    revenue,
    CASE
        WHEN unit = 'Thousands' THEN ROUND((revenue - budget) / 1000, 2)
        WHEN unit = 'Billions'  THEN ROUND((revenue - budget) * 1000, 2)
        ELSE ROUND((revenue - budget), 1)
    END AS profit_in_millions
FROM movies m
JOIN financials f ON m.movie_id = f.movie_id
WHERE industry = 'Bollywood'
ORDER BY profit_in_millions DESC;
```

### 2. Actor filmography using GROUP_CONCAT
Lists all movies each actor has appeared in as a single row.

```sql
SELECT
    a.name,
    GROUP_CONCAT(m.title SEPARATOR ' | ') AS movies
FROM actors a
JOIN movie_actor ma ON ma.actor_id = a.actor_id
JOIN movies m      ON m.movie_id   = ma.movie_id
GROUP BY a.actor_id;
```

### 3. Highest and lowest rated movies using subquery

```sql
SELECT title, imdb_rating
FROM movies
WHERE imdb_rating IN (
    (SELECT MAX(imdb_rating) FROM movies),
    (SELECT MIN(imdb_rating) FROM movies)
);
```

### 4. Actors aged between 70 and 85 — two approaches

**Using a derived table (subquery):**
```sql
SELECT * FROM (
    SELECT name, YEAR(CURDATE()) - birth_year AS age
    FROM actors
) AS actors_age
WHERE age > 70 AND age < 85;
```

**Using a CTE (cleaner, preferred in production):**
```sql
WITH actors_age AS (
    SELECT name, YEAR(CURDATE()) - birth_year AS age
    FROM actors
)
SELECT name AS actor_name, age
FROM actors_age
WHERE age > 70 AND age < 85;
```

### 5. Correlated subquery — movie count per actor

```sql
SELECT
    actor_id,
    name,
    (SELECT COUNT(*) FROM movie_actor
     WHERE actor_id = actors.actor_id) AS no_of_movies
FROM actors
ORDER BY no_of_movies DESC;
```

---

## How to Run

1. Install [MySQL](https://dev.mysql.com/downloads/) or use MySQL Workbench
2. Run `IMDB_Moviedb.sql` to create and populate the database
3. Open `IMDB.sql` and run individual queries to explore

---

## Tools Used

- MySQL 8.0
- MySQL Workbench

---

## Key Learnings

- `JOIN` defaults to `INNER JOIN` in MySQL
- `ANY` returns true if the condition matches **at least one** value in the list
- `ALL` returns true only if the condition matches **every** value in the list
- CTEs using `WITH` produce the same result as derived table subqueries but are far more readable — preferred in production
- Mixed units in financial data require normalisation before any meaningful comparison
