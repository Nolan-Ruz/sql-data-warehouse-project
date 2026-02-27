/*
====================================================================
Quality Checks
====================================================================

Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schema. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
====================================================================
*/

-- Check for Duplicates and Null values in the key
-------------------
-- crm_cust_info
-------------------
SELECT 
	cst_id,
	COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Check String values for unwanted spaces
SELECT cst_firstname FROM silver.crm_cust_info WHERE cst_firstname != TRIM(cst_firstname);
SELECT cst_lastname FROM silver.crm_cust_info WHERE cst_lastname != TRIM(cst_lastname);
SELECT cst_marital_status FROM silver.crm_cust_info WHERE cst_marital_status != TRIM(cst_marital_status);
SELECT cst_gndr FROM silver.crm_cust_info WHERE cst_gndr != TRIM(cst_gndr);

-- Check for distinct values in classification columns
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;

-------------------
-- crm_prd_info
-------------------

-- Check for Null and Dups in key
SELECT 
	prd_id, 
	COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 AND prd_id IS NULL

-- Check String values for unwanted spaces
SELECT prd_nm FROM silver.crm_prd_info WHERE prd_nm != TRIM(prd_nm);
SELECT prd_line FROM silver.crm_prd_info WHERE prd_line != TRIM(prd_line);

-- Check for NULLs or Negatives
SELECT prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Check for distinct values in classification columns
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

-- Check for Invalid Date Orders
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-------------------
-- crm_sales_details
-------------------

-- Check Keys
SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT DISTINCT prd_key FROM silver.crm_prd_info); 

SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT DISTINCT cst_id FROM silver.crm_cust_info);

-- Check for Invalid Dates
SELECT 
    sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL
    OR sls_order_dt > '2050-01-01'
    OR sls_order_dt < '1900-01-01'

-- Check for Invalid Date Orders
SELECT
	*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check sales Qauntity and price
SELECT  
	sls_sales as old_sls_sales,
	sls_quantity,
	sls_price as old_sls_price,
	CASE 
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END sls_sales,
	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales < 0 OR sls_quantity < 0 OR sls_price < 0
ORDER BY sls_sales, sls_quantity, sls_price

-------------------
-- erp_cust_az12
-------------------

-- Check valid dates

SELECT DISTINCT 
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Check low cardinality values

SELECT DISTINCT 
	gen
FROM silver.erp_cust_az12

-------------------
-- erp_loc_a101
-------------------

-- Check low cardinality values
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry

-------------------
-- erp_px_cat_g1v2
-------------------

-- check for bad strings
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Check low cardinality 
SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2
