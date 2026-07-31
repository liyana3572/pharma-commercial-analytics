DROP TABLE IF EXISTS sales_long_fixed;

CREATE TABLE sales_long_fixed AS
SELECT
  substr(trim(sale_date), 7, 4) || '-' ||
  substr(trim(sale_date), 4, 2) || '-' ||
  substr(trim(sale_date), 1, 2) AS sale_date,
  atc_category,
  quantity
FROM sales_long;

DROP TABLE sales_long;
ALTER TABLE sales_long_fixed RENAME TO sales_long;

ALTER TABLE sales_long ADD COLUMN sale_year TEXT;
ALTER TABLE sales_long ADD COLUMN sale_month TEXT;
ALTER TABLE sales_long ADD COLUMN sale_dow TEXT;

UPDATE sales_long SET sale_year = substr(sale_date, 1, 4);
UPDATE sales_long SET sale_month = substr(sale_date, 6, 2);
UPDATE sales_long SET sale_dow = strftime('%w', sale_date);



SELECT atc_category, ROUND(SUM(quantity), 0) AS total_units
FROM sales_long
GROUP BY atc_category
ORDER BY total_units DESC;


SELECT
  atc_category,
  sale_year AS year,
  ROUND(SUM(quantity), 0) AS total_units
FROM sales_long
GROUP BY atc_category, sale_year
ORDER BY atc_category, sale_year;


WITH yearly AS (
  SELECT atc_category, sale_year AS year, SUM(quantity) AS total_units
  FROM sales_long
  GROUP BY atc_category, sale_year
)
SELECT
  a.atc_category,
  a.year AS year_from,
  b.year AS year_to,
  a.total_units AS units_start,
  b.total_units AS units_end,
  ROUND((b.total_units - a.total_units) * 100.0 / a.total_units, 1) AS growth_pct
FROM yearly a
JOIN yearly b
  ON a.atc_category = b.atc_category
  AND CAST(b.year AS INTEGER) = CAST(a.year AS INTEGER) + 1
ORDER BY growth_pct DESC;


SELECT
  atc_category,
  sale_month AS month,
  ROUND(AVG(quantity), 2) AS avg_daily_units
FROM sales_long
GROUP BY atc_category, sale_month
ORDER BY atc_category, sale_month;


SELECT
  atc_category,
  sale_dow AS day_of_week,  -- 0=Sunday
  ROUND(AVG(quantity), 2) AS avg_units
FROM sales_long
GROUP BY atc_category, sale_dow
ORDER BY atc_category, sale_dow;


SELECT
  atc_category,
  ROUND(AVG(quantity), 2) AS avg_units,
  ROUND(
    SQRT(AVG((quantity - sub.avg_units) * (quantity - sub.avg_units))), 2
  ) AS stddev_units
FROM sales_long,
  (SELECT atc_category AS cat, AVG(quantity) AS avg_units FROM sales_long GROUP BY atc_category) AS sub
WHERE sales_long.atc_category = sub.cat
GROUP BY atc_category;