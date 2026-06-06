# ============================================================================
# PROJECT: SWIGGY SALES DATA 
# AUTHOR: Nitisha
# ENVIRONMENT: Kaggle Notebook (Python 3 Container with SQLite3 Relational Engine)
# DATA INPUT PATH: /kaggle/input/datasets/nitishadhamija/swiggy/Swiggy_Data.csv
# TOTAL clean PRODUCTION CAPACITY: 196,493 Rows
# This Python 3 environment comes with many helpful analytics libraries installed
# It is defined by the kaggle/python Docker image: https://github.com/kaggle/docker-python
# For example, here's several helpful packages to load

import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)

# Input data files are available in the read-only "../input/" directory
# For example, running this (by clicking run or pressing Shift+Enter) will list all files under the input directory

import os
for dirname, _, filenames in os.walk('/kaggle/input'):
    for filename in filenames:
        print(os.path.join(dirname, filename))

# You can write up to 20GB to the current directory (/kaggle/working/) that gets preserved as output when you create a version using "Save & Run All" 
# You can also write temporary files to /kaggle/temp/, but they won't be saved outside of the current session

# Use the kagglehub client library to attach Kaggle resources like competitions, datasets, and models to your session
# Learn more about kagglehub: https://github.com/Kaggle/kagglehub/blob/main/README.md

import kagglehub
# kagglehub.dataset_download('<owner>/<dataset-slug>')
import pandas as pd
import sqlite3

# FIXED: Pointing directly to the Swiggy_Data.csv file inside the folder
df = pd.read_csv('/kaggle/input/datasets/nitishadhamija/swiggy/Swiggy_Data.csv')

# Connects to your cloud SQL database
conn = sqlite3.connect('swiggy_database.db')
df.to_sql('swiggy_table', conn, if_exists='replace', index=False)

print("SQL Database is ready!")

# =======================================================
#   WRITE YOUR PURE SQL QUERY INSIDE THE TRIPLE QUOTES:
# =======================================================
query = """

SELECT * FROM swiggy_table 
LIMIT 10000

"""
# =======================================================

# This runs your SQL and displays your data table
pd.read_sql_query(query, conn)
import pandas as pd
import sqlite3

# 1. Load the data
df = pd.read_csv('/kaggle/input/datasets/nitishadhamija/swiggy/Swiggy_Data.csv')
conn = sqlite3.connect('swiggy_database.db')
cursor = conn.cursor()
df.to_sql('swiggy_table', conn, if_exists='replace', index=False)

# ===================================================================
# 2. THE FIX: This forces Kaggle to show ALL rows and columns on screen
# ===================================================================
pd.set_option('display.max_rows', None)    
pd.set_option('display.max_columns', None) 
# ===================================================================

# 3. Your SQL Query (Make sure there is NO "LIMIT 10" at the bottom!)
query = """
SELECT DISTINCT State, City 
FROM swiggy_table
ORDER BY State, City;
"""

# 4. Run and display everything
pd.read_sql_query(query, conn)
query = """
SELECT 
    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN `Order Date` IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_loc,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_cate,
    SUM(CASE WHEN `Dish Name` IS NULL THEN 1 ELSE 0 END) AS null_DishName,
    SUM(CASE WHEN `Price (INR)` IS NULL THEN 1 ELSE 0 END) AS null_Price,
    SUM(CASE WHEN `Restaurant Name` IS NULL THEN 1 ELSE 0 END) AS null_restaurant,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_Rating,
    SUM(CASE WHEN `Rating Count` IS NULL THEN 1 ELSE 0 END) AS null_RatingCount
FROM swiggy_table;
"""
# =======================================================

# This runs your count check and displays the results nicely
pd.read_sql_query(query, conn)
query = """
SELECT * FROM swiggy_table
WHERE State = '' 
   OR City = '' 
   OR `Order Date` = ''  
   OR `Restaurant Name` = '' 
   OR Location = '' 
   OR Category = '' 
   OR `Dish Name` = '' 
   OR Rating = '' 
   OR `Rating Count` = '';
"""
# =======================================================

