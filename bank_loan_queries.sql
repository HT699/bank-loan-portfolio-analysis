-- 	QUERY 1 = OVERALL PORTFOLIO PERFORMANCE

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
    
    
-- QUERY 2 = DEFAULT RATE BY LOAN GRADE

SELECT 
	grade,
    COUNT(id) AS total_loans,
    COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) AS bad_loans,
    ROUND(COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) * 100.0 / COUNT(id), 2) AS default_rate_pct,
    ROUND(AVG(int_rate) * 100, 2) AS avg_interest_rate_pct
FROM bank_loan
GROUP BY grade
ORDER BY default_rate_pct DESC;


-- QUERY 3 = DEFAULT RATE BY LOAN PURPOSE

SELECT 
	purpose,
    COUNT(id) AS total_loans,
    COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) AS bad_loans,
    ROUND(COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) * 100.0 / COUNT(id), 2) AS default_rate_pct,
    ROUND(AVG(loan_amount), 2) AS avg_loan_amount
FROM bank_loan
GROUP BY purpose
ORDER BY default_rate_pct DESC;


-- QUERY 4 = MONTHLY LOAN TRENDS

SELECT 
	DATE_FORMAT(STR_TO_DATE(issue_date, '%m/%d/%y'), '%y-%m') AS month,
    COUNT(id) AS total_loans,
    SUM(loan_amount) AS total_amount_funded,
    COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) AS bad_loans,
    ROUND(COUNT(CASE WHEN loan_category = 'Bad Loan' THEN id END) * 100.0 / COUNT(id), 2) AS default_rate_pct
FROM bank_loan
GROUP BY month
ORDER BY month ASC;


-- QUERY 5 = DEFAULT RATE BY DEBT TO INCOME RATIO

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