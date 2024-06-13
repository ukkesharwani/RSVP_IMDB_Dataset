USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:


SELECT table_name, table_rows
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'imdb';


/*
OUTPUT
director_mapping	3867
genre	            14662
movie	            6122
names	             27412
ratings				7927
role_mapping		16432

*/
-- Q2. Which columns in the movie table have null values?
-- Type your code below:

WITH null_info
     AS (SELECT Count(1) AS null_values
         FROM   movie
         WHERE  id IS NULL
         UNION ALL
         SELECT Count(1)
         FROM   movie
         WHERE  title IS NULL
         UNION ALL
         SELECT Count(1)
         FROM   movie
         WHERE  year IS NULL
         UNION ALL
         SELECT Count(1)
         FROM   movie
         WHERE  date_published IS NULL
         UNION ALL
         SELECT Count(1)
         FROM   movie
         WHERE  duration IS NULL
         UNION ALL
         SELECT Count(1)
         FROM   movie
         WHERE  country IS NULL
         UNION ALL
         SELECT Count(1)
         FROM   movie
         WHERE  worlwide_gross_income IS NULL
         UNION ALL
         SELECT Count(1)
         FROM   movie
         WHERE  languages IS NULL
         UNION ALL
         SELECT Count(1)
         FROM   movie
         WHERE  production_company IS NULL)
SELECT *
FROM   null_info; 

/*
--OUTPUT
-- column            null_values
*id                      0
*title                   0
*year                    0
*date_published          0
*duration                0
*country                 20
*worlwide_gross_income   3724
*languages               194
*production_company      528
*/

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|	2944			|
|	2019		|   2001			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 804			|
|	2			|	 640			|
|	3			|	 824	
    4                680
    5                625
    6                580
    7                493
    8                678
    9                809
    10               801
    11               625
    12               438
+---------------+-------------------+ */
-- Type your code below:

SELECT year,
       COUNT(id) AS number_of_movies
FROM   movie
GROUP  BY year
ORDER  BY COUNT(id) DESC;

/*
OUTPUT
----Answer filled above table


SELECT Month(date_published) AS month_num,
       COUNT(id) AS number_of_movies
FROM   movie
GROUP  BY month_num
ORDER  BY month_num;

/*
OUTPUT
----Answer filled above table



/*The highest number of movies is produced in the month of March=824
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT year,
       COUNT(id) AS movies_count
FROM   movie
WHERE  ( country LIKE '%USA%'
          OR country LIKE '%India%' )
          AND year = 2019;
          
  /*        
 --OUTPUT         
----movies_count=1059 



/* USA and India produced more than a thousand movies(1059) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT genre
FROM  genre; 


/*
--OUTPUT
-----Drama,Fantasy,Thriller,Comedy,Horror,Family,Romance,Adventure,Action,Sci-Fi,Crime,Mystery,Others
-----13 unique list of the genres present in the data set




/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT 
	genre , COUNT(movie_id) AS movie_count
FROM 
	genre 
GROUP BY 
	genre 
ORDER BY 
	movie_count desc LIMIT 1;

-- Drama 4285 genre has highest number of movies produced in overall.


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:


WITH genre_info
     AS (SELECT movie_id,
                Count(DISTINCT genre) AS one_genre
         FROM   genre
         GROUP  BY movie_id
         HAVING one_genre = 1)
SELECT Count(*)
FROM   genre_info; 

/*
OUTPUT
----one_genre=3289


/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	Action	          112.88
    Romance	          109.53
    Crime	          107.05
    Drama	          106.77
    Fantasy	          105.14
    Comedy	          102.62
    Adventure	      101.87
    Mystery	          101.80
    Thriller	      101.58
    Family	          100.97
    Others	          100.16
    Sci-Fi	          97.94
    Horror	          92.72			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT
   genre,
   ROUND(AVG(duration), 2) AS avg_duration 
FROM
   genre g 
   INNER JOIN
      movie m 
      ON g.movie_id = m.id 
GROUP BY
   genre 
ORDER BY
   avg_duration DESC;


---Output  written above 


/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


WITH genre_rank_info
     AS (SELECT genre,
                Count(DISTINCT movie_id)      AS movie_count,
                Dense_rank()
                  OVER(
                    ORDER BY (movie_id) DESC) AS genre_rank
         FROM   genre
         GROUP  BY genre)
SELECT *
FROM   genre_rank_info
WHERE  genre = 'Thriller'; 

/*
---OUTPUT
---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|Thriller 		|	     1484		|			3   	  |
+---------------+-------------------+------------------

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:


SELECT ROUND(Min(avg_rating))    AS min_avg_rating,
      ROUND(Max(avg_rating))   AS max_avg_rating,
       ROUND(Min(total_votes))   AS min_total_votes,
       ROUND(Max(total_votes))   AS max_total_votes,
       ROUND(Min(median_rating)) AS min_median_rating,
       ROUND(Max(median_rating)) AS max_median_rating
FROM   ratings;  

/*
---output:-
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		1 	    |			10	    |	       100  	  |	   725138	    	 |		1	       |	10			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/


    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too


SELECT     title,
           avg_rating,
           Row_number() OVER( ORDER BY avg_rating DESC) AS movie_rank
FROM       movie                                        AS m
INNER JOIN ratings                                      AS r
ON         r.movie_id = m.id limit 10;

/*
--OUTPUT
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
Kirket	                   10.0	                        1
Love in Kilnerry	       10.0	                        2
Gini Helida Kathe	       9.8	                        3
Runam	                   9.7	                        4
Fan	                       9.6	                        5
Android Kunjappan Version5.25 9.6	                    6
Yeh Suhaagraat Impossible  9.5	                        7
Safe	                   9.5	                        8
The Brighton Miracle	   9.5	                        9
Shibu	                   9.4	                        10

*/




