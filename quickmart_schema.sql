-- --------------------------------------------
-- ✅ STEP 1: CREATE DATABASE
-- --------------------------------------------

CREATE DATABASE QuickMartDW;
USE QuickMartDW;

-- --------------------------------------------
-- ⭐ STAR SCHEMA DESIGN
-- --------------------------------------------

-- 📅 Date Dimension (Denormalized)
CREATE TABLE Dim_Date (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    quarter INT,
    year INT
);

-- 📦 Product Dimension (Denormalized)
CREATE TABLE Dim_Product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    brand VARCHAR(50),
    price DECIMAL(10, 2)
);

-- 👤 Customer Dimension (Denormalized)
CREATE TABLE Dim_Customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    city VARCHAR(50)
);

-- 🏬 Store Dimension (Denormalized)
CREATE TABLE Dim_Store (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    region VARCHAR(50),
    manager_name VARCHAR(100)
);

-- 📊 Fact Table for Sales
CREATE TABLE Fact_Sales_Star (
    sale_id INT PRIMARY KEY,
    date_id INT,
    product_id INT,
    customer_id INT,
    store_id INT,
    quantity INT,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (date_id) REFERENCES Dim_Date(date_id),
    FOREIGN KEY (product_id) REFERENCES Dim_Product(product_id),
    FOREIGN KEY (customer_id) REFERENCES Dim_Customer(customer_id),
    FOREIGN KEY (store_id) REFERENCES Dim_Store(store_id)
);

-- ============================================
-- ⭐ STAR SCHEMA: SAMPLE DATA
-- ============================================

INSERT INTO Dim_Date VALUES
(1, '2024-01-15', 15, 1, 1, 2024),
(2, '2024-02-10', 10, 2, 1, 2024),
(3, '2024-03-05', 5, 3, 1, 2024);

INSERT INTO Dim_Product VALUES
(1, 'Milk', 'Dairy', 'Nestle', 2.50),
(2, 'Bread', 'Bakery', 'Wonder', 1.50),
(3, 'Juice', 'Beverage', 'Tropicana', 3.00);

INSERT INTO Dim_Customer VALUES
(1, 'Alice Smith', 'Female', 30, 'Toronto'),
(2, 'Bob Lee', 'Male', 45, 'Montreal'),
(3, 'Cathy Wang', 'Female', 28, 'Calgary');

INSERT INTO Dim_Store VALUES
(1, 'QuickMart Downtown', 'East', 'Mark Taylor'),
(2, 'QuickMart Uptown', 'West', 'Sarah Davis');

INSERT INTO Fact_Sales_Star VALUES
(1, 1, 1, 1, 1, 3, 7.50),
(2, 2, 2, 2, 1, 2, 3.00),
(3, 3, 3, 3, 2, 1, 3.00);

-- =====================================================
-- ⭐ STAR SCHEMA QUERIES
-- =====================================================

-- 1. Total Sales by Product
SELECT 
    dp.product_name,
    SUM(fs.total_amount) AS total_sales
FROM Fact_Sales_Star fs
JOIN Dim_Product dp ON fs.product_id = dp.product_id
GROUP BY dp.product_name;

-- 2. Total Quantity Sold by Store
SELECT 
    ds.store_name,
    SUM(fs.quantity) AS total_quantity
FROM Fact_Sales_Star fs
JOIN Dim_Store ds ON fs.store_id = ds.store_id
GROUP BY ds.store_name;

-- 3. Monthly Sales Performance
SELECT 
    dd.month,
    dd.year,
    SUM(fs.total_amount) AS monthly_sales
FROM Fact_Sales_Star fs
JOIN Dim_Date dd ON fs.date_id = dd.date_id
GROUP BY dd.year, dd.month
ORDER BY dd.year, dd.month;

-- 4. Sales by Customer City
SELECT 
    dc.city,
    SUM(fs.total_amount) AS total_sales
FROM Fact_Sales_Star fs
JOIN Dim_Customer dc ON fs.customer_id = dc.customer_id
GROUP BY dc.city;

-- 5. Average Sale per Transaction by Product
SELECT 
    dp.product_name,
    AVG(fs.total_amount) AS avg_sale_amount
FROM Fact_Sales_Star fs
JOIN Dim_Product dp ON fs.product_id = dp.product_id
GROUP BY dp.product_name;

-- --------------------------------------------
-- ❄️ SNOWFLAKE SCHEMA DESIGN
-- --------------------------------------------

-- 📅 Month Sub-Dimension
CREATE TABLE Dim_Month (
    month_id INT PRIMARY KEY,
    month_name VARCHAR(20),
    quarter INT
);

-- 📅 Date Dimension (Normalized)
CREATE TABLE Dim_Date_Snow (
    date_id INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month_id INT,
    year INT,
    FOREIGN KEY (month_id) REFERENCES Dim_Month(month_id)
);

-- 🧾 Category Sub-Dimension
CREATE TABLE Dim_Category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);

-- 🏷️ Brand Sub-Dimension
CREATE TABLE Dim_Brand (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(50)
);

-- 📦 Product Dimension (Normalized)
CREATE TABLE Dim_Product_Snow (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    brand_id INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (category_id) REFERENCES Dim_Category(category_id),
    FOREIGN KEY (brand_id) REFERENCES Dim_Brand(brand_id)
);

