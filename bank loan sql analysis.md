# Bank Loan Portfolio Analysis — SQL Analysis Documentation

**Tool Used:** MySQL Workbench  
**Database:** bank_loan_db  
**Table:** bank_loan  
**Total Records:** 38,576  
**Source File:** bank_loan.csv (cleaned in LibreOffice Calc)

-----

## Phase 1 — Environment Setup

### Step 1 — Prepared the CSV File

Before importing into MySQL, the cleaned Excel file was converted to CSV:

- Opened `bank_loan_analysis.xlsx` in LibreOffice Calc
- Saved as `bank_loan.csv` using **File → Save A Copy → Text CSV**
- Renamed file to remove double extension issue (`bank_loan.csv.csv` → `bank_loan.csv`)
- Copied file to MySQL’s secure upload directory:
  `C:\ProgramData\MySQL\MySQL Server 9.5\Uploads\`

**Why this folder?**
MySQL’s `secure_file_priv` setting restricts file imports to a specific directory.
This was confirmed by running:

```sql
SHOW VARIABLES LIKE 'secure_file_priv';
```

Result: `C:\ProgramData\MySQL\MySQL Server 9.5\Uploads\`

-----

### Step 2 — Created the Database

```sql
CREATE DATABASE bank_loan_db;
USE bank_loan_db;
```

-----

### Step 3 — Created the Table

All date columns were defined as TEXT to avoid import format conflicts.
Numeric columns were defined with appropriate decimal precision:

```sql
CREATE TABLE bank_loan (
    id INT,
    address_state VARCHAR(50),
    application_type VARCHAR(50),
    emp_length VARCHAR(50),
    emp_title VARCHAR(100),
    grade VARCHAR(5),
    home_ownership VARCHAR(50),
    issue_date TEXT,
    last_credit_pull_date TEXT,
    last_payment_date TEXT,
    loan_status VARCHAR(100),
    next_payment_date TEXT,
    member_id INT,
    purpose VARCHAR(50),
    sub_grade VARCHAR(10),
    term VARCHAR(20),
    verification_status VARCHAR(50),
    annual_income DECIMAL(15,2),
    dti DECIMAL(10,4),
    installment DECIMAL(10,2),
    int_rate DECIMAL(10,4),
    loan_amount INT,
    total_acc INT,
    total_payment DECIMAL(15,2),
    default_flag INT,
    loan_category VARCHAR(20),
    term_years INT
);
```

-----

### Step 4 — Imported the Data

The Table Data Import Wizard in MySQL Workbench was initially used but repeatedly timed out on 38,576 rows. The solution was to use `LOAD DATA INFILE` directly.

**Issues encountered and resolved:**

|Error          |Cause                          |Solution                          |
|---------------|-------------------------------|----------------------------------|
|Error 1290     |secure_file_priv restriction   |Moved file to MySQL Uploads folder|
|Error 29       |Uploads folder didn’t exist    |Created the folder manually       |
|Error 1366     |Special characters in emp_title|Added CHARACTER SET utf8mb4       |
|Count = 115,728|Import ran 3 times accidentally|Truncated table, reimported once  |

**Final working import command:**

```sql
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/bank_loan.csv'
IGNORE INTO TABLE bank_loan
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
```

**Import notes:**

- `CHARACTER SET utf8mb4` handled special characters in emp_title
- `IGNORE` skipped 1 row with an unsupported character encoding
- Warnings about `dti` truncation were acceptable (values rounded to 4 decimal places)
- Final import result: **38,576 records** (1 row excluded = 0.003% of dataset)

**Verified with:**

```sql
SELECT COUNT(*) FROM bank_loan;
```

Result: **38,576** ✅

-----

## Phase 2 — Data Exploration

Before writing analysis queries, the date format was verified:

```sql
SELECT issue_date FROM bank_loan LIMIT 10;
```

Result: Dates stored as `MM/DD/YY` format (e.g., `02/11/21`)

This confirmed the correct `STR_TO_DATE` pattern to use: `'%m/%d/%y'`

DTI value scale was also verified:

```sql
SELECT dti FROM bank_loan LIMIT 10;
```

Result: DTI stored as decimal proportions (e.g., `0.25` = 25% DTI)

-----

## Phase 3 — SQL Analysis Queries

All queries saved in: `bank_loan_queries.sql`

-----

### Query 1 — Overall Portfolio Performance

**Business Question:** What is the overall loan repayment and default rate across the entire portfolio?

```sql
-- QUERY 1: Overall Loan Portfolio Performance
SELECT
    COUNT(id) AS total_loans,
    SUM(loan_amount) AS total_amount_funded,
    SUM(total_payment) AS total_amount_received,
    COUNT(CASE WHEN loan_category = 'Good Loan' THEN id END) AS good_loans,
    COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) AS bad_loans,
    ROUND(COUNT(CASE WHEN loan_category = 'Good Loan' THEN id END) * 100.0 / COUNT(id), 2) AS good_loan_pct,
    ROUND(COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) * 100.0 / COUNT(id), 2) AS bad_loan_pct,
    ROUND(AVG(int_rate) * 100, 2) AS avg_interest_rate_pct,
    ROUND(AVG(dti), 2) AS avg_debt_to_income
