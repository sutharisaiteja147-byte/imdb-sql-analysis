USE moviesdb;

# Inner join ____
SELECT 
	*
FROM movies m
Inner JOIN financials f     # default join trigger to inner join which is common in both the table 
ON m.movie_id = f.movie_id;

#Outer Left join____
SELECT  
	m.movie_id, title, industry
FROM movies m
Left JOIN financials f        # it will take left table with first then join second table on the right 
ON m.movie_id = f.movie_id;   # we may see some null values because right table have no values  

#Right Join____ 

SELECT 
	f.movie_id, title, industry
FROM movies m
RIGHT JOIN financials f       # it will take right table first and then left unknown values will shown as null 
ON m.movie_id = f.movie_id;   #we need be carefull while dealing with the reference m.movie_id and f.movie_id

#full join is a mix of both using UNION built-in funtion___
SELECT  
	m.movie_id, title, industry
FROM movies m
Left JOIN financials f        # union of both the joins left U right 
ON m.movie_id = f.movie_id    # taking union of both the table it will shown entire table data 
UNION

SELECT  
	f.movie_id, 
    title, 
    industry                         #I need to keep in mind that number of selected coloumns should be same for both the joins
FROM movies m
Right Outer JOIN financials f    
ON m.movie_id = f.movie_id; 

# we can use Using built-in function to avoid on for example ___
SELECT 
	movie_id, title, industry        # here i am not getting amiguty due to using "using" built-in function 
FROM movies m                        #and it will figure out from which table it needs to take reference from!
Left JOIN financials f 
USING(movie_id)                      # these way we can avoid the ON 

# we can join using multiple tables as well using AND operator for example 
# after join -> on m.moive_id = f.movie_id AND m.col2 = f.col2
# inner join is the default join and left right and full are the outer joins

# cross Join _____
SELECT  
    CONCAT(title, "-> ",studio, "-" , revenue) as movie_industry_revenue,
    (revenue - budget) as profit 
FROM movies
CROSS JOIN financials;
# concat is a built - in function used to concatinate the words in the coloums we can perform arthematic operation in the coloumns selection itself 
# well when it comes to cross join it will do cartesian production of two table columns in simple terms it will place side by side each table 


#Q1 retrive the movie title, budget, revenue, profit from movie_db where industry is bollywood.
SELECT  
    m.movie_id,
    title,
    budget,
    revenue,
    (revenue - budget) as profit,
    unit
FROM movies m 
JOIN financials f
ON m.movie_id = f.movie_id
WHERE industry = "bollywood"
ORDER BY profit desc ;
# here we got the answer considering units i came to know that some of them are in thousands and most of them are millions 
#pather panchali units are in thousands it doesn't mean it has highest profit 

SELECT  
    m.movie_id,
    title,
    budget,
    revenue,
    CASE
    when unit = "thousands" then round((revenue - budget)/1000,2)
    when unit = "billions" then round((revenue - budget)*1000, 2)
    ELSE round((revenue - budget),1)
    END as profit_in_mil
FROM movies m
JOIN financials f
ON m.movie_id = f.movie_id
WHERE industry = "bollywood"
ORDER BY profit_in_mil DESC;
#using case statements we can convert the units to million 

#making use of group_concat function using link table like movie_actor
SELECT 
    m.title, group_concat(a.name separator " | ") as actors
FROM movies m
JOIN movie_actor ma ON ma.movie_id = m.movie_id
JOIN actors a ON a.actor_id = ma.actor_id
GROUP BY m.movie_id;
 
# now i group_concated movie.title using group by of actor_id  
SELECT 
    a.name,
    group_concat(m.title SEPARATOR " | ") AS movies 
FROM actors a
JOIN movie_actor ma ON ma.actor_id = a.actor_id
JOIN movies m ON m.movie_id = ma.movie_id
GROUP BY a.actor_id;

#SUBQUERIES
#select a movie with highest imdb_rating 
SELECT 
    title,
    imdb_rating
FROM movies 
ORDER BY imdb_rating desc  limit 5;
 
# Another way of righting using subqueries 
SELECT 
    title,
    imdb_rating
FROM movies
WHERE imdb_rating = (SELECT MAX(imdb_rating) FROM movies);
# The above query returned a single value we can write a query to return multiple or list of values 

#return a list of value 
SELECT *
FROM movies 
WHERE imdb_rating in (
                      (SELECT MAX(IMDB_RATING) FROM MOVIES), 
                      (SELECT MIN(IMDB_RATING) FROM MOVIES));
                      
#RETURNS A table 
#Q2  SELECT all the actors whose age > 70 and < 85
SELECT 
     name,
     year(curdate())-birth_year as age 
