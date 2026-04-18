# SQL Data Warehouse Project

An end-to-end SQL data warehousing project that transforms raw source data into a clean, analytics-ready dimensional model for reporting and business intelligence.

This project demonstrates practical data engineering skills including ETL development, data modeling, data quality checks, and warehouse design using SQL.

---

## Project Objective

Build a modern data warehouse that consolidates data from multiple source systems into a centralized reporting layer.

The warehouse is designed to support:

- Sales performance reporting  
- Customer analysis  
- Product insights  
- Trend analysis  
- Reliable self-service analytics

---

## Architecture

This project follows a medallion architecture warehouse design:

### Bronze Layer
Raw source data loaded as-is into staging tables.

### Silver Layer
Cleaned, standardized, and transformed data with improved quality and consistency.

### Gold Layer
Business-ready dimensional model using fact and dimension tables optimized for analytics.

---

## Data Model

Star schema design used for reporting performance and usability.

### Fact Tables
- FactSales

### Dimension Tables
- DimCustomer  
- DimProduct  
- DimDate
---

## Key Skills Demonstrated

- SQL Development  
- ETL Pipeline Design  
- Data Cleansing & Transformation  
- Star Schema Modeling  
- Fact / Dimension Design  
- Query Optimization  
- Data Validation  
- Git / Version Control

---

## Example Business Questions Answered

- What products generate the most revenue?
- Which customers purchase most frequently?
- How are sales trending over time?
- Which regions perform best?
- What categories are growing or declining?

---

## Tech Stack

- SQL Server / T-SQL  
- SSMS  
- GitHub  
- CSV Source Files

---

## Repository Structure

```text
sql-data-warehouse-project/
│── datasets/
│── scripts/
│   │── bronze/
│   │── silver/
│   │── gold/
│── docs/
│── tests/
│── README.md
