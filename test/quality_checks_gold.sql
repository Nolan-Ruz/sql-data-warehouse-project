/*
===============================================================================
Quality Checks
===============================================================================

Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ===========================================
-- Dim Customer
-- ===========================================
-- Checking for Uniqueness of Customer Number in Dim Customer
-- Expectation: No Results

SELECT customer_number, COUNT(*)
FROM
(
	SELECT
		ci.cst_id customer_id,
		ci.cst_key customer_number,
		ci.cst_firstname first_name,
		ci.cst_lastname last_name,
		la.cntry country,
		ci.cst_marital_status marital_status,
		CASE WHEN ci.cst_gndr != 'NA' THEN ci.cst_gndr
			ELSE COALESCE(ci.cst_gndr, 'NA')
		END as gender,
		ca.bdate birth_date,
		ci.cst_create_date create_date
	FROM silver.crm_cust_info ci
	LEFT JOIN silver.erp_cust_az12 ca 
		ON ci.cst_key = ca.cid
	LEFT JOIN silver.erp_loc_a101 la
		ON ci.cst_key = la.cid
)t1
GROUP BY customer_number
HAVING COUNT(*) > 1;

-- ========================================
-- Dim Product
-- ========================================
-- Checking for Uniqueness of Product Number in Dim Product
-- Expectation: No Results

SELECT product_number, COUNT(*)
FROM
(
SELECT 
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
	LEFT JOIN silver.erp_px_cat_g1v2 erp ON crm.cat_id = erp.id 
WHERE prd_end_dt IS NULL) t1
GROUP BY product_number
HAVING COUNT(*) > 1;

-- ========================================
-- Fact Sales
-- ========================================
-- Checking for Missing or Missmachted Product and Customer 
-- Expectation: No Results

SELECT * 
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc
	ON fs.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
	ON fs.product_key = dp.product_key
WHERE fs.customer_key IS NULL OR fs.product_key IS NULL;
