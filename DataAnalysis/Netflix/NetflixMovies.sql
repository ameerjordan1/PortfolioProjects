-- View the entire table

SELECT * FROM netflix;

-- Confirm the rows

SELECT
	COUNT(*) as total_content
FROM netflix;

-- Look at the different types

SELECT
	DISTINCT TYPE
FROM netflix;

-- Question 1
-- Count the number of Movies vs. TV shows

SELECT
	type,
    COUNT(*) as total_content
FROM netflix
GROUP BY type;

-- Question 2
-- Find the most common rating for movies and TV shows

WITH rating_counts AS (
    SELECT 
        type,
        rating,
        COUNT(*) as count,
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
    FROM netflix
    GROUP BY type, rating
)
SELECT type, rating, count
FROM rating_counts
WHERE ranking = 1;

-- Question 3
-- List all movies released in a specific year (e.g., 2020) 

-- Filter 2020
-- Movies

SELECT * FROM netflix
WHERE 
	type = 'movie' 
    AND
    release_year = 2020;
    
-- Question 4
-- Find the top 5 countries with the most content on Netlfix

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n.n), ',', -1)) AS country,
    COUNT(*) as total_content
FROM netflix
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) n
    ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= n.n - 1
WHERE country IS NOT NULL AND country != ''
GROUP BY TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n.n), ',', -1))
HAVING country != ''
ORDER BY total_content DESC
LIMIT 5;

-- Question 5
-- Identify the longest movie

SELECT * FROM netflix
WHERE
	type = 'Movie'
    AND
    duration = (SELECT MAX(duration) FROM netflix);
    
-- Question 6
-- Find content added in the last 5 years

SELECT *,
    STR_TO_DATE(date_added, '%M %d, %Y') AS date_added_converted
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURRENT_DATE - INTERVAL 5 YEAR;

-- Question 7
-- Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT * FROM netflix 
WHERE director LIKE '%Rajiv Chilaka%';

-- Question 8
-- List all TV shows with more than 5 seasons

SELECT *,
    CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) AS seasons
FROM netflix
WHERE type = 'TV Show'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- Quetion 9 
-- Count the number of content items in each genre

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre,
    COUNT(*) AS total_content
FROM netflix
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) n
    ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= n.n - 1
WHERE listed_in IS NOT NULL AND listed_in != ''
GROUP BY TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1))
ORDER BY total_content DESC;


-- Question 10 
-- Find each year and the average number of content release by India on netflix. Return top 5 year with highest average content release.

SELECT 
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year,
    COUNT(*) AS total_content,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100, 2) AS avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY year
ORDER BY avg_content_per_year DESC
LIMIT 5;

-- Question 11
-- List all movies that are documentaries

SELECT * FROM netflix
WHERE 
	listed_in LIKE '%documentaries%';

-- Question 12
-- Find all contetn without a director

SELECT * FROM netflix
WHERE 
	director = '';

-- Question 13
-- Find how many movies actor 'Salman Khan' appeared in the last 10 years

SELECT * FROM netflix
WHERE 
	cast LIKE '%Salman Khan%'
    AND 
    release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- Question 14
-- Find the top 10 actors who appeared in the highest number of movies produced in United States

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n.n), ',', -1)) AS actor,
    COUNT(*) AS total_content
FROM netflix
JOIN (SELECT 1 n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
      UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) n
    ON CHAR_LENGTH(cast) - CHAR_LENGTH(REPLACE(cast, ',', '')) >= n.n - 1
WHERE country LIKE '%United States%'
AND cast IS NOT NULL AND cast != ''
GROUP BY TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n.n), ',', -1))
ORDER BY total_content DESC
LIMIT 10;

-- Question 15
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing 
-- these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category. 


WITH new_table
AS
(
SELECT 
* ,
	CASE
    WHEN description LIKE '%kill%' OR
		description LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
	END category
FROM netflix
)
SELECT
	category,
    COUNT(*) as total_content
FROM new_table
GROUP BY 1;










    
    