/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
-- -----Fan	and Android Kunjappan Version5.25 movie have average rating of 9.6.

So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have


SELECT median_rating,
       COUNT(movie_id) AS movie_count
FROM   ratings
GROUP  BY median_rating
ORDER  BY median_rating;

/*
--OUTPUT
+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
1	                       94
2	                       119
3	                       283
4	                       479
5	                       985
6	                       1975
7	                       2257
8	                       1030
9	                       429
10	                       346

*/  


/* Movies with a median rating of 7 is highest in number=2257
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:



SELECT
       production_company,
       COUNT(movie_id) AS movie_count,
       Dense_rank()
         OVER(
           ORDER BY Count(id) DESC) AS prod_company_rank
FROM   ratings r
       INNER JOIN movie m
               ON r.movie_id = m.id
WHERE  avg_rating > 8
       AND production_company IS NOT NULL
GROUP  BY production_company
ORDER  BY movie_count DESC; 






-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:



SELECT g.genre,
       COUNT(g.movie_id) AS movie_count
FROM   genre g
       INNER JOIN ratings r
               ON g.movie_id = r.movie_id
       INNER JOIN movie m
               ON r.movie_id = m.id
WHERE  m.country LIKE '%USA%'
       AND r.total_votes > 1000
       AND Month(date_published) = 3
       AND year = 2017
GROUP  BY g.genre
ORDER  BY movie_count DESC; 

/*
-- OUTPUT
genre   Movie_count
Drama	 24
Comedy	 9
Action	 8
Thriller	8
Sci-Fi	 7
Crime	 6
Horror	 6
Mystery	 4
Romance	 4
Fantasy	 3
Adventure	3
Family	    1

*/


-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


SELECT title,
       avg_rating,
       genre
FROM   genre g
       INNER JOIN ratings r
               ON g.movie_id = r.movie_id
       INNER JOIN movie m
               ON r.movie_id = m.id
WHERE  title LIKE 'The%'
       AND avg_rating > 8
ORDER  BY avg_rating DESC; 






-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:


SELECT median_rating,
       Count(movie_id) AS movie_count
FROM   movie AS m
       INNER JOIN ratings AS r
               ON m.id = r.movie_id
WHERE  median_rating = 8
       AND date_published BETWEEN '2018-04-01' AND '2019-04-01'
GROUP  BY median_rating; 

/*
--OUTPUT
--median_rating   movie_count
    8                  361
    
    */



