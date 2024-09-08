# Netflix Movies and TV Shows Data Analysis using SQL
![Netflix -Logo](https://github.com/chitranjan-nirala/Netflix_SQL_Project/blob/main/logo.png)
## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives
- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.
## Dataset
The data for this project is sourced from the Kaggle dataset:

- Dataset Link: [Netflix Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)
## Schema
```sql
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
```
- Business Problems and Solutions
## 1. Count the Number of Movies vs TV Shows
``` sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```

- Objective: Determine the distribution of content types on Netflix.

## 2. Find the Most Common Rating for Movies and TV Shows
```sql
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
```
- Objective: Identify the most frequently occurring rating for each type of content.

## 3. List All Movies Released in a Specific Year (e.g., 2020)
```sql
select * from netflix_titles where type ='Movie' and release_year= 2020;
```
- Objective: Retrieve all movies released in a specific year.

## 4. Find the Top 5 Countries with the Most Content on Netflix
```sql
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
```
- Objective: Identify the top 5 countries with the highest number of content items.
## 5. Identify the Longest Movie
 ```sql
SELECT *
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;
```
- Objective: Find the movie with the longest duration.

## 6. Find Content Added in the Last 5 Years
 ```sql
SELECT *
FROM netflix_titles
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;
```
- Objective: Retrieve content added to Netflix in the last 5 years.

## 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
```sql
SELECT *
FROM netflix_titles
WHERE FIND_IN_SET('Rajiv Chilaka', director) > 0;
```

## 8. List All TV Shows with More Than 5 Seasons
```sql 
select * from netflix_titles where type = 'TV Show' AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
```
- Objective: Identify TV shows with more than 5 seasons.

## 9. Count the Number of Content Items in Each Genre
```sql
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
```
- Objective: Count the number of content items in each genre.

## 10.Find each year and the average numbers of content release in India on netflix.
 ```sql
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
```
- Objective: Calculate and rank years by the average number of content releases by India.

## 11. List All Movies that are Documentaries
```sql
SELECT * 
FROM netflix_titles
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';
```
- Objective: Retrieve all movies classified as documentaries.

## 12. Find All Content Without a Director
```sql
SELECT * 
FROM netflix_titles
WHERE director is NULL;
```
- Objective: List content that does not have a director.

## 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
```sql
SELECT COUNT(*) AS movie_count
FROM netflix_titles
WHERE cast LIKE '%Salman Khan%'
  AND release_year >= YEAR(CURDATE()) - 10;
```
- Objective: Count the number of movies featuring 'Salman Khan' in the last 10 years.

## 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
```sql
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
```
- Objective: Identify the top 10 actors with the most appearances in Indian-produced movies.

## 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
```sql
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
```
Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.
