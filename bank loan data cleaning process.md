# Bank Loan Portfolio Analysis — Full Data Cleaning Process

**Tool Used:** LibreOffice Calc  
**Dataset:** financial_loan.csv (sourced from GitHub)  
**Total Rows:** 38,577 loan records  
**Total Columns:** 24 original + 3 calculated = 27 final columns

-----

## Step 1 — Open and Save the File

1. Opened `financial_loan.csv` in LibreOffice Calc
1. Went to **File → Save As**
1. Changed the file type to **Excel Workbook (.xlsx)**
1. Named the file `bank_loan_analysis.xlsx`
1. When prompted, clicked **“Keep Current Format”** to save as .xlsx
1. All future saves used **Ctrl + S → Keep Current Format**

-----

## Step 2 — Freeze the Header Row

1. Clicked on **Cell A2** (first row of data below the header)
1. Went to **View → Freeze Rows and Columns**
1. A thick horizontal line appeared below Row 1 confirming the freeze
1. Column headers remained visible while scrolling through all 38,577 rows

-----

## Step 3 — Verify Row Count

1. Pressed **Ctrl + End** to jump to the last cell with data
1. Confirmed the dataset contained **38,577 rows** of loan records
1. Noted the last column was **Column X (total_payment)**

-----

## Step 4 — Check for Duplicate Rows

1. Clicked anywhere inside the data
1. Went to **Data → Remove Duplicates**
1. Clicked **Select All** to include all columns
1. Clicked **OK**
1. Result: **No duplicate rows found** — dataset confirmed clean

-----

## Step 5 — Check for Missing Values (COUNTBLANK)

Identified all column letters by reviewing Row 1 headers:

|Column|Header               |
|------|---------------------|
|A     |id                   |
|B     |address_state        |
|C     |application_type     |
|D     |emp_length           |
|E     |emp_title            |
|F     |grade                |
|G     |home_ownership       |
|H     |issue_date           |
|I     |last_credit_pull_date|
|J     |last_payment_date    |
|K     |loan_status          |
|L     |next_payment_date    |
|M     |member_id            |
|N     |purpose              |
|O     |sub_grade            |
|P     |term                 |
|Q     |verification_status  |
|R     |annual_income        |
|S     |dti                  |
|T     |installment          |
|U     |int_rate             |
|V     |loan_amount          |
|W     |total_acc            |
|X     |total_payment        |

Used **COUNTBLANK** formula with specific row ranges (not full columns) to avoid counting empty rows below the data. Typed labels in column Z and formulas in column AA:

```
=COUNTBLANK(K2:K38577)   → loan_status
=COUNTBLANK(F2:F38577)   → grade
=COUNTBLANK(R2:R38577)   → annual_income
=COUNTBLANK(S2:S38577)   → dti
=COUNTBLANK(U2:U38577)   → int_rate
=COUNTBLANK(V2:V38577)   → loan_amount
=COUNTBLANK(N2:N38577)   → purpose
=COUNTBLANK(D2:D38577)   → emp_length
=COUNTBLANK(E2:E38577)   → emp_title
```

**Results:**

|Column       |Blank Count|
|-------------|-----------|
|loan_status  |0 ✅        |
|grade        |0 ✅        |
|annual_income|0 ✅        |
|dti          |0 ✅        |
|int_rate     |0 ✅        |
|loan_amount  |0 ✅        |
|purpose      |0 ✅        |
|emp_length   |0 ✅        |
|emp_title    |**1,432 ⚠️**|

Deleted the COUNTBLANK working columns after recording results.

-----

## Step 6 — Handle Missing Values in emp_title

emp_title (Column E) had **1,432 blank cells.** Since job title is not a critical analytical column, blanks were filled with “Unknown”:

1. Clicked the **Column E header** to select the entire column
1. Pressed **Ctrl + H** to open Find & Replace
1. Clicked **“Other Options”** to expand settings
1. Checked **“Regular Expressions”**
1. In **Search For** typed: `^$`
1. In **Replace With** typed: `Unknown`
1. Checked **“Current Selection Only”**
1. Clicked **Replace All**
1. Result: **1,432 cells** replaced with “Unknown”
1. Re-ran COUNTBLANK on emp_title to confirm result = **0** ✅