# This runs your query and shows any rows that have empty strings
pd.read_sql_query(query, conn)
duplicate_check_query = """
SELECT 
    State, City, `Order Date`, `Restaurant Name`,
    Location, Category, `Price (INR)`, COUNT(*) as cnt 
FROM swiggy_table 
GROUP BY 
    State, City, `Order Date`, `Restaurant Name`, `Price (INR)`,
    Location, Category
HAVING COUNT(*) > 1;
"""

print("--- DUPLICATE ROWS FOUND ---")
duplicates_df = pd.read_sql_query(duplicate_check_query, conn)
print(duplicates_df)


# =======================================================
#   2. DELETE DUPLICATES & KEEP ONLY UNIQUE ROWS
# =======================================================
# Since SQLite doesn't allow 'DELETE FROM CTE', we select the clean data 
# using ROW_NUMBER() and overwrite the table with just the unique records (RN = 1)

clean_data_query = """
WITH CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER(
               PARTITION BY State, City, `Order Date`, `Restaurant Name`, `Price (INR)`, Location, Category 
               ORDER BY `Order Date`
           ) AS RN
    FROM swiggy_table
)
SELECT State, City, `Order Date`, `Restaurant Name`, Location, Category, `Price (INR)`, Rating, `Rating Count`
FROM CTE 
WHERE RN = 1;
"""

# Fetch the clean rows into Python
df_clean = pd.read_sql_query(clean_data_query, conn)

# Overwrite 'swiggy_table' inside the SQL database with the completely unique data
df_clean.to_sql('swiggy_table', conn, if_exists='replace', index=False)

print("\n--- DUPLICATES REMOVED SUCCESSFULY ---")
print(f"Total rows left in your clean dataset: {len(df_clean)}")
cursor.execute("""
CREATE TABLE dim_date (
    date_id INTEGER PRIMARY KEY,
    full_date TEXT,
    year INTEGER, 
    month INTEGER,
    month_name TEXT,
    quarter INTEGER,
    day INTEGER,
    week INTEGER
);
""")
cursor.execute("""
CREATE TABLE dim_location (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    State TEXT,
    City TEXT,
    Location TEXT
);
""")

# Created directly with backticks to match your preferred naming format
cursor.execute("""
CREATE TABLE dim_restaurant (
    restaurant_id INTEGER PRIMARY KEY AUTOINCREMENT,
    `Restaurant Name` TEXT
);
""")

cursor.execute("""
CREATE TABLE dim_category (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    Category TEXT
);
""")

cursor.execute("""
CREATE TABLE dim_dish (
    dish_id INTEGER PRIMARY KEY AUTOINCREMENT,
    `Dish Name` TEXT
);
""")

cursor.execute("""
CREATE TABLE fact_swiggy_orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    date_id INTEGER,
    `Price (INR)` REAL,
    Rating REAL,
    `Rating Count` INTEGER,
    location_id INTEGER,
    restaurant_id INTEGER,
    category_id INTEGER,
    dish_id INTEGER,
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (location_id) REFERENCES dim_location(location_id),
    FOREIGN KEY (restaurant_id) REFERENCES dim_restaurant(restaurant_id),
    FOREIGN KEY (category_id) REFERENCES dim_category(category_id),
    FOREIGN KEY (dish_id) REFERENCES dim_dish(dish_id)
);
""")
conn.commit()
print("⭐ Schema Created Successfully!")
# Query the hidden SQLite master table to get all user-created tables
tables = pd.read_sql_query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';", conn)

print("============ DATA WAREHOUSE SCHEMA STRUCTURE ============")
for table_name in tables['name']:
    print(f"\n📋 TABLE: {table_name}")
    print("--------------------------------------------------")
    # PRAGMA table_info lists column id, name, type, nullability, and keys
    info = pd.read_sql_query(f"PRAGMA table_info({table_name});", conn)
    display(info[['name', 'type', 'pk']])
# 4. POPULATE DIMENSION TABLES (Using Pandas for complex Date/String manipulation)
# =======================================================

# Load fresh copy of your clean data
df_raw = pd.read_csv('/kaggle/input/datasets/nitishadhamija/swiggy/Swiggy_Data.csv')
# Dropping duplicates based on your unique combination rules to keep dimensions clean
df_swiggy = df_raw.drop_duplicates(subset=['State', 'City', 'Order Date', 'Restaurant Name', 'Price (INR)', 'Location', 'Category']).copy()

