-- Data cleaning

SELECT *
FROM smart_lock_data;

-- step1. Removing duplicates
-- step2. Standardize the data 
-- step3. Dealing with Null values or blank values 

-- Now for Removing duplicate creating one more 
CREATE TABLE smart_lock_new       -- COPYING ACTUAL DATA TO NEW TABLE (HERE WE COPYING COLUMN NAME)
LIKE  smart_lock_data;

-- COPYING THE DATA TO NEW TABLE
INSERT smart_lock_new
SELECT *
FROM smart_lock_data;  

SELECT *
FROM smart_lock_new;



-- step1. Removing duplicates

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY Brand_name,Price,Rating,Rating_count,Review_count,Ranking,URL) AS row_num
FROM smart_lock_data 
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;        -- so here is no duplicates


-- step2. Standardize the data 
-- Now we will move to every column

UPDATE smart_lock_new
SET Rating_count = REPLACE(Rating_count, '(', '');

UPDATE smart_lock_new
SET Rating_count = REPLACE(Rating_count, ')', '');

UPDATE smart_lock_new
SET Price = REPLACE(Price, 'â‚¹', '');

UPDATE smart_lock_new
SET Review_count = REPLACE(Review_count, 'Reviews', '');


-- step3. Dealing with Null values or blank values
UPDATE smart_lock_new
SET Rating = '0.0'
WHERE Rating IS NULL;

UPDATE smart_lock_new
SET Rating_count = '0'
WHERE Rating_count IS NULL;

UPDATE smart_lock_new
SET Review_count = '0'
WHERE Review_count IS NULL;

SELECT *
FROM smart_lock_new;


-- changing Data Types

ALTER TABLE smart_lock_new
MODIFY Brand_name VARCHAR(500),
MODIFY Price VARCHAR(20),
MODIFY Rating FLOAT,
MODIFY Rating_count INT,
MODIFY Review_count INT,
MODIFY Ranking INT,
MODIFY URL VARCHAR(1000) ;

CREATE VIEW smart_lock_cleaned AS
SELECT 
    Brand_name,
    CAST(REPLACE(Price, ',', '') AS UNSIGNED) AS Price,
    Rating,
    Rating_count,
    Review_count,
    Ranking,
    URL
FROM smart_lock_new;


SELECT *
FROM smart_lock_new;

# Analysis

-- This query assumes the brand name is the first word in the Brand column.

SELECT 
    SUBSTRING_INDEX(Brand_name, ' ', 1) AS BrandName,
    TRIM(SUBSTRING(Brand_name, INSTR(Brand_name, ' ') + 1)) AS Description
FROM smart_lock_new;


-- step1-- a. Number of brands in the segment


SELECT 
    SUM(NumberOfBrands) AS TotalDistinctBrands
FROM (
    SELECT 
        BrandName,
        COUNT(DISTINCT BrandName) AS NumberOfBrands
    FROM (
        SELECT 
            SUBSTRING_INDEX(Brand_name, ' ', 1) AS BrandName
        FROM smart_lock_new
    ) AS ExtractedData
    GROUP BY BrandName
) AS BrandCountData;


-- b. Count of SKUs  as per brand

SELECT 
    SUBSTRING_INDEX(Brand_name, ' ', 1) AS BrandName,
    COUNT(*) AS SKU_Count
FROM smart_lock_new
GROUP BY BrandName
ORDER BY SKU_Count DESC;

-- c. Calculating Average Ranking by Brand Name:
SELECT 
    SUBSTRING_INDEX(Brand_name, ' ', 1) AS BrandName,
    AVG(Ranking) AS AverageRanking
FROM smart_lock_new
GROUP BY BrandName
ORDER BY AverageRanking ASC;


-- d. Relative Rating:
SELECT 
    SUBSTRING_INDEX(Brand_name, ' ', 1) AS BrandName,
    Price,
    CASE
        WHEN Price < 3000 THEN '<INR 4,999'
        WHEN Price BETWEEN 3000 AND 4999 THEN 'INR 3,000-4,999'
        WHEN Price BETWEEN 5000 AND 9999 THEN 'INR 5,000-9,999'
        WHEN Price BETWEEN 10000 AND 14999 THEN 'INR 10,000-14,999'
        WHEN Price BETWEEN 15000 AND 19999 THEN 'INR 15,000-19,999'
        ELSE 'Greater than 20,000'
    END AS PriceBand
FROM smart_lock_cleaned;




SELECT *
FROM smart_lock_new;

