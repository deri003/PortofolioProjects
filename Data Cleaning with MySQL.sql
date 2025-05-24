-- SQL Project: Data Cleaning
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- The layoffs dataset used is from March 11, 2020 to May 15, 2025.


SELECT *
FROM layoffs_2025.layoffs;

-- 1. Remove Duplicates

-- Create a new table namely layoffs_staging and insert from the layoffs table.
CREATE TABLE layoffs_2025.layoffs_staging
LIKE layoffs_2025.layoffs;

INSERT layoffs_2025.layoffs_staging
SELECT *
FROM layoffs_2025.layoffs;

SELECT *
FROM layoffs_2025.layoffs_staging;

-- Check and delete duplicate data.
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_2025.layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised) AS row_num
FROM layoffs_2025.layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Cazoo';

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised) AS row_num
FROM layoffs_2025.layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

-- Because you can't DELETE directly from duplicate_cte, you need to create a layoffs_staging1 table and then insert from the layoffs_staging table.
CREATE TABLE `layoffs_staging1` (
  `company` text,
  `location` text,
  `total_laid_off` double DEFAULT NULL,
  `date` text,
  `percentage_laid_off` text,
  `industry` text,
  `source` text,
  `stage` text,
  `funds_raised` text,
  `country` text,
  `date_added` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



INSERT INTO layoffs_2025.layoffs_staging1
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised) AS row_num
FROM layoffs_2025.layoffs_staging;

DELETE
FROM layoffs_2025.layoffs_staging1
WHERE row_num > 1;

SELECT *
FROM layoffs_2025.layoffs_staging1
WHERE row_num > 1;

SELECT COUNT(*)
FROM layoffs_2025.layoffs_staging1;

-- 2. Standardize the Data

SELECT company, TRIM(company)
FROM layoffs_2025.layoffs_staging1;

UPDATE layoffs_2025.layoffs_staging1
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_2025.layoffs_staging1
ORDER  BY 1;

SELECT *
FROM layoffs_2025.layoffs_staging1
WHERE industry IS NULL 
OR industry = ''
ORDER  BY 1;

SELECT *
FROM layoffs_2025.layoffs_staging1
WHERE company LIKE 'Apps%';

SELECT DISTINCT country
FROM layoffs_2025.layoffs_staging1
ORDER  BY 1;

-- Change the format of 'date' and 'date_added' from TEXT to DATE.
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_2025.layoffs_staging1;

UPDATE layoffs_2025.layoffs_staging1
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_2025.layoffs_staging1
MODIFY COLUMN `date` DATE;

SELECT `date_added`,
STR_TO_DATE(`date_added`, '%m/%d/%Y')
FROM layoffs_2025.layoffs_staging1;

UPDATE layoffs_2025.layoffs_staging1
SET `date_added` = STR_TO_DATE(`date_added`, '%m/%d/%Y');

ALTER TABLE layoffs_2025.layoffs_staging1
MODIFY COLUMN `date_added` DATE;


-- 3. Null Values or blank values

-- Find out the null or blank values ​​from the total_laid_off and percentage_laid_off columns.
SELECT *
FROM layoffs_2025.layoffs_staging1
WHERE total_laid_off = '' OR total_laid_off IS NULL
   OR percentage_laid_off = '' OR percentage_laid_off IS NULL;

-- Then update blank values ​​to null values.
UPDATE layoffs_2025.layoffs_staging1
SET total_laid_off = NULL
WHERE total_laid_off = '';

UPDATE layoffs_2025.layoffs_staging1
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

SELECT *
FROM layoffs_2025.layoffs_staging1
WHERE total_laid_off = '' OR total_laid_off IS NULL
   OR percentage_laid_off = '' OR percentage_laid_off IS NULL;

-- Remove null values.
DELETE
FROM layoffs_2025.layoffs_staging1
WHERE total_laid_off IS NULL OR percentage_laid_off IS NULL;

SELECT *
FROM layoffs_2025.layoffs_staging1
WHERE total_laid_off IS NULL OR percentage_laid_off IS NULL;

SELECT *
FROM layoffs_2025.layoffs_staging1
WHERE funds_raised = '' OR funds_raised IS NULL;

UPDATE layoffs_2025.layoffs_staging1
SET funds_raised = NULL
WHERE funds_raised = '';

SELECT *
FROM layoffs_2025.layoffs_staging1;

SELECT COUNT(*)
FROM layoffs_2025.layoffs_staging1;

-- 4. Remove Any Columns

ALTER TABLE layoffs_2025.layoffs_staging1
DROP COLUMN row_num;

SELECT *
FROM layoffs_2025.layoffs_staging1;

ALTER TABLE layoffs_2025.layoffs_staging1
MODIFY percentage_laid_off DECIMAL(5,2);

-- Added new column funds_raised_clean.
ALTER TABLE layoffs_2025.layoffs_staging1 ADD COLUMN funds_raised_clean DECIMAL(15,2);

UPDATE layoffs_2025.layoffs_staging1
SET funds_raised_clean = 
  CASE
    WHEN funds_raised LIKE '%B%' THEN REPLACE(REPLACE(funds_raised, '$', ''), 'B', '') * 1000
    WHEN funds_raised LIKE '%M%' THEN REPLACE(REPLACE(funds_raised, '$', ''), 'M', '') * 1
    WHEN funds_raised LIKE '%K%' THEN REPLACE(REPLACE(funds_raised, '$', ''), 'K', '') / 1000
    ELSE REPLACE(funds_raised, '$', '') -- Asumsi angka utuh tanpa huruf
  END;


SELECT *
FROM layoffs_2025.layoffs_staging1;