# A. Populate dim_date using Pandas string parsing (Fast & Error-Free)
df_swiggy['Parsed_Date'] = pd.to_datetime(df_swiggy['Order Date'], format='%d-%m-%Y', errors='coerce')
df_date_clean = df_swiggy.dropna(subset=['Parsed_Date']).copy()

dim_date_df = pd.DataFrame()
dim_date_df['date_id'] = df_date_clean['Parsed_Date'].dt.strftime('%Y%m%d').astype(int)
dim_date_df['full_date'] = df_date_clean['Parsed_Date'].dt.strftime('%Y-%m-%d')
dim_date_df['year'] = df_date_clean['Parsed_Date'].dt.year
dim_date_df['month'] = df_date_clean['Parsed_Date'].dt.month
dim_date_df['month_name'] = df_date_clean['Parsed_Date'].dt.strftime('%B')
dim_date_df['quarter'] = df_date_clean['Parsed_Date'].dt.quarter
dim_date_df['day'] = df_date_clean['Parsed_Date'].dt.day
dim_date_df['week'] = df_date_clean['Parsed_Date'].dt.isocalendar().week.astype(int)
dim_date_df = dim_date_df.drop_duplicates(subset=['date_id'])
dim_date_df.to_sql('dim_date', conn, if_exists='append', index=False)

# B. Populate dim_location
dim_location_df = df_swiggy[['State', 'City', 'Location']].drop_duplicates().dropna()
dim_location_df.to_sql('dim_location', conn, if_exists='append', index=False)

# C. Populate dim_restaurant
dim_restaurant_df = df_swiggy[['Restaurant Name']].drop_duplicates().dropna()
dim_restaurant_df.to_sql('dim_restaurant', conn, if_exists='append', index=False)

# D. Populate dim_category
dim_category_df = df_swiggy[['Category']].drop_duplicates().dropna()
dim_category_df.to_sql('dim_category', conn, if_exists='append', index=False)

# E. Populate dim_dish
dim_dish_df = df_swiggy[['Dish Name']].drop_duplicates().dropna()
dim_dish_df.to_sql('dim_dish', conn, if_exists='append', index=False)

print("🚀 Dimension Tables Populated Successfully!")

# =======================================================
# 5. POPULATE FACT TABLE (Using SQLite Join Architecture)
# =======================================================

# Temporarily write your clean working dataframe to a staging table so SQLite can join it
df_swiggy['Formatted_Order_Date'] = df_swiggy['Parsed_Date'].dt.strftime('%Y-%m-%d')
df_swiggy.to_sql('stg_swiggy', conn, if_exists='replace', index=False)

cursor.execute("""
INSERT INTO fact_swiggy_orders (date_id, `Price (INR)`, Rating, `Rating Count`, location_id, restaurant_id, category_id, dish_id)
SELECT 
    dd.date_id,
    s.`Price (INR)`,
    s.Rating,
    s.`Rating Count`,
    dl.location_id,
    dr.restaurant_id,
    dc.category_id,
    dsh.dish_id
FROM stg_swiggy s
JOIN dim_date dd ON dd.full_date = s.Formatted_Order_Date
JOIN dim_location dl ON dl.State = s.State AND dl.City = s.City AND dl.Location = s.Location
JOIN dim_restaurant dr ON dr.`Restaurant Name` = s.`Restaurant Name`
JOIN dim_category dc ON dc.Category = s.Category
JOIN dim_dish dsh ON dsh.`Dish Name` = s.`Dish Name`;
""")
conn.commit()

# Clean up staging table
cursor.execute("DROP TABLE IF EXISTS stg_swiggy;")
print("⚙️ Fact Table Built and Connected!")
# Setting Pandas to display tables beautifully
pd.set_option('display.max_columns', None)

print("==================================================")
print("1. CENTRAL FACT TABLE SAMPLE (fact_swiggy_orders)")
print("==================================================")
# The Fact Table contains metrics and numeric ID keys pointing to dimensions
print(pd.read_sql_query("SELECT * FROM fact_swiggy_orders LIMIT 5;", conn))

print("\n==================================================")
print("2. DIMENSION TABLES SAMPLES")
print("==================================================")

