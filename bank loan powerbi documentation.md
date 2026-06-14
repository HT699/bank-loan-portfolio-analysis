# Bank Loan Portfolio Analysis — Power BI Dashboard Documentation

**Tool Used:** Microsoft Power BI Desktop  
**Dashboard Pages:** 2 (Executive Summary + Risk Analysis)  
**Data Source:** bank_loan_powerbi.csv (exported from MySQL)  
**Total Records:** 38,576 loan records  
**Dashboard Title:** Bank Loan Portfolio Analysis by HT Olugbade

-----

## Phase 1 — Data Connection

### Step 1 — Attempted MySQL Direct Connection

Initially attempted to connect Power BI directly to MySQL database (bank_loan_db).
Power BI displayed the message:

> *“This connector requires one or more additional components to be installed.”*

This required the MySQL Connector/NET driver which was not installed.

### Step 2 — Exported Data from MySQL (Alternative Method)

Instead of installing the driver, data was exported directly from MySQL Workbench:

1. Ran this query in MySQL Workbench:

```sql
SELECT * FROM bank_loan;
```

1. Right-clicked the results grid
1. Clicked **Export Resultset**
1. Saved as **`bank_loan_powerbi.csv`** to Desktop

### Step 3 — Connected Power BI to CSV

1. Opened **Power BI Desktop**
1. Clicked **Home → Get Data → Text/CSV**
1. Selected **bank_loan_powerbi.csv**
1. Clicked **Load**

### Step 4 — Fixed Data Types

After loading, several numeric columns were imported as Text. Fixed in Data view:

1. Clicked **Data view** icon (left sidebar)
1. Selected each column and changed Data Type under **Column tools:**

|Column       |Incorrect Type|Corrected Type|
|-------------|--------------|--------------|
|dti          |Text          |Decimal Number|
|int_rate     |Text          |Decimal Number|
|annual_income|Text          |Decimal Number|
|total_payment|Text          |Decimal Number|
|loan_amount  |Text          |Whole Number  |

-----

## Phase 2 — Dashboard Setup

### Step 5 — Renamed Pages

At the bottom of Power BI:

1. Right-clicked **Page 1** → Renamed to `Executive Summary`
1. Clicked **+** to add new page → Renamed to `Risk Analysis`

### Step 6 — Applied Dark Theme

1. Clicked **View** tab
1. Clicked **Themes**
1. Selected the **Executive** theme (dark navy background)

This gave the dashboard a professional finance-appropriate appearance with:

- Dark navy background
- White text
- Clean minimal layout

-----

## Phase 3 — Page 1: Executive Summary

### Step 7 — Created 6 KPI Cards (Top Row)

Each card was created by:

1. Clicking blank canvas area
1. Selecting **Card** visual from Visualizations panel
1. Dragging the relevant field into **Fields** box
1. Changing aggregation type as needed
1. Renaming the field label by right-clicking → **Rename for this visual**

|Card                 |Field Used   |Aggregation   |Display|
|---------------------|-------------|--------------|-------|
|Total Loans          |id           |Count Distinct|38.576K|
|Avg Interest Rate    |int_rate     |Average       |12.05% |
|Total Amount Funded  |loan_amount  |Sum           |436M   |
|Average DTI          |dti          |Average       |13.33% |
|Total Defaults       |default_flag |Sum           |5K     |
|Total Amount Received|total_payment|Sum           |473M   |

**Issue Encountered:** Avg Interest Rate showed 0.12 instead of 12%
**Fix Applied:**

1. Clicked the int_rate card
1. Went to **Modeling tab → Format → Percentage**
1. Repeated for dti column

All 6 cards were arranged in a **single row across the top** of the canvas.

-----

### Step 8 — Created Donut Chart: Loan Portfolio Breakdown

**Purpose:** Show the split between Good Loans, Bad Loans and Current loans

1. Clicked blank canvas area
1. Selected **Donut Chart** visual
1. Dragged **loan_category** into **Legend**
1. Dragged **id** into **Values** → changed to **Count**
1. Formatted title: `Loan Portfolio Breakdown`
1. Positioned: **Middle left** of canvas

**Result:**

- Good Loan: 22bn (82.07%)
- Bad Loan: 4bn (14.12%)
- Current: 1bn (3.81%)

-----

### Step 9 — Created Bar Chart: Loan Volume by Purpose

**Purpose:** Show which loan purposes are most common in the portfolio

