-- Event Analytics
-- accessing tables in the database 
-- customers, events, cakes, vendor orders

select * from customers
select * from events
select * from cakes
select * from vendor_orders


-- seasonability
-- What's the total budget/spend by season?
SELECT season, SUM(budget_actual) AS total_budget from events group by season order by total_budget;
-- summer season had total budget of 16892575 than other seasons

-- Which season has the most events, and which has the highest total budget?
SELECT season, COUNT(*) AS event_count, SUM(budget_actual) AS total_budget, AVG(budget_actual) AS avg_budget
FROM events GROUP BY season ORDER BY total_budget DESC;   -- so summer season has most events and high budget


-- statisfaction
-- 	How many events had a satisfaction score of 3 or higher?
SELECT COUNT(*) AS events_satisfied FROM events WHERE satisfaction_score >= 3;
-- 1157 events had satisfaction score more than 3 

-- 	How many weekend events had satisfaction ? 3, vs weekday events?
SELECT is_weekend, COUNT(*) AS satisfied_events
FROM events WHERE satisfaction_score >= 3
GROUP BY is_weekend;
-- 825 events when its weekend, 332 when its weekday

-- Weekend vs weekday: guest count, budget, satisfaction
SELECT is_weekend,
       AVG(guest_count) AS avg_guests,
       AVG(budget_actual) AS avg_budget,
       AVG(CAST(satisfaction_score AS FLOAT)) AS avg_satisfaction
FROM events
GROUP BY is_weekend;
-- avg guests on a weekend - 79 with avgsatisfaction of 4.0

-- Product(cake) + theme
-- Which cake flavor is ordered most often?
select count(*) as order_count, flavor from cakes group by flavor order by order_count desc;
-- most orderd was butterscotch and chocolate is 2nd most ordered

-- Which cake size is most common for each theme, and how much does it cost?
SELECT theme, size_kg, COUNT(*) AS freq, AVG(ck.cost) AS avg_cost
FROM cakes ck JOIN events ev ON ck.event_id = ev.event_id
GROUP BY theme, size_kg ORDER BY theme, freq DESC;
-- beach themed party cake was most ordered with size around 1.5, freq approx 9, avg cost 2500 - 3000

-- Which theme orders the largest cakes, and avg cost?
SELECT e.theme, AVG(ck.size_kg) AS avg_cake_size, AVG(ck.cost) AS avg_cake_cost
FROM cakes ck
JOIN events e ON ck.event_id = e.event_id
GROUP BY e.theme
ORDER BY avg_cake_size DESC;
-- most ordered theme of the cakes are vintage


-- Vendor, vendor reliability
-- Which vendor is used most frequently across all events?
select vendor_name, COUNT(*) AS times_booked FROM vendor_orders GROUP BY vendor_name ORDER BY times_booked DESC;
-- balloon vendor, cake vendor mostly booked

-- What's the maximum cost recorded for each vendor category?
SELECT vendor_category, MAX(cost) AS max_cost FROM vendor_orders GROUP BY vendor_category ORDER BY max_cost DESC;
-- catering is the highest category which has max cost with decoration being seconds, photography being 3rd

-- Which vendor category has the highest peak cost?"
SELECT vendor_category, MAX(cost) AS max_cost, AVG(cost) AS avg_cost
FROM vendor_orders
GROUP BY vendor_category
ORDER BY max_cost DESC;
-- catering  has highest peak cost with max cost - 29k+ , avg cost of 15k+

-- Which vendor category consumes the largest share of budget?
SELECT vendor_category, SUM(cost) AS total_spend,
       ROUND(SUM(cost) * 100.0 / SUM(SUM(cost)) OVER(), 1) AS pct_of_total
FROM vendor_orders
GROUP BY vendor_category
ORDER BY total_spend DESC; -- catering with total spend of 13790511 and pct of total - 39.7