-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

WITH movie_language_count
     AS (SELECT languages,
                SUM(total_votes) AS Total_number_votes
         FROM   ratings r
                INNER JOIN movie m
                        ON r.movie_id = m.id
         WHERE  languages LIKE '%German%'
         UNION ALL
         SELECT languages,
                Sum(total_votes) AS Total_number_votes
         FROM   ratings r
                INNER JOIN movie m
                        ON r.movie_id = m.id
         WHERE  languages LIKE '%Italian%')
SELECT *
FROM   movie_language_count; 


/*   OUTPUT 
 Languages    Total_number_votes
   German	        4421525
   Italian      	2559540
   */


-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:


-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|		17335   	|	       13431	  |	   15226	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT A.name_nulls,
       B.height_nulls,
       C.date_of_birth_nulls,
       D.known_for_movies_nulls
FROM   (SELECT Count(*) AS name_nulls
        FROM   names
        WHERE  NAME IS NULL)A,
       (SELECT Count(*) AS height_nulls
        FROM   names
        WHERE  height IS NULL)B,
       (SELECT Count(*) AS date_of_birth_nulls
        FROM   names
        WHERE  date_of_birth IS NULL)C,
       (SELECT Count(*) AS known_for_movies_nulls
        FROM   names
        WHERE  known_for_movies IS NULL)D; 

--- Answer filled above table

/* There are no Null value in the column 'name'-yes
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|	James Mangold    	4
    Joe Russo	        3
  Anthony Russo	        3		    |	
+---------------+-------------------+ */
-- Type your code below:


WITH top_three_directors AS
(
           SELECT     g.genre           AS genre,
                      Count(g.movie_id) AS movie_count,
                      r.avg_rating      AS avg_rating
           FROM       movie             AS m
           INNER JOIN genre             AS g
           ON         m.id=g.movie_id
           INNER JOIN ratings AS r
           ON         m.id=r.movie_id
           WHERE      r.avg_rating>8
           GROUP BY   genre
           ORDER BY   movie_count DESC limit 3 )
SELECT     n.NAME           AS director_name,
           Count(m.id)      AS movie_count
FROM       names            AS n
INNER JOIN director_mapping AS d
ON         n.id=d.name_id
INNER JOIN movie AS m
ON         d.movie_id=m.id
INNER JOIN genre AS g
ON         m.id=g.movie_id
INNER JOIN ratings AS r
ON         m.id=r.movie_id
WHERE      r.avg_rating>8
AND        g.genre IN
           (
                  SELECT genre
                  FROM   top_three_directors)
GROUP BY   director_name
ORDER BY   movie_count DESC limit 3;

-- Answer filled above-
           

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT name AS actor_name,
       COUNT(*) AS movie_count
FROM   names n
       INNER JOIN role_mapping r
               ON n.id = r.name_id
       INNER JOIN ratings t
               ON r.movie_id = t.movie_id
WHERE  median_rating >= 8
       AND category = 'actor'
GROUP  BY name
ORDER  BY movie_count DESC
LIMIT  2;

/*
---OUTPUT
---+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
    Mammootty	         8
     Mohanlal	         5 
     
     */



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT     production_company,
           SUM(total_votes) AS vote_count,
           Dense_rank() OVER(ORDER BY Sum(total_votes) DESC) AS prod_comp_rank
FROM       movie m
INNER JOIN ratings r
ON         m.id = r.movie_id
GROUP BY   production_company limit 3;


/*
---OUTPUT
+------------------+--------------------+---------------------+
|production_company|  vote_count			|	prod_comp_rank|
+------------------+--------------------+---------------------+
Marvel Studios	         2656967	                  1
Twentieth Century Fox	 2411163	                  2
Warner Bros.	         2396057	                  3

*/

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH top_actor_fromlist AS
(
           SELECT     NAME  AS actor_name,
                      Sum(total_votes) AS total_votes,
                      Count(m.id) AS movie_count,
                      Round(Sum(avg_rating * total_votes) / Sum(total_votes), 2) AS actor_avg_rating,
                      dense_rank() over(order by avg_rating desc) as actor_rank
           FROM       movie m
           INNER JOIN ratings r
           ON         m.id = r.movie_id
           INNER JOIN role_mapping t
           ON         r.movie_id = t.movie_id
           INNER JOIN names n
           ON         t.name_id = n.id
           WHERE      category = 'actor'
           AND        country LIKE '%India%'
           GROUP BY   NAME
           HAVING     Count(m.id) >= 5 limit 1)