1. Clicked blank canvas area
1. Selected **Clustered Bar Chart** visual
1. Dragged **purpose** into **Y-axis**
1. Dragged **id** into **X-axis** → changed to **Count**
1. Formatted title: `Loan Volume By Purpose`
1. Positioned: **Middle right** of canvas

**Key Finding Visible:**
Debt Consolidation was by far the most common loan purpose at ~15K loans.

-----

### Step 10 — Created Line Chart: Monthly Loan Volume Trend

**Purpose:** Show how loan volume changed month over month across 12 months

**Issue 1 Encountered:** Line chart X-axis showed “Day (0-30)” instead of months.
**Cause:** issue_date was stored as TEXT, not a proper date format.

**Fix Applied — Created Month_Year Calculated Column:**

1. Went to **Data view**
1. Clicked **New Column**
1. Typed this DAX formula:

```
Month_Year = 
VAR Slash1 = FIND("/", 'bank_loan_powerbi'[issue_date])
VAR Slash2 = FIND("/", 'bank_loan_powerbi'[issue_date], Slash1 + 1)
VAR MonthNum = VALUE(LEFT('bank_loan_powerbi'[issue_date], Slash1 - 1))
VAR YearNum = VALUE("20" & RIGHT('bank_loan_powerbi'[issue_date], 2))
RETURN FORMAT(DATE(YearNum, MonthNum, 1), "YYYY-MM")
```

**Issue 2 Encountered:** First formula attempt failed with error:

> *“Cannot convert value ‘6/’ of type Text to type number”*

**Cause:** Some dates had single-digit months (e.g., `6/11/21`) instead of `06/11/21`.
**Fix:** Used FIND() to locate the “/” separator dynamically instead of fixed character positions.

**Result:** Month_Year column created with values like `2021-01`, `2021-06`, `2021-12`

**Building the Line Chart:**

1. Clicked blank canvas area
1. Selected **Line Chart** visual
1. Dragged **Month_Year** into **X-axis** (not issue_date)
1. Dragged **loan_amount** into **Y-axis** → changed to **Sum**
1. Sorted by Month_Year ascending
1. Formatted title: `Monthly Loan Volume Trend`
1. Positioned: **Bottom of canvas, full width**

**Result:** Clean upward trend line showing loan volume from 2021-01 through 2021-12

-----

## Phase 4 — Page 2: Risk Analysis

Clicked the **Risk Analysis** tab at the bottom of Power BI.

-----

### Step 11 — Created Grade Slicer

**Purpose:** Allow viewers to filter all charts by loan grade simultaneously

1. Clicked blank canvas area
1. Selected **Slicer** visual
1. Dragged **grade** into **Field**
1. Positioned: **Top left** of canvas

**Result:** Interactive filter showing checkboxes for grades A, B, C, D, E, F, G

-----

### Step 12 — Created Bar Chart: Default Rate by Loan Purpose

**Purpose:** Show which loan purposes carry the highest default risk

1. Clicked blank canvas area
1. Selected **Clustered Bar Chart** visual
1. Dragged **purpose** into **Y-axis**
1. Dragged **loan_category** into **Legend**
1. Dragged **id** into **X-axis** → changed to **Count**
1. Formatted title: `Default Rate By Loan Purpose`
1. Positioned: **Left** of canvas

**Key Finding Visible:**
Small business loans showed the highest proportion of Bad Loans (25.62% default rate).

-----

### Step 13 — Created Bar Chart: Default Risk by Loan Grade

**Purpose:** Show which loan grades carry the highest default risk

1. Clicked blank canvas area
1. Selected **Clustered Bar Chart** visual
1. Dragged **grade** into **Y-axis**
1. Dragged **loan_category** into **Legend**
1. Dragged **id** into **X-axis** → changed to **Count**
1. Formatted title: `Default Risk By Loan Grade`
1. Positioned: **Middle** of canvas

**Key Finding Visible:**
Grade G and F loans showed the highest proportion of Bad Loans (31.31% and 30.25%).

-----

### Step 14 — Created Bar Chart: Loan Risk by DTI

**Purpose:** Show how default risk varies across debt-to-income ratio ranges

**Issue Encountered:** Initial chart using raw dti column showed hundreds of individual decimal values (0.00, 0.01, 0.02…) making the chart unreadable.

**Fix Applied — Created DTI Range Calculated Column:**

1. Went to **Data view**
1. Clicked **New Column**
1. Typed this DAX formula:

```
dti_range = 
SWITCH(
    TRUE(),
    'bank_loan_powerbi'[dti] < 0.10, "0-10% DTI",
    'bank_loan_powerbi'[dti] < 0.20, "10-20% DTI",
    'bank_loan_powerbi'[dti] <= 0.30, "20-30% DTI",
    "30%+ DTI"
)
```

1. Pressed **Enter**
1. New column created with 3 clean categories

**Building the Chart:**

1. Clicked blank canvas area
1. Selected **Clustered Bar Chart** visual
1. Dragged **dti_range** into **Y-axis** (not raw dti)
1. Dragged **loan_category** into **Legend**
1. Dragged **id** into **X-axis** → changed to **Count**
1. Formatted title: `Loan Risk By DTI`
1. Positioned: **Right** of canvas

**Result:** 3 clean bars showing:

- 20-30% DTI: Highest bad loan proportion
- 10-20% DTI: Medium bad loan proportion
- 0-10% DTI: Lowest bad loan proportion

-----

### Step 15 — Added Dashboard Title

On both pages:

1. Clicked **Insert → Text Box**
1. Typed: `BANK LOAN PORTFOLIO ANALYSIS BY HT OLUGBADE`
1. Increased font size and centered at top of canvas

-----

### Step 16 — Tested Interactivity

1. Clicked **Grade G** in the slicer
1. All 3 charts filtered simultaneously to show only Grade G loans
1. Confirmed cross-filtering was working correctly
1. Clicked Grade G again to deselect and restore full view

-----

## Phase 5 — Final Save and Export

### Step 17 — Saved the Power BI File

1. Pressed **Ctrl + S**
1. Named file: `Bank_loan_powe_bi`
1. Saved to Documents folder

### Step 18 — Exported Screenshots

1. Pressed **Windows Key + Shift + S** on each page
1. Pasted into Paint and saved as:
- `page1_executive_summary.png`
- `page2_risk_analysis.png`

-----

## Complete Dashboard Summary

### Page 1 — Executive Summary

|Visual                   |Type       |Key Metric            |
|-------------------------|-----------|----------------------|
|Total Loans              |KPI Card   |38,576                |
|Avg Interest Rate        |KPI Card   |12.05%                |
|Total Amount Funded      |KPI Card   |436M                  |
|Average DTI              |KPI Card   |13.33%                |
|Total Defaults           |KPI Card   |5K                    |
|Total Amount Received    |KPI Card   |473M                  |
|Loan Portfolio Breakdown |Donut Chart|82.07% Good Loans     |
|Loan Volume By Purpose   |Bar Chart  |Debt Consolidation #1 |
|Monthly Loan Volume Trend|Line Chart |12 months upward trend|

### Page 2 — Risk Analysis

|Visual                      |Type     |Key Finding                     |
|----------------------------|---------|--------------------------------|
|Grade Filter                |Slicer   |A through G interactive         |
|Default Rate By Loan Purpose|Bar Chart|Small Business highest at 25.62%|
|Default Risk By Loan Grade  |Bar Chart|Grade G highest at 31.31%       |
|Loan Risk By DTI            |Bar Chart|Default rises with DTI          |

-----

## Calculated Columns Created in Power BI

|Column Name|Formula Type              |Purpose                                      |
|-----------|--------------------------|---------------------------------------------|
|Month_Year |DAX (FIND + DATE + FORMAT)|Convert text dates to YYYY-MM for trend chart|
|dti_range  |DAX (SWITCH)              |Group decimal DTI into readable ranges       |

-----

## Key Dashboard Insights

1. **83.33%** of loans are Good Loans — portfolio is largely healthy
1. **13.82%** overall default rate — significant risk requiring management attention
1. **Grade G loans** default at **31.31%** — nearly 1 in 3 loans fail
1. **Small Business** loans carry the highest default risk at **25.62%**
1. Default rate rises consistently from **11.96%** to **15.56%** as DTI increases
1. **Debt Consolidation** is the most common loan purpose by volume
1. Loan volume showed a **consistent upward trend** throughout 2021

-----

## Data Quality Notes for README

> “Power BI dashboard built from 38,576 cleaned loan records exported from MySQL.
> Two calculated columns were engineered using DAX to handle text-format dates
> and create meaningful DTI range groupings. The two-page interactive dashboard
> features 6 KPI cards, a donut chart, two bar charts, a line chart, and an
> interactive grade slicer enabling dynamic cross-filtering across all visuals.”