FROM bank_loan;
```

**Results:**

|Metric          |Value |
|----------------|------|
|total_loans     |38,576|
|good_loan_pct   |83.33%|
|bad_loan_pct    |13.82%|
|current_loan_pct|~2.85%|

**Key Insight:**
13.82% of all loans defaulted (Charged Off). 83.33% were fully paid or current.
The remaining 2.85% are loans still actively being repaid.

-----

### Query 2 — Default Rate by Loan Grade

**Business Question:** Which loan grades carry the highest default risk?

```sql
-- QUERY 2: Default Rate by Loan Grade
SELECT
    grade,
    COUNT(id) AS total_loans,
    COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) AS bad_loans,
    ROUND(COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) * 100.0 / COUNT(id), 2) AS default_rate_pct,
    ROUND(AVG(int_rate) * 100, 2) AS avg_interest_rate_pct
FROM bank_loan
GROUP BY grade
ORDER BY default_rate_pct DESC;
```

**Results (Top 3 Highest Default Grades):**

|Grade|Default Rate|Risk Level|
|-----|------------|----------|
|G    |31.31%      |Extreme   |
|F    |30.25%      |Extreme   |
|E    |24.80%      |Very High |

**Key Insight:**
Grade G and F loans default at nearly 1 in 3 loans.
Grade E defaults at 1 in 4 loans.
These three grades represent the highest-risk segment of the portfolio
and warrant stricter lending criteria or higher interest rate compensation.

-----

### Query 3 — Default Rate by Loan Purpose

**Business Question:** Which loan purposes have the worst repayment rates?

```sql
-- QUERY 3: Default Rate by Loan Purpose
SELECT
    purpose,
    COUNT(id) AS total_loans,
    COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) AS bad_loans,
    ROUND(COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) * 100.0 / COUNT(id), 2) AS default_rate_pct,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM bank_loan
GROUP BY purpose
ORDER BY default_rate_pct DESC;
```

**Results (Top 3 Highest Default Purposes):**

|Purpose         |Default Rate|Insight                           |
|----------------|------------|----------------------------------|
|Small Business  |25.62%      |High business failure rate        |
|Renewable Energy|18.09%      |Emerging sector uncertainty       |
|Educational     |15.87%      |Income uncertainty post-graduation|

**Key Insight:**
Small business loans carry the highest default risk at 25.62%.
This aligns with real-world data showing high small business failure rates,
especially in early years of operation.

-----

### Query 4 — Monthly Loan Volume and Default Trends

**Business Question:** How has loan volume and default rate changed month over month?

**Note:** Initial query returned NULL values for one month due to incorrect date format pattern.
Diagnosed and fixed by checking raw date format:

```sql
SELECT issue_date FROM bank_loan LIMIT 20;
```

Confirmed format was `MM/DD/YY` — corrected STR_TO_DATE pattern to `'%m/%d/%y'`

```sql
-- QUERY 4: Monthly Loan Volume and Default Trends
SELECT
    DATE_FORMAT(STR_TO_DATE(issue_date, '%m/%d/%y'), '%Y-%m') AS month,
    COUNT(id) AS total_loans,
    SUM(loan_amount) AS total_amount_funded,
    COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) AS bad_loans,
    ROUND(COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) * 100.0 / COUNT(id), 2) AS default_rate_pct