-- which vendor category is both most expensive AND most delay-prone?
-- (the avaerage cost of delayed vendor category and late percentage)
SELECT vendor_category,
       AVG(cost) AS avg_cost,
       ROUND(SUM(CASE WHEN status='Late' THEN 1.0 ELSE 0 END)/COUNT(*)*100,1) AS late_pct
FROM vendor_orders
GROUP BY vendor_category
ORDER BY late_pct DESC;
-- tho decoration has 27% of being delayed , catering has highest avg cost of vendor category

-- How many vendor orders were delayed, and which category adds the most extra cost from delays?
SELECT vendor_category,
       SUM(CASE WHEN status='Late' THEN 1 ELSE 0 END) AS delayed_orders,
       COUNT(*) AS total_orders,
       AVG(delay_minutes) AS avg_delay_minutes
FROM vendor_orders GROUP BY vendor_category ORDER BY delayed_orders DESC;
-- decoration cetegory is mostly delayed with orders 248 but still having the total orders of 904 more than the catering category, avg delayminute - 7

-- Within each vendor category, which vendor is the most expensive on average?
SELECT vendor_category, vendor_name, 
       AVG(cost) AS avg_cost,
       RANK() OVER (PARTITION BY vendor_category ORDER BY AVG(cost) DESC) AS cost_rank
FROM vendor_orders
GROUP BY vendor_category, vendor_name;
-- balloon category has is the most expensive on an avg with avg cost 3k+ and rank 1




--Customer + product (customer retention)
-- Which cake flavor is most common among repeat customers?
SELECT ck.flavor, COUNT(*) AS order_count
FROM cakes ck
JOIN events ev ON ck.event_id = ev.event_id
JOIN customers c ON ev.customer_id = c.customer_id
WHERE c.repeat_customer = 1
GROUP BY ck.flavor ORDER BY order_count DESC;
-- butterscotch most ordered one with ordercount of 63 times, seconds is vanilla, blackforest the next.


-- How many customers had more than one event (repeated customers)?
SELECT customer_id, COUNT(event_id) AS total_events
FROM events
GROUP BY customer_id
HAVING COUNT(event_id) > 1
ORDER BY total_events DESC;

-- the list of repeated customers along with their cities/type of segment
SELECT c.customer_id, c.customer_name, c.segment, ev.total_events
FROM customers c
JOIN (
    SELECT customer_id, COUNT(event_id) AS total_events
    FROM events
    GROUP BY customer_id
    HAVING COUNT(event_id) > 1
) ev ON c.customer_id = ev.customer_id
ORDER BY ev.total_events DESC;
-- cutomerid 24, was a regular customer booking for family events to a count of 10


-- within customers, which segment was the most spended (total spend)
SELECT 
    c.customer_id,
    c.segment,
    SUM(e.budget_actual) AS total_spend,
    RANK() OVER (PARTITION BY c.segment ORDER BY SUM(e.budget_actual) DESC) AS spend_rank_in_segment
FROM events e
JOIN customers c ON e.customer_id = c.customer_id
GROUP BY c.customer_id, c.segment;


-- Budget behavior
-- Do events planned with less lead time end up costing more?
SELECT 
  CASE WHEN planning_days < 10 THEN 'Under 10 days'
       WHEN planning_days < 25 THEN '10-25 days'
       ELSE '25+ days' END AS planning_window,
  AVG(budget_actual) AS avg_budget,
  AVG(budget_overrun_pct) AS avg_overrun_pct
FROM events
GROUP BY CASE WHEN planning_days < 10 THEN 'Under 10 days'
              WHEN planning_days < 25 THEN '10-25 days'
              ELSE '25+ days' END;
-- 10-25 days planning has budget over 53k+ with avg overrunpct of 5.05

-- 	Do events with fewer planning days tend to have higher budgets? (same query with different conds)
SELECT 
  CASE WHEN planning_days < 14 THEN 'Short (<14 days)' 
       WHEN planning_days < 30 THEN 'Medium (14-30)' 
       ELSE 'Long (30+)' END AS planning_bucket,
  AVG(budget_actual) AS avg_budget, COUNT(*) AS event_count
