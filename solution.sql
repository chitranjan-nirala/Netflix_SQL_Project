create database Netflix_db;
use Netflix_db;
drop table if exists Netflix;
create table Netflix(
 show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    cast        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);


select * from netflix_titles;


-- Find the Most Common Rating for Movies and TV Shows
SELECT 
    type,
    rating AS most_frequent_rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_titles
    GROUP BY type, rating
) AS RatingCounts
WHERE rating_count = (
    SELECT MAX(rating_count)
    FROM (
        SELECT 
            type,
            rating,
            COUNT(*) AS rating_count
        FROM netflix_titles
        GROUP BY type, rating
    ) AS SubRatingCounts
    WHERE SubRatingCounts.type = RatingCounts.type
);

-- List All Movies Released in a Specific Year (e.g., 2020)
select * from netflix_titles where type ='Movie' and release_year= 2020;

-- Find the Top 5 Countries with the Most Content on Netflix
SELECT country, COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1)) AS country
    FROM netflix_titles
    JOIN numbers
    ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= numbers.n - 1
    WHERE country IS NOT NULL
) AS split_countries
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;


-- Identify the Longest Movie
-- select * from netflix_titles where type ='Movie' order by duration desc limit 1; 
-- Identify the Longest Movie
SELECT *
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

-- Find Content Added in the Last 5 Years
SELECT *
FROM netflix_titles
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM netflix_titles
WHERE FIND_IN_SET('Rajiv Chilaka', director) > 0;

-- List All TV Shows with More Than 5 Seasons 
select * from netflix_titles where type = 'TV Show' AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- Count the Number of Content Items in Each Genre
SELECT genre, COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', num.n), ',', -1)) AS genre
    FROM netflix_titles
    JOIN (
        SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    ) num ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= num.n - 1
) AS genre_list
WHERE genre IS NOT NULL
GROUP BY genre
ORDER BY total_content DESC;

-- Find the top 5 years with the highest average content release in India on Netflix
SELECT 
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / (SELECT COUNT(show_id) FROM netflix_titles WHERE country LIKE '%India%') * 100, 2
    ) AS avg_release
FROM netflix_titles
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;

-- List All Movies that are Documentaries
SELECT * 
FROM netflix_titles
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';

-- find All Content Without a Director
-- Select all entries where the director is NULL
SELECT * 
FROM netflix_titles
WHERE director is NULL;

-- Find how many movies actor 'Salman Khan' appeared in the last 10 years
SELECT COUNT(*) AS movie_count
FROM netflix_titles
WHERE cast LIKE '%Salman Khan%'
  AND release_year >= YEAR(CURDATE()) - 10;

-- Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
    actor,
    COUNT(*) AS movie_count
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', numbers.n), ',', -1)) AS actor
    FROM netflix_titles
    JOIN (
        SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    ) numbers
    ON CHAR_LENGTH(cast) - CHAR_LENGTH(REPLACE(cast, ',', '')) >= numbers.n - 1
    WHERE country = 'India'
) AS actor_list
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;


-- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix_titles
) AS categorized_content
GROUP BY category;
