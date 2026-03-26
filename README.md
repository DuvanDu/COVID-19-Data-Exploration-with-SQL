# 🦠 COVID-19 Data Exploration with SQL

## 📋 Project Overview

This project explores global COVID-19 data using PostgreSQL. It analyzes infection rates, death counts, vaccination rollouts, and more — across countries, continents, and time periods — using real-world data from [Our World in Data](https://ourworldindata.org/covid-deaths).

---

## 🗄️ Dataset

The dataset is split into two tables:

| Table | Description |
|-------|-------------|
| `coviddeaths` | Daily COVID-19 cases, deaths, and population data per country |
| `covidvaccinations` | Daily vaccination, testing, and socioeconomic data per country |

> **Note:** In this dataset, when `continent IS NULL`, the `country` column contains continent-level and global aggregates (e.g., `World`, `Europe`, `High income`). This is a quirk of the Our World in Data format and is handled throughout the queries.

---

## 🛠️ SQL Skills Used

- Joins
- CTEs (Common Table Expressions)
- Temporary Tables
- Window Functions
- Aggregate Functions
- Creating Views
- Data Type Conversion
- NULLIF for safe division

---

## 📁 File Structure

```
├── covid_exploration.sql       -- Main SQL query file
├── README.md                   -- Project documentation
```

---

## 🔍 Queries Breakdown

### 1. Initial Data Exploration
Basic `SELECT` statements to inspect both tables and identify the columns used throughout the analysis.

### 2. Total Cases vs Total Deaths
Calculates the **death percentage** per day in Colombia — showing the likelihood of dying if you contracted COVID during that period.

### 3. Total Cases vs Population
Shows the **percentage of Colombia's population** that got infected with COVID over time.

### 4. Countries with Highest Infection Rate
Ranks all countries by their **peak infection rate** relative to their population.

### 5. Countries with Highest Death Count
Ranks countries by **total deaths** and death percentage of population, excluding continent-level aggregates.

### 6. Continents with Highest Death Count
Aggregates death data at the **continent level**.

### 7. Global Aggregates
Queries rows where `continent IS NULL` to get **continent and world-level totals** from the dataset's aggregate rows.

### 8. Global Numbers
- **All-time global totals**: ~1% of all infected people died from COVID-19
- **Daily global breakdown**: new cases, deaths, and death rate per day worldwide

### 9. Population vs Vaccinations (Rolling Total)
Joins both tables and uses a **Window Function** to calculate a rolling cumulative vaccination count per country over time.

### 10. Vaccination Percentage — CTE
Uses a **CTE** to calculate what percentage of each country's population has been vaccinated using the rolling total.

### 11. Vaccination Percentage — Temp Table
Same calculation as above but using a **Temporary Table** for reusability within the session.

### 12. Create View
Stores the rolling vaccination query as a **View** for use in future queries, dashboards, or data visualization tools.

---

## ⚙️ How to Run

### Prerequisites
- PostgreSQL 12+
- pgAdmin 4 (or any PostgreSQL client)
- COVID-19 dataset CSV files from [Our World in Data](https://ourworldindata.org/covid-deaths)

### Setup Steps

1. **Create the tables** by running the `CREATE TABLE` statements for `coviddeaths` and `covidvaccinations`

2. **Import the CSV files** using pgAdmin's Import/Export tool or the COPY command:
```sql
SET datestyle = 'ISO, MDY';

COPY coviddeaths
FROM '/path/to/coviddeaths.csv'
DELIMITER ','
CSV HEADER;

COPY covidvaccinations
FROM '/path/to/covidvaccinations.csv'
DELIMITER ','
CSV HEADER;
```

3. **Run the queries** in `covid_exploration.sql` sequentially

---

## 💡 Key Findings

- Globally, approximately **1% of all COVID-19 confirmed cases resulted in death**
- Some countries reported vaccination percentages **over 100%** due to booster shots being counted as additional vaccinations, not unique individuals
- Continent-level and global aggregate rows are stored in the `country` column with a `NULL` continent — always filter with `WHERE continent IS NOT NULL` when querying country-level data to avoid double counting

---

## 📊 Suggested Visualizations

After running the queries, these views/results are great candidates for dashboards:

- Death percentage over time per country (line chart)
- Top 10 countries by infection rate (bar chart)
- Rolling vaccinations vs population (area chart)
- Global daily cases and deaths (dual-axis line chart)

---

## 👤 Author

Data exploration project using PostgreSQL and pgAdmin 4.  
Dataset source: [Our World in Data — COVID-19](https://ourworldindata.org/covid-deaths)