FROM bank_loan
GROUP BY month
ORDER BY month ASC;
```

**Results:**

|Metric                |Value    |
|----------------------|---------|
|Total months of data  |12 months|
|NULL months           |0        |
|Last month total loans|4,314    |

**Key Insight:**
Full 12-month trend data available with no gaps.
Monthly loan volume provides a clear time-series for dashboard visualisation.

-----

### Query 5 — Default Rate by Debt-to-Income (DTI) Range

**Business Question:** Do borrowers with higher debt burdens default more?

**Note:** Initial query returned only one bucket (0-10% DTI) for all 38,576 loans.
Diagnosed by checking raw DTI values:

```sql
SELECT dti FROM bank_loan LIMIT 10;
```

Confirmed DTI stored as decimal proportions (0.25 = 25%), not whole numbers.
Updated CASE thresholds from 10/20/30 to 0.10/0.20/0.30.

DTI range verified with:

```sql
SELECT
    MAX(dti) AS max_dti,
    MIN(dti) AS min_dti,
    ROUND(AVG(dti), 4) AS avg_dti
FROM bank_loan;
```

|Metric |Value          |
|-------|---------------|
|max_dti|0.30 (30%)     |
|min_dti|0.00 (0%)      |
|avg_dti|0.1333 (13.33%)|

```sql
-- QUERY 5: Default Rate by DTI Range
SELECT
    CASE
        WHEN dti < 0.10 THEN '0-10% DTI'
        WHEN dti BETWEEN 0.10 AND 0.20 THEN '10-20% DTI'
        WHEN dti BETWEEN 0.20 AND 0.30 THEN '20-30% DTI'
        WHEN dti > 0.30 THEN '30%+ DTI'
    END AS dti_range,
    COUNT(id) AS total_loans,
    COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) AS bad_loans,
    ROUND(COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) * 100.0 / COUNT(id), 2) AS default_rate_pct,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM bank_loan
GROUP BY dti_range
ORDER BY default_rate_pct DESC;
```

**Results:**

|DTI Range |Default Rate|Risk Level|
|----------|------------|----------|
|20-30% DTI|15.56%      |Highest   |
|10-20% DTI|14.36%      |Medium    |
|0-10% DTI |11.96%      |Lowest    |

**Key Insight:**
Default rate increases consistently as DTI rises.
Every 10% increase in DTI corresponds to roughly a 2% increase in default rate.
This confirms DTI as a reliable predictor of default risk —
a foundational principle in credit risk analysis.

-----

## Phase 4 — Complete Findings Summary

|#|Business Question            |Key Finding                                              |
|-|-----------------------------|---------------------------------------------------------|
|1|Overall portfolio performance|13.82% default rate across 38,576 loans                  |
|2|Default rate by loan grade   |Grade G loans default at 31.31% — nearly 1 in 3          |
|3|Default rate by loan purpose |Small business loans highest at 25.62%                   |
|4|Monthly loan trends          |12 months of clean trend data, up to 4,314 loans/month   |
|5|Default rate by DTI range    |Default rate rises from 11.96% to 15.56% as DTI increases|

-----

## Data Quality Notes for README

> “38,576 of 38,577 records successfully imported into MySQL Workbench.
> One record excluded due to an unsupported special character in the emp_title field —
> representing 0.003% of the dataset with no material impact on analysis.
> Import warnings related to dti decimal truncation were reviewed and confirmed
> to have no impact on analytical results.
> Five SQL queries were written to answer key business questions around
> portfolio performance, credit risk, loan purpose, and borrower characteristics.”