-- 🌆 City Sub-Dimension
CREATE TABLE Dim_City (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

-- 👤 Customer Dimension (Normalized)
CREATE TABLE Dim_Customer_Snow (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES Dim_City(city_id)
);

-- 🌍 Region Sub-Dimension
CREATE TABLE Dim_Region (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(50)
);

-- 👨‍💼 Manager Sub-Dimension
CREATE TABLE Dim_Manager (
    manager_id INT PRIMARY KEY,
    manager_name VARCHAR(100)
);

-- 🏬 Store Dimension (Normalized)
CREATE TABLE Dim_Store_Snow (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    region_id INT,
    manager_id INT,
    FOREIGN KEY (region_id) REFERENCES Dim_Region(region_id),
    FOREIGN KEY (manager_id) REFERENCES Dim_Manager(manager_id)
);

-- 📊 Fact Table for Sales
CREATE TABLE Fact_Sales_Snowflake (
    sale_id INT PRIMARY KEY,
    date_id INT,
    product_id INT,
    customer_id INT,
    store_id INT,
    quantity INT,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (date_id) REFERENCES Dim_Date_Snow(date_id),
    FOREIGN KEY (product_id) REFERENCES Dim_Product_Snow(product_id),
    FOREIGN KEY (customer_id) REFERENCES Dim_Customer_Snow(customer_id),
    FOREIGN KEY (store_id) REFERENCES Dim_Store_Snow(store_id)
);

-- ============================================
-- ❄️ SNOWFLAKE SCHEMA: SAMPLE DATA
-- ============================================

INSERT INTO Dim_Month VALUES
(1, 'January', 1),
(2, 'February', 1),
(3, 'March', 1);

INSERT INTO Dim_Date_Snow VALUES
(1, '2024-01-15', 15, 1, 2024),
(2, '2024-02-10', 10, 2, 2024),
(3, '2024-03-05', 5, 3, 2024);

INSERT INTO Dim_Category VALUES
(1, 'Dairy'),
(2, 'Bakery'),
(3, 'Beverage');

INSERT INTO Dim_Brand VALUES
(1, 'Nestle'),
(2, 'Wonder'),
(3, 'Tropicana');

INSERT INTO Dim_Product_Snow VALUES
(1, 'Milk', 1, 1, 2.50),
(2, 'Bread', 2, 2, 1.50),
(3, 'Juice', 3, 3, 3.00);

INSERT INTO Dim_City VALUES
(1, 'Toronto', 'Ontario', 'Canada'),
(2, 'Montreal', 'Quebec', 'Canada'),
(3, 'Calgary', 'Alberta', 'Canada');

INSERT INTO Dim_Customer_Snow VALUES
(1, 'Alice Smith', 'Female', 30, 1),
(2, 'Bob Lee', 'Male', 45, 2),
(3, 'Cathy Wang', 'Female', 28, 3);

INSERT INTO Dim_Region VALUES
(1, 'East'),
(2, 'West');

INSERT INTO Dim_Manager VALUES
(1, 'Mark Taylor'),
(2, 'Sarah Davis');

INSERT INTO Dim_Store_Snow VALUES
(1, 'QuickMart Downtown', 1, 1),
(2, 'QuickMart Uptown', 2, 2);

INSERT INTO Fact_Sales_Snowflake VALUES
(1, 1, 1, 1, 1, 3, 7.50),
(2, 2, 2, 2, 1, 2, 3.00),
(3, 3, 3, 3, 2, 1, 3.00);

-- =====================================================
-- ❄️ SNOWFLAKE SCHEMA QUERIES
-- =====================================================

-- 1. Total Sales by Product Category
SELECT 
    dc.category_name,
    SUM(fs.total_amount) AS total_sales
FROM Fact_Sales_Snowflake fs
JOIN Dim_Product_Snow dp ON fs.product_id = dp.product_id
JOIN Dim_Category dc ON dp.category_id = dc.category_id
GROUP BY dc.category_name;

-- 2. Total Quantity Sold by Region
SELECT 
    dr.region_name,
    SUM(fs.quantity) AS total_quantity
FROM Fact_Sales_Snowflake fs
JOIN Dim_Store_Snow ds ON fs.store_id = ds.store_id
JOIN Dim_Region dr ON ds.region_id = dr.region_id
GROUP BY dr.region_name;

-- 3. Monthly Sales Trend
SELECT 
    dm.month_name,
    dd.year,
    SUM(fs.total_amount) AS monthly_sales
FROM Fact_Sales_Snowflake fs
JOIN Dim_Date_Snow dd ON fs.date_id = dd.date_id
JOIN Dim_Month dm ON dd.month_id = dm.month_id
GROUP BY dd.year, dm.month_name
ORDER BY dd.year, dm.month_name;

-- 4. Sales by City and Country
SELECT 
    dci.city_name,
    dci.country,
    SUM(fs.total_amount) AS total_sales
FROM Fact_Sales_Snowflake fs
JOIN Dim_Customer_Snow dc ON fs.customer_id = dc.customer_id
JOIN Dim_City dci ON dc.city_id = dci.city_id
GROUP BY dci.city_name, dci.country;

-- 5. Average Sales by Brand
SELECT 
    db.brand_name,
    AVG(fs.total_amount) AS avg_sale_amount
FROM Fact_Sales_Snowflake fs
JOIN Dim_Product_Snow dp ON fs.product_id = dp.product_id
JOIN Dim_Brand db ON dp.brand_id = db.brand_id
GROUP BY db.brand_name;