SELECT*
FROM   top_actor_fromlist;

/*
----OUTPUT
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
Vijay Sethupathi     	23114               	5	                8.42	             1
*/


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH top5_actress_hindimovie_india_with_averagerating AS
(
           SELECT     n.NAME   AS actress_name,
                      Sum(r.total_votes)  AS total_votes,
                      Count(m.id)  AS movie_count,
                      Round((Sum(avg_rating  * total_votes) / Sum(total_votes)), 2)  AS actress_avg_rating,
					  Rank() OVER(ORDER BY (Sum(avg_rating * total_votes) / Sum(total_votes)) DESC, Sum(total_votes) DESC) AS actress_rank
                      
           FROM       movie m
           INNER JOIN ratings r
           ON         m.id = r.movie_id
           INNER JOIN role_mapping t
           ON         m.id = t.movie_id
           INNER JOIN names n
           ON         t.name_id = n.id
           WHERE      category = 'actress'
           AND        country LIKE '%India%'
           AND        languages LIKE '%Hindi%'
           GROUP BY   NAME
           HAVING     Count(m.id) >= 3 limit 5)
SELECT*
FROM   top5_actress_hindimovie_india_with_averagerating;




/*
---OUTPUT
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
Taapsee Pannu       	18061	             3                  	7.74             	1
Kriti Sanon	            21967              	 3	                    7.05              	2
Divya Dutta         	8579	             3	                    6.88                3
Shraddha Kapoor	        26779	             3	                    6.63                4
Kriti Kharbanda	        2549	             3	                    4.80          	    5

*/
/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:


WITH thriller_movies_avgrating
     AS (SELECT title,
                CASE
                  WHEN avg_rating > 8 THEN 'superhit movies'
                  WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
                  WHEN avg_rating BETWEEN 5 AND 7 THEN
                  'One-time-watching movies'
                  WHEN avg_rating < 5 THEN 'flop movies'
                END AS avg_rating_category
         FROM   movie AS m
                INNER JOIN genre AS g
                        ON m.id = g.movie_id
                INNER JOIN ratings AS r
                        ON m.id = r.movie_id
         WHERE  genre = 'thriller')
SELECT *
FROM   thriller_movies_avgrating; 






/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


WITH total_average_movie_duration
     AS (SELECT genre,
                Round(Avg(duration), 2)                      AS avg_duration,
                SUM(Round(Avg(duration), 2))
                  over(
                    ORDER BY genre ROWS unbounded preceding) AS
                running_total_duration,
                Avg(Round(Avg(duration), 2))
                  over(
                    ORDER BY genre ROWS unbounded preceding) AS
                moving_avg_duration
         FROM   movie m
                inner join genre g
                        ON m.id = g.movie_id
         GROUP  BY genre
         ORDER  BY genre)
SELECT *
FROM   total_average_movie_duration; 