-----

## Step 7 — Fix Date Columns

Four columns contained dates stored as text in DD-MM-YYYY format:

- **H** — issue_date
- **I** — last_credit_pull_date
- **J** — last_payment_date
- **L** — next_payment_date

For each column, ran **Text to Columns** with DMY format:

1. Clicked the column header to select the entire column
1. Went to **Data → Text to Columns**
1. Selected **“Separated by”** → clicked **Next**
1. Unchecked all separators → clicked **Next**
1. Changed Column Type to **Date** and set format to **DMY** (Day-Month-Year)
1. Clicked **Finish**
1. Confirmed dates were now **right-aligned** (properly recognized as dates)

**Why DMY?** The dataset stored dates as DD-MM-YYYY (e.g., 17-07-2021). Using DMY correctly reads 17 as the day and 07 as the month. Using MDY would fail for any day number above 12.

Repeated this process for all four date columns — H, I, J and L.

-----

## Step 8 — Create Calculated Column 1: default_flag (Column Y)

**Purpose:** Flags each loan as defaulted (1) or not (0) for quantitative analysis.

1. Clicked **Y1** → typed `default_flag` → pressed **Enter**
1. Clicked **Y2** → typed:

```
=IF(K2="Charged Off",1,0)
```

1. Pressed **Enter**
1. Copied the formula down to **Y38577** using the Name Box (typed `Y3:Y38577` → Enter → Ctrl+V)

**Result:** Column Y populated with 1s (defaulted loans) and 0s (non-defaulted loans) ✅

-----

## Step 9 — Create Calculated Column 2: loan_category (Column Z)

**Purpose:** Categorizes each loan as Good Loan, Bad Loan, or Current for portfolio segmentation.

1. Clicked **Z1** → typed `loan_category` → pressed **Enter**
1. Clicked **Z2** → typed:

```
=IF(LEFT(TRIM(K2),5)="Fully","Good Loan",IF(TRIM(K2)="Charged Off","Bad Loan","Current"))
```

1. Pressed **Enter**
1. Copied the formula down to **Z38577**

**Note:** Used `LEFT(TRIM(K2),5)` instead of exact match on “Fully Paid” because the dataset contained a non-breaking space character (confirmed via `=CODE(MID(K5,6,1))` returning 160) between “Fully” and “Paid” that prevented exact string matching.

**Result:** Column Z populated with Good Loan, Bad Loan, and Current values ✅

-----

## Step 10 — Create Calculated Column 3: term_years (Column AA)

**Purpose:** Converts loan term from text format to numeric years for easier analysis.

1. Clicked **AA1** → typed `term_years` → pressed **Enter**
1. Clicked **AA2** → typed:

```
=IF(TRIM(P2)="36 months",3,5)
```

1. Pressed **Enter**
1. Copied the formula down to **AA38577**

**Note:** Used `TRIM()` to handle leading spaces in the term column values.

**Result:** Column AA populated with 3s (36-month loans) and 5s (60-month loans) ✅

-----

## Final Dataset Summary

|Property                |Detail                                 |
|------------------------|---------------------------------------|
|File name               |bank_loan_analysis.xlsx                |
|Total rows              |38,577                                 |
|Total columns           |27 (24 original + 3 calculated)        |
|Duplicate rows          |0                                      |
|Missing values remaining|0                                      |
|Date columns formatted  |4 (H, I, J, L)                         |
|New columns added       |default_flag, loan_category, term_years|

-----

## Data Quality Notes for README

> “Performed comprehensive data quality checks across all 24 columns. No duplicate records were found across 38,577 loan entries. Missing values were identified only in the emp_title column (1,432 records, 3.7% of dataset) and handled by substituting ‘Unknown’ as the job title was not a critical analytical variable. All four date columns were converted from text (DD-MM-YYYY) to proper date format. Three calculated columns were engineered to support default risk analysis and portfolio segmentation.”