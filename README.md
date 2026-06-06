
# Swiggy Data Analytics & Data Warehousing Project
    
## 📌 Project Overview
An end-to-end data analytics project migrating raw food delivery operations data into a structured dimensional 
SQL queries are implemented to handle data audits, treat duplicate redundancies, 
and extract high-level business Key Performance Indicators (KPIs).
  
 * **Dataset Name:** Swiggy sales Dataset

## 🚀 Live Interactive Workspace
The full dataset execution, environment pipeline, and live interactive tables can be viewed directly on Kaggle:
👉 **[View My Live Kaggle Notebook](https://www.kaggle.com/code/nitishadhamija/notebook4f3f16ebf1/edit)**
 
## 🏗️ Data Warehouse Architecture (Star Schema)

The raw transactional table (`swiggy_table`) was normalized and 
re-engineered into a highly scalable **Star Schema** 
data warehouse structure to optimize query performance and data structural integrity.
  
[dim_date]           [dim_location]
           │                      │
           └───► [fact_swiggy_orders] ◄──┘
                     ▲      ▲
           ┌─────────┘      └─────────┐
           │                          │
    [dim_restaurant]            [dim_category]
                                      ▲
                                      │
                                  [dim_dish]

**`fact_swiggy_orders` (The Center):** This table holds only the numbers for each order—like the price, the customer rating, and ID numbers that link out to the other tables.
* **`dim_date`:** Handles the timing. It breaks dates down into the exact Year, Quarter, Month Name, and the Day of the Week.
* **`dim_location`:** Handles geography. It maps out exactly which State, City, and local region the order came from.
* **`dim_restaurant`:** A clean list of all unique restaurant names.
* **`dim_category`:** Tracks food categories and cuisine styles (like North Indian, Chinese, Desserts).
* **`dim_dish`:** A master list of every unique dish name ordered.
---
## 🛠️ What I Did (The Data Engineering Pipeline)

1. **Found Missing Data:** I wrote SQL queries to scan the entire dataset to find and handle empty spaces, blank strings, and missing numbers.
2. **Deleted Duplicate Orders:** Sometimes the same order gets logged twice by accident. I used advanced SQL window functions (`ROW_NUMBER()`) to find and completely delete multi-column duplicate rows so the insights are 100% accurate.
3. **Fixed Dates and Text:** Raw dates look like text strings (e.g., "29-06-2025"). I converted them into standard database dates (`YYYY-MM-DD`) and turned text prices into actual numbers that math can be done on.
4. **Built the Warehouse:** I generated automatic ID keys for all the lookup tables and used SQL joins to link everything perfectly into the central Fact Table.
---
## 📊 Core Business Insights & KPIs
By running optimized SQL queries on my newly built data warehouse, I extracted these clean business metrics:

### 1. Executive Dashboard KPIs
* **`Total_Orders`**: Tracks the exact number of successful food orders processed on the platform.
* **`Total_Revenue`**: Calculates the total sales amount, formatted cleanly in Millions (e.g., `12.45 M`) for business presentations.
* **`Avg_Price`**: Shows the average cost of a dish on Swiggy, formatted cleanly in Indian Rupees (₹).
* **`Avg_Rating`**: Gives the overall average customer satisfaction score across all restaurants.

### 2. Trends & Market Analysis
* **Time Trends:** Tracks how order volumes change by Year, Quarter, and Month to find seasonal peaks.
* **Weekly Patterns:** Groups orders by the day of the week (Monday to Sunday) to show exactly how much food demand spikes on weekends.
* **Location Hotspots:** Ranks the Top 10 cities by order volume and shows which States contribute the most revenue.
* **Food Favorites:** Extracts the top 10 most popular cuisines and specific dish names people order the most.
---
## 💻 Tools Used
* **Language:** Python 3
* **Database Engine:** SQL / SQLite (via the `sqlite3` library)
* **Data Processing:** Pandas
* **Charts & Graphs:** Matplotlib and Seaborn