FROM events GROUP BY 
  CASE WHEN planning_days < 14 THEN 'Short (<14 days)' 
       WHEN planning_days < 30 THEN 'Medium (14-30)' 
       ELSE 'Long (30+)' END;
-- medium planning bucket had more events than others with avg budget over 50k+

-- Most "profitable" themes (using budget_actual as proxy for spend, satisfaction as value)
SELECT theme,
       COUNT(*) AS event_count,
       AVG(budget_actual) AS avg_spend,
       AVG(CAST(satisfaction_score AS FLOAT)) AS avg_satisfaction
FROM events
GROUP BY theme
ORDER BY avg_satisfaction DESC, avg_spend DESC; -- minimalist has avg satisfication score of 4.2


-- What's the average budget needed for events with 20/40/60 guests
SELECT
  CASE
    WHEN guest_count <= 25 THEN '0-25'
    WHEN guest_count <= 50 THEN '26-50'
    WHEN guest_count <= 75 THEN '51-75'
    ELSE '75+'
  END AS guest_bucket,
  AVG(budget_actual) AS avg_budget
FROM events
GROUP BY
  CASE
    WHEN guest_count <= 25 THEN '0-25'
    WHEN guest_count <= 50 THEN '26-50'
    WHEN guest_count <= 75 THEN '51-75'
    ELSE '75+'
  END
ORDER BY MIN(guest_count);
-- guest count with 75+ have avg budget of 58k+ while 25 to 40 count had avgbudget of 45k+ 


-- What is the cumulative (running) total of event budget spend month over month? and did it change from previous month?
WITH monthly_budget AS (
    SELECT 
        FORMAT(event_date, 'yyyy-MM') AS event_month,
        SUM(budget_actual) AS total_budget
    FROM events
    GROUP BY FORMAT(event_date, 'yyyy-MM')
)
SELECT 
    event_month,
    total_budget,
    LAG(total_budget) OVER (ORDER BY event_month) AS prev_month_budget,
    total_budget - LAG(total_budget) OVER (ORDER BY event_month) AS change_vs_prev_month
FROM monthly_budget
ORDER BY event_month;
-- the running total changed from 2nd month of 2024 and the change is observed in changevsprevmonth column in the result query

-- insight 1 budget overrun rule
-- Do outdoor events with more than 120 guests overrun their planned budget more than other events?
-- The "outdoor + >120 guests -> budget overrun" insight -- it does seem to happen that way cause outdoor events 
-- with 120 guests have event count of 50+ and avg overrunpct of 19%
-- while home or indoor events with guests <120 have avgoverunpct - 4.0 with event count 240+
SELECT venue_type,
       CASE WHEN guest_count > 120 THEN 'Over 120 guests' ELSE '120 or fewer' END AS guest_bucket,
       AVG(budget_overrun_pct) AS avg_overrun_pct,
       COUNT(*) AS event_count
FROM events
GROUP BY venue_type, CASE WHEN guest_count > 120 THEN 'Over 120 guests' ELSE '120 or fewer' END
ORDER BY avg_overrun_pct DESC;


-- insight 2 vendor reliability
-- Which vendor category has the highest delay rate, and how does that compare to its average cost?
SELECT vendor_category,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN status = 'Late' THEN 1 ELSE 0 END) AS late_orders,
       ROUND(SUM(CASE WHEN status='Late' THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 1) AS late_pct,
       AVG(delay_minutes) AS avg_delay_minutes,
       AVG(cost) AS avg_cost
FROM vendor_orders
GROUP BY vendor_category
ORDER BY late_pct DESC;
-- as appeared in previous queries , this makes it clear that decoration category has the highest delay rate 
-- with late orders 200+ and avg cost 7k+
-- and late percentage 27% , total orders 850+