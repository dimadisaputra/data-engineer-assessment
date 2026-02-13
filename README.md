# Data Engineer Technical Assessment

## Overview
Hi, I'm **Dimas Adi Saputra**, a Results-oriented Data Engineer with 1+ year of experience in building automated ETL pipelines and web scrapers. I am passionate about leveraging data for automation and smarter business decisions.

In this assessment, I focused on creating clean, maintainable, and scalable solutions.
- **SQL Assessment**: Designed a normalized schema and optimized queries for business insights.
- **ETL Assessment**: Built a robust Python script to clean and standardize messy location data, ensuring data integrity for downstream analysis.
- **Visualization**: Created an actionable dashboard to monitor inventory health and operational efficiency.

**Note**: The Big Data Pipeline assessment (Section 4) is located in a separate repository:
[https://github.com/dimadisaputra/retail360](https://github.com/dimadisaputra/retail360)

## Tools Used
### Project Stack
- **Languages**: Python 3.12, SQL
- **Libraries**: 
  - `pandas` (Data manipulation)
  - `openpyxl` (Excel I/O)
  - `difflib` (Fuzzy matching for data cleaning)
- **Visualization**: Looker Studio
- **Version Control**: Git

### Big Data Pipeline (Section 4)
- **Orchestration**: Apache Airflow 2.10.4
- **Date Processing**: Apache Spark 3.5.1 (PySpark)
- **Storage**: MinIO (Data Lake), PostgreSQL 16 (Data Mart)
- **Visualization**: Metabase
- **Infrastructure**: Docker, Docker Compose

### Key Software Versions
- **Python**: 3.12+
- **Pandas**: >= 3.0.0

## Setup Instructions

### Prerequisites
Ensure you have Python 3.12 installed.

1. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   # OR using pyproject.toml
   pip install .
   ```

### 1. SQL Assessment
Navigate to `1-sql-assessment/queries/` and execute the scripts in the following order to set up the database and run analysis:
1. `CREATE_DATABASE.sql` - Sets up the schema.
2. `CREATE_TABLE.sql` - Creates the necessary tables.
3. `INSERT_TABLE.sql` - Populates tables with dummy data.
4. Run analytical queries:
   - `QUERY_INVENTORY_TURNOVER.sql`
   - `QUERY_CUSTOMER_PURCHAES_PATTERN.sql`
   - `QUERY_STAFF_PEFORMANCE.sql`

*See `1-sql-assessment/DASHBOARD_SUGGESTION.md` for the dashboard proposal.*

### 2. ETL Assessment
The ETL script processes asset data, normalizes city names, and enriches it with master data.
To run the pipeline:
```bash
python 2-etl-assessment/src/main.py
```
- **Input**: `2-etl-assessment/data/` (City Indonesia.xlsx, Assessment Data Asset Dummy.xlsx)
- **Output**: Enriched data and reports are saved to `2-etl-assessment/data/` and `2-etl-assessment/logs/`.

### 3. Visualization
You can view the **Koperasi Operations Dashboard** here:
[View Dashboard on Looker Studio](https://lookerstudio.google.com/reporting/9d7b6722-194b-46d5-945f-d67df3ed6e66)

*Screenshots and a PDF export are available in the `3-visualization` folder.*

## Time Spent
- **1. SQL Assessment**: ~2 hours (Schema design, query optimization, dummy data generation)
- **2. ETL Assessment**: ~2 hours (Scripting logic, handling edge cases/dirty data, logging)
- **3. Visualization**: ~1.5 hours (Dashboard layout, connecting data sources)
- **4. Big Data Pipeline**: ~6 hours (Separate repository implementation)

## AI Utilization

### 1. Mock Data Generation
I used AI to generate realistic dummy data to populate the SQL tables, ensuring data integrity and variety for testing.

**Build Prompt:**
> "Generate 50 SQL INSERT statements for the `inventory` table. Ensure `expiry_date` is always at least 3 months after the `manufacturing_date` and `stock_level` varies between 0 and 100."

### 2. Code Optimization
AI suggested efficient logic to handle specific dirty data patterns that standard normalization missed.

**Prompt Used:**
> "I have inconsistent city names from user input.
> 1. 'FAK FAK' should be normalized to 'FAKFAK'.
> 2. 'OKU TIMUR' (and other OKU variations) should map to 'KABUPATEN OGAN KOMERING ULU TIMUR'.
> 3. ambiguous names like 'JAKARTA' should be flagged as invalid because we need the specific administrative city (e.g., Jakarta Selatan).
>
> Please write a Python function with specific rules to handle these cases before trying fuzzy matching."

### 3. Error Debugging
I utilized AI to trace and resolve specific errors encountered during the development of the ETL pipeline.

**Prompt Used:**
> "I am getting a `ValueError: cannot convert float NaN to integer` when creating the `Internal_Site_ID` from the `RegionalCode` column. The column contains some null values. How should I handle this in Pandas before string formatting?"

### 4. Logic Fixes
AI helped resolve a logic flaw in the inventory calculation where filtering data caused incorrect stock levels.

**Prompt Used:**
> "My query calculates `current_stock_level` based on transactions from the last 3 months, resulting in negative values because prior stock accumulation is ignored. How can I adjust the SQL to include the initial stock balance while keeping the report focused on recent activity?"
