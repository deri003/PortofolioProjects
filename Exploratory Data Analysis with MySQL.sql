-- SQL Project: Exploratory Data Analysis
-- https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- The layoffs dataset used is from March 11, 2020 to May 15, 2025.



-- After performing SQL Project: Data Cleaning, the next step is to perform SQL Project: Exploratory Data Analysis.
SELECT *
FROM layoffs_2025.layoffs_staging1;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_2025.layoffs_staging1;
-- The highest percentage_laid_off was 100% with the largest total_laid_off being 22,000 people.

SELECT *
FROM layoffs_2025.layoffs_staging1
WHERE percentage_laid_off = 100.00;

SELECT *
FROM layoffs_2025.layoffs_staging1
WHERE percentage_laid_off = 100.00
ORDER BY total_laid_off DESC;
-- Based on total_laid_off, Katerra Company ranks first with a percentage_laid_off of 100%.

SELECT *
FROM layoffs_2025.layoffs_staging1
WHERE percentage_laid_off = 100.00
ORDER BY funds_raised_clean DESC;
-- Based on funds_raised, Britishvolt Company ranks first with a percentage_laid_off of 100%.

SELECT company, SUM(total_laid_off)
FROM layoffs_2025.layoffs_staging1
GROUP BY company
ORDER BY 2 DESC;
-- Intel Corporation ranks first based on total_laid_off of 37,000 people.

SELECT industry, SUM(total_laid_off)
FROM layoffs_2025.layoffs_staging1
GROUP BY industry
ORDER BY 2 DESC;
-- The hardware industry sector ranked first based on total_laid_off of 73892 people.

SELECT country, SUM(total_laid_off)
FROM layoffs_2025.layoffs_staging1
GROUP BY country
ORDER BY 2 DESC;
-- The country with the highest total_laid_off is the United States with 423,974 people.

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_2025.layoffs_staging1
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- Starting from 2022-2024 total_laid_off is more than 100000.

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_2025.layoffs_staging1
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;
-- Based on the total_laid_off amount in January 2023, it was the highest at 82988.

WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_2025.layoffs_staging1
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS Rolling_Total
FROM Rolling_Total;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_2025.layoffs_staging1
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;
-- From January to May 2025, Intel company with the highest total_laid_off is 22000.

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_2025.layoffs_staging1
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;
-- The companies with the highest total_laid_off from March 2020 to May 2025 were Uber, Katerra, Meta, Google, Intel and Intel, respectively.