FROM actors
WHERE age >70 # throws an error because it is an dervied column

#but we can use these as a new table like these 

SELECT * FROM (SELECT 
     name,
     year(curdate())-birth_year as age 
FROM actors) AS actors_age
WHERE age > 70 AND age < 85

# we can write these query in mutlple ways but i am trying to give an idea of subquery 
#the other way of writing query is 
SELECT 
    name,
    YEAR(CURDATE()) - birth_year AS age
FROM actors
WHERE YEAR(CURDATE()) - birth_year > 70
  AND YEAR(CURDATE()) - birth_year < 85;
  
#select actors who acted in any of these movies (101,110,121)
SELECT * FROM ACTORS WHERE ACTOR_ID IN (
                                      SELECT ACTOR_ID FROM MOVIE_ACTOR WHERE MOVIE_ID IN(101,110,121)
                                      );
                                      
#SAME OUTPUT WE CAN GENERATE USING ANY OPERATOR 
SELECT * FROM ACTORS WHERE ACTOR_ID = ANY (
                                      SELECT ACTOR_ID FROM MOVIE_ACTOR WHERE MOVIE_ID IN(101,110,121)
                                      );
# in the above query it will take the minimum value to consider any 
#NOW ALL operator
#Q Select all movies whose rating is greater than *any* of the marvel rating 

SELECT * FROM MOVIES WHERE imdb_rating = ANY (
                            SELECT imdb_rating FROM MOVIES WHERE STUDIO ="MARVEL STUDIOS"
                            );
                            
						# QUERY_2
SELECT * FROM MOVIES WHERE imdb_rating IN (
    SELECT imdb_rating
    FROM MOVIES
    WHERE studio = 'MARVEL STUDIOs'
);
# QUERY 1 AND 2 RETURNS SAME NUMBER OF LINES OF CODE 
               #QUERY_3
SELECT * FROM MOVIES WHERE imdb_rating > ANY (
                            SELECT MIN(imdb_rating) FROM MOVIES WHERE STUDIO ="MARVEL STUDIOS"
                            );
                            
#QUERY 4
SELECT * FROM MOVIES WHERE imdb_rating > SOME (
                            SELECT MIN(imdb_rating) FROM MOVIES WHERE STUDIO ="MARVEL STUDIOS"
                            );
#QUERY 3 AND 4 RETURNS SAME OUTPUT BUT DIFFERENT SYNTAX QUERY 3 USED "ANY" AND 4 USED "SOME"
#THIS QUERIES ARE USED FOR USE CASES ONLY 
#ANY USES MINIMUM OF NUMBER IN A SUBQUERY
#Q Select all movies whose rating is greater than *ALL* of the marvel rating 
SELECT * FROM MOVIES WHERE imdb_rating > ALL (
                            SELECT MIN(imdb_rating) FROM MOVIES WHERE STUDIO ="MARVEL STUDIOS"
                            );

#IN, ANY, ALL EXPECT A LIST AS INPUT 

#CO_RELATED SUBQUERY
#Q SELECT THE ACTOR ID, ACTOR NAME AND THE TOTAL NUMBER OF MOVIES THEY ACTED IN.
SELECT 
      a.ACTOR_ID,
      a.NAME,
      COUNT(*) AS NO_OF_MOVIES
FROM movie_actor ma
JOIN actors a 
ON ma.actor_id = a.actor_id
GROUP BY ACTOR_ID
ORDER BY NO_OF_MOVIES DESC;
# the above code is in_general way of writing the code 

# now co-related subquery which will relate to out of scope or outer table 
SELECT 
    Actor_id,
    Name, 
    (select count(*) from movie_actor 
     where actor_id = actors.actor_id ) as No_Of_Movies
FROM actors 
ORDER BY NO_OF_MOVIES DESC;

#observe carefully that i am not using any joins here but i am calling data from two tables 
#one is actors table and the other is movie_actor here actors table is related to outer table or outer query where i have used inside column
#basically actors.actor_id doing a itration through out the actor_id and counting using count function 

#COMMON TABLE EXPRESSION (CTE's)

#Get all actors whose age is between 70 and 85
SELECT * FROM (SELECT 
     name,
     year(curdate())-birth_year as age 
FROM actors) AS actors_age
WHERE age > 70 AND age < 85;

#now by using cte's
with actors_age as (
     SELECT 
         name,
         year(curdate())-birth_year as age 
     FROM actors
)
SELECT 
	name AS Actor_Name, 
    Age
FROM actors_age
WHERE age > 70 AND age < 85;

#both queries work in same way but with clean and neat apperance for CTE's most widely used in real world don't neglect!

#EXPLAIN ANALYSIS go through documentation to know about it 