/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================

Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- ================================================================
-- Dim Customer
-- ================================================================
  
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    ci.cst_id customer_id,
    ci.cst_key customer_number,
    ci.cst_firstname first_name,
    ci.cst_lastname last_name,
    la.cntry country,
    ci.cst_marital_status marital_status,
    CASE 
        WHEN ci.cst_gndr != 'NA' THEN ci.cst_gndr
        ELSE COALESCE(ci.cst_gndr, 'NA')
    END AS gender,
    ca.bdate birth_date,
    ci.cst_create_date create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO

-- ================================================================
-- Dim Product
-- ================================================================
  
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY crm.prd_start_dt, crm.prd_key) product_key,
    crm.prd_id product_id,
    crm.prd_key product_number,
    crm.prd_nm product_name,
    crm.cat_id category_id,
    erp.cat category,
    erp.subcat sub_category,
    erp.maintenance maintenance_flag,
    crm.prd_cost cost,
    crm.prd_line product_line,
    crm.prd_start_dt start_date
FROM silver.crm_prd_info crm
LEFT JOIN silver.erp_px_cat_g1v2 erp 
    ON crm.cat_id = erp.id 
WHERE prd_end_dt IS NULL;
GO
-- ================================================================
-- Fact Sales
-- ================================================================
  
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num order_number,
    dp.product_key,
    dc.customer_key,
    sd.sls_order_dt order_date,
    sd.sls_ship_dt shipping_date,
    sd.sls_due_dt due_date,
    sd.sls_sales sales_amount,
    sd.sls_quantity quantity,
    sd.sls_price price
FROM silver.crm_sales_details sd 
LEFT JOIN gold.dim_customers dc 
    ON sd.sls_cust_id = dc.customer_id
LEFT JOIN gold.dim_products dp 
    ON sd.sls_prd_key = dp.product_number;
GO

-- ================================================================
-- Dim Date
-- ================================================================

IF OBJECT_ID('gold.dim_date', 'V') IS NOT NULL
    DROP VIEW gold.dim_date;
GO

CREATE VIEW gold.dim_date AS
WITH n AS (
    SELECT TOP (9497)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS num
    FROM sys.objects
)
SELECT
    CONVERT(INT, FORMAT(DATEADD(DAY, num, '2010-01-01'), 'yyyyMMdd')) AS date_key,
    DATEADD(DAY, num, '2010-01-01') AS full_date,
    YEAR(DATEADD(DAY, num, '2010-01-01')) AS year,
    MONTH(DATEADD(DAY, num, '2010-01-01')) AS month_number,
    DATENAME(MONTH, DATEADD(DAY, num, '2010-01-01')) AS month_name,
    DAY(DATEADD(DAY, num, '2010-01-01')) AS day_number
FROM n;
GO
