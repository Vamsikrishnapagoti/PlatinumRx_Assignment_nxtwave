-- Q1: Last booked room for each user
SELECT 
    user_id,
    room_no
FROM (
    SELECT 
        user_id,
        room_no,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY booking_date DESC
        ) AS rn
    FROM bookings
) t
WHERE rn = 1;

-- Q2: Total billing amount for bookings in Nov 2021

SELECT 
    bc.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_bill
FROM booking_commercials bc
JOIN items i 
    ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 11
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.booking_id;

-- Q3: Bills in Oct 2021 with amount > 1000

SELECT 
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i 
    ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 10
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.bill_id
HAVING bill_amount > 1000;

-- Q4: Most and least ordered item per month in 2021

WITH item_sales AS (
    SELECT 
        MONTH(bc.bill_date) AS month,
        i.item_name,
        SUM(bc.item_quantity) AS total_qty,

        RANK() OVER (
            PARTITION BY MONTH(bc.bill_date)
            ORDER BY SUM(bc.item_quantity) DESC
        ) AS max_rank,

        RANK() OVER (
            PARTITION BY MONTH(bc.bill_date)
            ORDER BY SUM(bc.item_quantity) ASC
        ) AS min_rank

    FROM booking_commercials bc
    JOIN items i 
        ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY MONTH(bc.bill_date), i.item_name
)

SELECT 
    month,
    item_name,
    total_qty,
    CASE 
        WHEN max_rank = 1 THEN 'Most Ordered'
        WHEN min_rank = 1 THEN 'Least Ordered'
    END AS category
FROM item_sales
WHERE max_rank = 1 OR min_rank = 1;

-- Q5: Customers with 2nd highest bill each month in 2021

WITH monthly_bills AS (
    SELECT 
        u.user_id,
        MONTH(bc.bill_date) AS month,
        bc.bill_id,
        SUM(bc.item_quantity * i.item_rate) AS total_bill,

        DENSE_RANK() OVER (
            PARTITION BY MONTH(bc.bill_date)
            ORDER BY SUM(bc.item_quantity * i.item_rate) DESC
        ) AS rnk

    FROM booking_commercials bc
    JOIN items i 
        ON bc.item_id = i.item_id
    JOIN bookings b 
        ON bc.booking_id = b.booking_id
    JOIN users u 
        ON b.user_id = u.user_id

    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY 
        u.user_id,
        MONTH(bc.bill_date),
        bc.bill_id
)

SELECT 
    user_id,
    month,
    bill_id,
    total_bill
FROM monthly_bills
WHERE rnk = 2;