/*
--OUTPUT
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
Action	               112.88	          112.88	                112.880000
Adventure	           101.87	          214.75	                 107.375000
Comedy	               102.62	          317.37	                 105.790000
Crime	               107.05	          424.42	                 106.105000
Drama	               106.77	          531.19	                 106.238000
Family	               100.97	          632.16	                 105.360000
Fantasy	               105.14	          737.30	                 105.328571
Horror				  92.72	              830.02	                  103.752500
Mystery	 				101.80			931.82						103.535556
Others					100.16			1031.98						103.198000
Romance					109.53			1141.51						103.773636
Sci-Fi					97.94			1239.45						103.287500
Thriller				101.58			1341.03						103.156154


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH top_three_genre AS
(
         SELECT   genre,
                  Count(movie_id) AS movie_count
         FROM     genre
         GROUP BY genre
         ORDER BY movie_count DESC limit 3 ), top_five_movie AS
(
           SELECT     genre,
                      year,
                      title AS movie_name,
                      worlwide_gross_income,
                      Dense_rank() OVER(partition BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
           FROM       movie m
           INNER JOIN genre g
           ON         m.id = g.movie_id
           WHERE      genre IN
                      (
                             SELECT genre
                             FROM   top_three_genre) )
SELECT *
FROM   top_five_movie
WHERE  movie_rank<=5;




-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

with highest_number_of_hits_movies AS
(
SELECT     production_company,
           Count(id)                                  AS movie_count,
           Row_number() OVER(ORDER BY Count(id) DESC) AS prod_comp_rank
FROM       movie m
INNER JOIN ratings r
ON         m.id = r.movie_id
WHERE      median_rating>=8
AND        production_company IS NOT NULL
AND        position(',' IN languages)>0
GROUP BY   production_company limit 2)
select * from highest_number_of_hits_movies;

/*
---OUTPUT
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
Star Cinema	                   7	                1
Twentieth Century Fox	       4	                2
*/



-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


WITH top3_actress_superhit_movies AS
(
           SELECT     n.NAME,
                      Sum(r.total_votes)                              AS total_votes,
                      Count(rt.movie_id)                              AS movie_count,
                      Round(Avg(r.avg_rating), 2)                     AS avg_rating,
                      Row_number()OVER(ORDER BY Avg(avg_rating) DESC) AS actress_rank
           FROM       names n
           INNER JOIN role_mapping rt
           ON         n.id = rt.name_id
           INNER JOIN ratings r
           ON         rt.movie_id = r.movie_id
           INNER JOIN genre g
           ON         r.movie_id = g.movie_id
           WHERE      category = 'actress'
           AND        avg_rating > 8
           AND        genre = 'Drama'
           GROUP BY   NAME limit 3)
SELECT *
FROM   top3_actress_superhit_movies;


/*
---OUTPUT
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
 Sangeetha Bhat	       1010                 	1	             9.60	                1
 Fatmire Sahiti	       3932	                    1	             9.40                   2
 Adriana Matoshi	   3932	                    1	             9.40                   3
 /*


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH Nine_director_total AS
(
           SELECT     dm.name_id AS director_id,
                      n.NAME     AS director_name,
                      m.id,
                      Datediff(Lead(date_published) OVER(partition BY NAME ORDER BY date_published) , date_published) + 1 AS 'avg_inter_movie_days',
                      r.avg_rating,
                      r.total_votes,
                      m.duration
           FROM       movie m
           INNER JOIN ratings r
           ON         r.movie_id = m.id
           INNER JOIN director_mapping dm
           ON         dm.movie_id = m.id
           INNER JOIN names n
           ON         n.id = dm.name_id )
SELECT   director_id,
         director_name,
         Count(id)                        AS number_of_movies,
         Round(Avg(avg_inter_movie_days)) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)                  AS avg_rating,
         Sum(total_votes)                 AS total_votes,
         Min(avg_rating)                  AS min_rating,
         Max(avg_rating)                  AS max_rating,
         Sum(duration)                    AS total_duration
FROM     Nine_director_total
GROUP BY director_name
ORDER BY number_of_movies DESC limit 9;


/*
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
nm1777967				A.L. Vijay				5					178					5.42			1754			3.7			6.9		613
nm2096009				Andrew Jones			5					192					3.02			1989			2.7			3.2	    432
nm0425364				Jesse V. Johnson		4					300					5.45			14778			4.2			6.5 	383
nm2691863				Justin Price			4					316					4.5				5343			3			5.8	    346
nm0001752				Steven Soderbergh		4					255					6.48			171684			6.2			7	    401
nm6356309				Ã–zgÃ¼r Bakar			4					113					3.75			1092			3.1			4.9  	374
nm0515005				Sam Liu					4					261					6.23			28557			5.8	       6.7	    312
nm0814469				Sion Sono				4					332					6.03			2972			5.4	       6.4	    502
nm0831321				Chris Stokes			4					199					4.33			3664			4	       4.6	    352

*/

