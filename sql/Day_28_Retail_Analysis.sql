
USE retail_analysis;

LOAD DATA LOCAL INFILE 'C:/Users/Admin/Downloads/transformed_retail_sales.csv'
INTO TABLE retail_sales_import
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT COUNT(*) AS Total_Records
FROM retail_sales_import;

describe retail_sales_import;
#1. Total sales
SELECT SUM(Sales) AS Total_Sales FROM retail_sales_import;

#2. Total profit
SELECT SUM(Profit) AS Total_Profit FROM retail_sales_import;

#3. Total orders
SELECT COUNT(DISTINCT `Order ID`) AS Total_Orders FROM retail_sales_import;

#4. Total customers
SELECT COUNT(DISTINCT `Customer ID`) AS Total_Customers FROM retail_sales_import;

#5. Average order value
SELECT SUM(Sales) / COUNT(DISTINCT `Order ID`) AS Average_Order_Value FROM retail_sales_import;

#6. Sales by category
SELECT Category, SUM(Sales) AS Total_Sales FROM retail_sales_import
GROUP BY Category
ORDER BY Total_Sales DESC;

#7. Sales by region
SELECT Region, SUM(Sales) AS Total_Sales
FROM retail_sales_import
GROUP BY Region
ORDER BY Total_Sales DESC;

#8. Profit by category
SELECT Category, SUM(Profit) AS Total_Profit
FROM retail_sales_import
GROUP BY Category
ORDER BY Total_Profit DESC;

#9. Profit by region
SELECT Region, SUM(Profit) AS Total_Profit
FROM retail_sales_import
GROUP BY Region
ORDER BY Total_Profit DESC;

#10. Sales by month
SELECT
    YEAR(`Order Date`) AS Sales_Year,
    MONTH(`Order Date`) AS Sales_Month,
    SUM(Sales) AS Total_Sales
FROM retail_sales_import
GROUP BY YEAR(`Order Date`), MONTH(`Order Date`)
ORDER BY Sales_Year, Sales_Month;

#11. Top 10 customers
SELECT `Customer ID`, `Customer Name`, SUM(Sales) AS Total_Sales
FROM retail_sales_import
GROUP BY `Customer ID`, `Customer Name`
ORDER BY Total_Sales DESC
LIMIT 10;

#12. Repeat customers
SELECT
    `Customer ID`,
    `Customer Name`,
    COUNT(DISTINCT `Order ID`) AS Total_Orders
FROM retail_sales_import
GROUP BY `Customer ID`, `Customer Name`
HAVING COUNT(DISTINCT `Order ID`) > 1
ORDER BY Total_Orders DESC;

#13. Average customer spending
SELECT
    AVG(Customer_Sales) AS Average_Customer_Spending
FROM (
    SELECT
        `Customer ID`,
        SUM(Sales) AS Customer_Sales
    FROM retail_sales_import
    GROUP BY `Customer ID`
) AS customer_summary;

#14. Top products
SELECT
    `Product Name`,
    SUM(Sales) AS Total_Sales
FROM retail_sales_import
GROUP BY `Product Name`
ORDER BY Total_Sales DESC
LIMIT 10;

#15. Bottom products
SELECT
    `Product Name`,
    SUM(Sales) AS Total_Sales
FROM retail_sales_import
GROUP BY `Product Name`
ORDER BY Total_Sales ASC
LIMIT 10;

#16. Most profitable products
SELECT
    `Product Name`,
    SUM(Profit) AS Total_Profit
FROM retail_sales_import
GROUP BY `Product Name`
ORDER BY Total_Profit DESC
LIMIT 10;

#17. Customer ranking
WITH customer_sales AS (
    SELECT
        `Customer ID`,
        `Customer Name`,
        SUM(Sales) AS Total_Sales
    FROM retail_sales_import
    GROUP BY `Customer ID`, `Customer Name`
)
SELECT
    `Customer ID`,
    `Customer Name`,
    Total_Sales,
    RANK() OVER (ORDER BY Total_Sales DESC) AS Customer_Rank
FROM customer_sales
ORDER BY Customer_Rank;

#18. Product ranking
WITH product_sales AS (
    SELECT
        `Product Name`,
        SUM(Sales) AS Total_Sales
    FROM retail_sales_import
    GROUP BY `Product Name`
)
SELECT
    `Product Name`,
    Total_Sales,
    RANK() OVER (ORDER BY Total_Sales DESC) AS Product_Rank
FROM product_sales
ORDER BY Product_Rank;

#19. Monthly growth
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(`Order Date`, '%Y-%m') AS Sales_Month,
        SUM(Sales) AS Total_Sales
    FROM retail_sales_import
    GROUP BY DATE_FORMAT(`Order Date`, '%Y-%m')
),
sales_growth AS (
    SELECT
        Sales_Month,
        Total_Sales,
        LAG(Total_Sales) OVER (
            ORDER BY Sales_Month
        ) AS Previous_Month_Sales
    FROM monthly_sales
)
SELECT
    Sales_Month,
    Total_Sales,
    Previous_Month_Sales,
    ROUND(
        (Total_Sales - Previous_Month_Sales)
        / NULLIF(Previous_Month_Sales, 0) * 100,
        2
    ) AS Growth_Percentage
FROM sales_growth
ORDER BY Sales_Month;

#20. Category ranking
WITH category_sales AS (
    SELECT
        Category,
        SUM(Sales) AS Total_Sales
    FROM retail_sales_import
    GROUP BY Category
)
SELECT
    Category,
    Total_Sales,
    RANK() OVER (ORDER BY Total_Sales DESC) AS Category_Rank
FROM category_sales
ORDER BY Category_Rank;

#Customer segmentation using CASE
WITH customer_sales AS (
    SELECT
        `Customer ID`,
        `Customer Name`,
        SUM(Sales) AS Total_Sales
    FROM retail_sales_import
    GROUP BY `Customer ID`, `Customer Name`
)
SELECT
    `Customer ID`,
    `Customer Name`,
    Total_Sales,
    CASE
        WHEN Total_Sales >= 5000 THEN 'High Value'
        WHEN Total_Sales >= 2000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Segment
FROM customer_sales
ORDER BY Total_Sales DESC;