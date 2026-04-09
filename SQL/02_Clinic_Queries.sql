-- Q1: Revenue from each sales channel (2021)

SELECT 
    sales_channel,
    SUM(amount) AS total_revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

-- Q2: Top 10 most valuable customers (2021)


SELECT 
    uid,
    SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;


-- Q3: Month-wise revenue, expense, profit, status

WITH revenue AS (
    SELECT 
        MONTH(datetime) AS month,
        SUM(amount) AS total_revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY MONTH(datetime)
),

expense_data AS (
    SELECT 
        MONTH(datetime) AS month,
        SUM(amount) AS total_expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY MONTH(datetime)
)

SELECT 
    r.month,
    r.total_revenue,
    e.total_expense,
    (r.total_revenue - e.total_expense) AS profit,
    CASE 
        WHEN (r.total_revenue - e.total_expense) > 0 THEN 'Profitable'
        ELSE 'Not Profitable'
    END AS status
FROM revenue r
JOIN expense_data e 
    ON r.month = e.month;


-- Q4: Most profitable clinic per city (given month)

WITH clinic_profit AS (
    SELECT 
        c.city,
        c.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit,
        RANK() OVER (
            PARTITION BY c.city
            ORDER BY (SUM(cs.amount) - COALESCE(SUM(e.amount), 0)) DESC
        ) AS rnk
    FROM clinics c
    LEFT JOIN clinic_sales cs 
        ON c.cid = cs.cid
    LEFT JOIN expenses e 
        ON c.cid = e.cid
    WHERE MONTH(cs.datetime) = 9   
    GROUP BY c.city, c.cid
)

SELECT 
    city,
    cid,
    profit
FROM clinic_profit
WHERE rnk = 1;


-- Q5: 2nd least profitable clinic per state (given month)

WITH clinic_profit AS (
    SELECT 
        c.state,
        c.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit,
        DENSE_RANK() OVER (
            PARTITION BY c.state
            ORDER BY (SUM(cs.amount) - COALESCE(SUM(e.amount), 0)) ASC
        ) AS rnk
    FROM clinics c
    LEFT JOIN clinic_sales cs 
        ON c.cid = cs.cid
    LEFT JOIN expenses e 
        ON c.cid = e.cid
    WHERE MONTH(cs.datetime) = 9  
    GROUP BY c.state, c.cid
)

SELECT 
    state,
    cid,
    profit
FROM clinic_profit
WHERE rnk = 2;
