SELECT * FROM walmart;

--
SELECT COUNT(*) FROM walmart;

SELECT 
	payment_method,
    COUNT(*)    
FROM walmart
GROUP BY payment_method;

SELECT 
	COUNT(DISTINCT Branch)
FROM walmart;

SELECT MIN(quantity) FROM walmart;

-- Business Problems
-- Project Question #1
-- Find different payment method and number of transactions, number of quantity sold

SELECT 
	payment_method,
    COUNT(*) as no_payments ,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;


-- Project Question #2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING

SELECT *
FROM (
    SELECT
        branch,
        category,
        AVG(rating) as avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as `rank`
    FROM walmart
    GROUP BY 1, 2
) AS ranked
WHERE `rank` = 1;

-- Project Question #3
-- Identify the busiest day for each branch based on the number of transactions

SELECT *
FROM (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) as day_name,
        COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as `rank`
    FROM walmart
    GROUP BY 1, 2
) AS ranked
WHERE `rank` = 1;

-- Project Question #4
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT 
	payment_method,
    -- COUNT(*) as no_payments,
    SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Project Question #6
-- Determine the average, minimum, and maximum rating of products for each city.
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
	city,
	category,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating,
    AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2;

-- Project Question #6
-- Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit. 

SELECT 
	category, 
    SUM(total) as total_revenue,
    SUM(total * profit_margin) as profit
FROM walmart
Group BY 1;

-- Project Question #7
-- Determine the most common payment method for each branch. 
-- Display Branch and the preferred_payment_method.

WITH cte
AS
(SELECT 
	branch,
    payment_method,
    COUNT(*) as total_trans,
    RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as `rank`
FROM walmart
GROUP BY 1,2
)
SELECT * 
FROM cte
WHERE `rank` = 1;

-- Project Question #8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out each of the shift and number of invoives

SELECT
    branch,
    CASE
        WHEN HOUR(time) < 12 THEN 'MORNING'
        WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        ELSE 'EVENING'
    END as shift,
    COUNT(*) as num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Project Question #9
-- Identify 5 branch with highest decrease ration in revenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
YEAR(STR_TO_DATE(date, '%d/%m/%y')) as formatted_date
FROM walmart;

-- 2022 Sales
WITH revenue_2022
AS
(
	SELECT
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
	GROUP BY 1
),

revenue_2023
AS
(
	SELECT
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
    ls.revenue as last_year_revenue,
    cs.revenue as cr_year_revenue,
   ROUND((ls.revenue - cs.revenue) / ls.revenue * 100, 2) as rdr
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;