print("\n📋 dim_location (Mapping IDs to States, Cities, & Regions):")
print(pd.read_sql_query("SELECT * FROM dim_location LIMIT 3;", conn))

print("\n📋 dim_date (Mapping IDs to Calendar Trends):")
print(pd.read_sql_query("SELECT * FROM dim_date LIMIT 3;", conn))

print("\n📋 dim_restaurant (Unique Restaurant Records):")
print(pd.read_sql_query("SELECT * FROM dim_restaurant LIMIT 3;", conn))

print("\n📋 dim_dish (Unique Food Items):")
print(pd.read_sql_query("SELECT * FROM dim_dish LIMIT 3;", conn))

print("\n📋 dim_category (Food Categories):")
print(pd.read_sql_query("SELECT * FROM dim_category LIMIT 3;", conn))
# 6. RUN AND PRINT KPI QUERIES (SQLite Adaptations)
# =======================================================
# Setting Pandas options to print out all of your analysis fields clearly
pd.set_option('display.max_rows', None)
pd.set_option('display.max_columns', None)

print("\n=== KPI 1: TOTAL ORDERS ===")
print(pd.read_sql_query("SELECT COUNT(*) AS Total_Orders FROM fact_swiggy_orders;", conn))

print("\n=== KPI 2: TOTAL REVENUE ===")
print(pd.read_sql_query("SELECT ROUND(SUM(`Price (INR)`), 2) AS Total_Revenue FROM fact_swiggy_orders;", conn))

print("\n=== KPI 3: AVERAGE DISH PRICE ===")
print(pd.read_sql_query("SELECT ROUND(AVG(`Price (INR)`), 2) AS Avg_Price FROM fact_swiggy_orders;", conn))

print("\n=== KPI 4: AVERAGE RATING ===")
print(pd.read_sql_query("SELECT ROUND(AVG(Rating), 2) AS Avg_Rating FROM fact_swiggy_orders WHERE Rating IS NOT NULL AND Rating != '';", conn))

print("\n=== ANALYSIS: MONTHLY ORDER TREND ===")
query_monthly = """
SELECT year, month, month_name, COUNT(*) as total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY year, month, month_name
ORDER BY year, month;
"""
print(pd.read_sql_query(query_monthly, conn))

print("\n=== ANALYSIS: ORDERS BY DAY OF WEEK ===")
# SQLite uses strftime('%w', full_date) for day numbers (0=Sunday) and strftime('%A') for names
query_dow = """
SELECT 
    CASE strftime('%w', d.full_date)
        WHEN '0' THEN 'Sunday' WHEN '1' THEN 'Monday' WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday' WHEN '4' THEN 'Thursday' WHEN '5' THEN 'Friday'
        WHEN '6' THEN 'Saturday' END AS day_name,
    COUNT(*) AS total_orders
FROM fact_swiggy_orders f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY day_name
ORDER BY strftime('%w', d.full_date);
"""
print(pd.read_sql_query(query_dow, conn))

print("\n=== TOP 10 CITIES BY ORDER VOLUME ===")
query_cities = """
SELECT l.City, COUNT(*) AS Total_Orders 
FROM fact_swiggy_orders f
JOIN dim_location l ON l.location_id = f.location_id
GROUP BY l.City
ORDER BY Total_Orders DESC
LIMIT 10;
"""
print(pd.read_sql_query(query_cities, conn))

print("\n=== REVENUE CONTRIBUTION BY STATES ===")
query_states = """
SELECT l.State, ROUND(SUM(f.`Price (INR)`), 2) AS Total_Revenue 
FROM fact_swiggy_orders f
JOIN dim_location l ON l.location_id = f.location_id
GROUP BY l.State
ORDER BY Total_Revenue DESC;
"""
print(pd.read_sql_query(query_states, conn))
print("\n=== KPI 2: TOTAL REVENUE (IN MILLIONS) ===")
print(pd.read_sql_query("SELECT ROUND(SUM(`Price (INR)`) / 1000000.0, 2) || ' M' AS Total_Revenue FROM fact_swiggy_orders;", conn))
print("\n=== KPI 3: AVERAGE DISH PRICE (INR) ===")
print(pd.read_sql_query("SELECT '₹ ' || ROUND(AVG(`Price (INR)`), 2) AS Avg_Price FROM fact_swiggy_orders;", conn))
