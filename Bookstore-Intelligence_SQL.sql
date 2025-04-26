-- ==================
-- Revenue Analysis
-- ==================

-- Top 10 books that generated the highest revenue after discounts

select distinct Book_name, sum(product_disc_price*qty_sold) as Revenue_per_book
from books_data
group by Book_name
order by Revenue_per_book desc
limit 10;

-- Which author generates the highest Revenue

select author, sum(product_disc_price*qty_sold) as Revenue_per_Author
from books_data
group by author
order by Revenue_per_Author desc limit 10;


-- Performance by Category
-- Which types (genres) or languages are most profitable?

select type, language, sum(product_disc_price*qty_sold) as Revenue_after_discount,
SUM(qty_sold) AS total_copies_sold
from books_data
group by type, language
order by Revenue_after_discount desc
limit 10;

-- Find the total revenue lost due to discounts (difference between real price and discounted price).

select sum(product_real_price-product_disc_price) as Total_revenue_lost
from books_data;

-- ==================================
-- Author Performance
-- ==================================

-- Which authors consistently perform well across multiple books 
-- (Books_written >=3, average rating ≥ 4.5 and > 1000 copies sold)?

select author, count(distinct book_name) as Books_written,
round(avg(product_rating),2) as Avg_rating,
sum(qty_sold) as Total_copies_sold
from books_data
group by author
having Books_written >=3 and Avg_rating>=4.5 and Total_copies_sold>1000
ORDER BY Avg_rating DESC;

-- Which authors have books that are consistently rated high and should be featured in must pick?

SELECT 
    author,
    COUNT(*) AS books_count,
    ROUND(AVG(product_rating), 2) AS avg_rating,
    SUM(qty_sold) AS total_copies_sold
FROM books_data
GROUP BY author
HAVING books_count >= 3 AND avg_rating >= 4.5 
ORDER BY avg_rating DESC;


-- Which authors show consistent high performance — rank authors by average rating?

WITH author_stats AS (
    SELECT 
        author,
        COUNT(*) AS total_books,
        ROUND(AVG(product_rating), 2) AS avg_rating
    FROM books_data
    GROUP BY author
)
SELECT *,
       DENSE_RANK() OVER (ORDER BY avg_rating DESC) AS performance_rank
FROM author_stats
WHERE total_books >= 10
ORDER BY performance_rank;

-- ==========================
-- Product Analysis
-- ==========================

-- Which books have high revenue but low rating — and should be reconsidered for restocking or promotion?

select distinct Book_name, product_disc_price*qty_sold as Revenue, product_rating
from books_data
where product_rating<=4
order by Revenue desc;

-- What are the top 5 most underrated books — high ratings but low number of copies sold (< 100)?

select Distinct Book_name, product_rating, qty_sold, on_promotion
from books_data
where product_rating>=4.5 and qty_sold<100
order by product_rating desc, qty_sold asc;

-- What are the hidden gem books — highly rated, mid-priced, low exposure?

SELECT 
    Book_name, author, round(avg(product_disc_price),0) as Avg_Price, 
    round(Avg(qty_sold),0) as Avg_Copies_Sold,
    avg(product_rating) as Avg_rating
FROM books_data
Group by Book_name, author
having Avg_rating >= 4.5 
    AND Avg_Price BETWEEN 300 AND 600 
    AND Avg_Copies_Sold BETWEEN 20 AND 100
ORDER BY Avg_rating DESC
LIMIT 10;

-- =========================
-- Pricing Analysis
-- =========================

-- Which price segments yield the best ratings and sales?

SELECT 
    CASE 
        WHEN product_disc_price < 200 THEN 'Below 200'
        WHEN product_disc_price BETWEEN 200 AND 400 THEN '200-400'
        WHEN product_disc_price BETWEEN 401 AND 600 THEN '401-600'
        ELSE '600+'
    END AS price_segment,
    COUNT(*) AS num_books,
    ROUND(AVG(product_rating), 2) AS avg_rating,
    SUM(qty_sold) AS total_copies_sold,
    ROUND(SUM(product_disc_price * qty_sold)) AS total_revenue
FROM books_data
GROUP BY price_segment
ORDER BY total_revenue DESC;

-- ============================================
-- Promotional Strategy — Does Discounting Pay Off?
-- Do promoted books outperform non-promoted ones?
-- ============================================

select on_promotion, 
round(avg(product_disc_price*qty_sold),2) as Avg_Revenue, 
round(avg(qty_sold),2) as Avg_Copies_Sold
from books_data
group by on_promotion;

-- ============================================
--  Discount Sensitivity — What’s the Sweet Spot?
-- Which discount levels lead to optimal sales?
-- ============================================

SELECT 
    case 
		when discount_offered_prcnt <20 then 'Discount Below 20%'
        when discount_offered_prcnt between 20 and 30 then 'Discount between 20%-30%'
        when discount_offered_prcnt between 31 and 40 then 'Discount between 31%-40%'
        when discount_offered_prcnt between 41 and 50 then 'Discount between 41%-50%'
        else 'Above 50%'
	end as Discount_Categories ,
    avg(product_disc_price*qty_sold) as Avg_Revenue,
    avg(qty_sold) as Avg_Copies_Sold
    from books_data
    group by Discount_Categories
    order by Avg_Revenue desc;

-- 🧾 Are we over-discounting top-performing books?
-- Find top 10 books by revenue, then compare their discount percent and ratings.

select distinct Book_name, on_promotion, discount_offered_prcnt, product_rating,
product_disc_price*qty_sold as Revenue
from books_data
where on_promotion='Yes' and discount_offered_prcnt>=20
order by Revenue desc
limit 10;

-- the books with high ratings + high revenue + high discounts indicate that they're undervalued
-- Book store should consider lowering discounts to increase profit margins

-- =========================================
-- Negative Cash Flow - Stock Risk Warning 
-- — High Discount, Low Sales
-- Which books have high discounts but failed to sell?
-- ==========================================

SELECT 
    Book_name,
    discount_offered_prcnt,
    qty_sold
FROM books_data
WHERE discount_offered_prcnt >= 40 AND qty_sold < 50
ORDER BY qty_sold;



