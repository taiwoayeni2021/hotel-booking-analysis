--Create table
CREATE TABLE hotel(
	booking_id				INTEGER,
	hotel_type				TEXT,
	lead_time_days			INTEGER,
	arrival_date			DATE,
	stay_nights				INTEGER,
	adults					INTEGER,
	children				INTEGER,
	meal_plan				TEXT,
	market_segment			TEXT,
	repeated_guest			INTEGER,
	previous_cancelation	INTEGER,
	booking_status			TEXT,
	ADR						DECIMAL(10,2),
	day_name				TEXT,
	day_number				INTEGER,
	month_name				TEXT,
	month_number			INTEGER,
	total_revenue			DECIMAL(10,2)
);

-----1. OVERALL PERFORMANCE
--What is the Overall Booking Volume?
SELECT COUNT(*) AS total_bookings
FROM hotel;

--What is the Overall Total Revenue?
SELECT SUM(total_revenue) AS total_revenue
FROM hotel
WHERE booking_status = 'Check-Out';

--What is the Overall Average ADR
SELECT ROUND(AVG(adr),2) AS avg_adr
FROM hotel
WHERE booking_status = 'Check-Out';

-----2. SEASONALITY & DEMAND TRENDS
--Which month generates the highest bookings & revenue?
SELECT month_name, COUNT(*) AS total_bookings, SUM(total_revenue) AS monthly_revenue
FROM hotel
WHERE booking_status = 'Check-Out'
GROUP BY month_name, month_number
ORDER BY month_number;
--Note: October is number two in booking but number five in revenue. This reveals
--that the number of bookings is not the sole determinant of revenue. 

--Which days of the week have the highest check_ins?
SELECT day_name, COUNT(*) AS total_bookings
FROM hotel
WHERE booking_status = 'Check-Out'
GROUP BY day_name
ORDER BY total_bookings DESC;
--Note: The 'WHERE' clause there is to exclude bookings that did not end in check-in.

-----3. REVENUE OPTIMIZATION
--Which market segment generates the highest revenue?
SELECT market_segment, SUM(total_revenue) AS revenue
FROM hotel
WHERE booking_status = 'Check-Out'
GROUP BY market_segment
ORDER BY revenue DESC;

--Which hotel type performed better in terms of revenue and ADR?
SELECT hotel_type, SUM(total_revenue) AS revenue, ROUND(AVG(adr),2) AS avg_adr
FROM hotel
WHERE booking_status = 'Check-Out'
GROUP BY hotel_type
ORDER BY revenue DESC;

--Which meal plan contribute the most to total revenue?
SELECT meal_plan, SUM(total_revenue) AS revenue
FROM hotel
WHERE booking_status = 'Check-Out'
GROUP BY meal_plan
ORDER BY revenue DESC;

--Revenue vs Booking Volume
SELECT 
    market_segment,
    COUNT(*) AS bookings,
    SUM(total_revenue) AS revenue,
    ROUND(SUM(total_revenue) / COUNT(*),2) AS revenue_per_booking
FROM hotel
WHERE booking_status = 'Check-Out'
GROUP BY market_segment
ORDER BY revenue DESC;

--Combined Driver Analysis
SELECT 
    hotel_type,
    market_segment,
    SUM(total_revenue) AS revenue
FROM hotel
WHERE booking_status = 'Check-Out'
GROUP BY hotel_type, market_segment
ORDER BY revenue DESC;

-----4. CANCELLATION ANALYSIS
--What is the overall cancellation rate?
SELECT
	ROUND(COUNT(CASE
	WHEN booking_status IN ('Canceled', 'No-Show')THEN 1 END) *100.0/COUNT(*),2)
	AS cancellation_rate
	FROM hotel;

--What is the overall Successful Booking rate?
SELECT
	ROUND(
		COUNT(CASE WHEN booking_status = 'Check-Out' THEN 1 END) * 100.0/
	COUNT(*),2) AS success_rate
	FROM hotel;

--Which market segment has the highest cancellation rate?
SELECT market_segment, COUNT(*) AS total_bookings,
COUNT(CASE
	WHEN booking_status IN ('Canceled', 'No-Show') THEN 1 END) AS cancellations,
	ROUND(
	COUNT (CASE
		WHEN booking_status IN ('Canceled', 'No-Show') THEN 1 END) *100.0/
		COUNT(*),2) AS cancellation_rate
FROM hotel
GROUP BY market_segment
ORDER BY cancellation_rate DESC;
--Insight: Online travel agents had the highest cancellation rate of 34.81%,
--suggesting the need for stricter cancellation policies for this segment.

--Does lead time influence cancellation behaviour?
SELECT
	CASE
		WHEN lead_time_days <= 7 THEN '0 -7 days'
		WHEN lead_time_days <= 30 THEN '8 -30 days'
		WHEN lead_time_days <= 60 THEN '31 -60 days'
		WHEN lead_time_days <= 90 THEN '61 -90 days'
		WHEN lead_time_days <= 120 THEN '91 -120 days'
		WHEN lead_time_days <= 150 THEN '121 -150 days'
		ELSE '150 + days'
	END AS lead_time_group,
	CASE
		WHEN lead_time_days <= 7 THEN 1
		WHEN lead_time_days <= 30 THEN 2
		WHEN lead_time_days <= 60 THEN 3
		WHEN lead_time_days <= 90 THEN 4
		WHEN lead_time_days <= 120 THEN 5
		WHEN lead_time_days <= 150 THEN 6
		ELSE 7
	END AS sort_order,
	COUNT(*) AS total_bookings
	FROM hotel
	GROUP BY lead_time_group, sort_order
	ORDER BY sort_order;

-----5. CUSTOMER BEHAVIOUR
--Do repeat guests generate more revenue and have lower cancellation rates?
--A. Do repeat guests generate more revenue?
SELECT
	repeated_guest, SUM(total_revenue) AS total_revenue,
	ROUND(AVG(total_revenue),2) AS avg_revenue
FROM hotel
WHERE booking_status = 'Check-Out'
GROUP BY repeated_guest;
--Note: New guests contributed higher average revenue.

--B. Do repeat guests have lower cancellation rates?
SELECT
	repeated_guest,
	ROUND(COUNT(CASE
	WHEN booking_status IN ('Canceled', 'No-Show')THEN 1 END)*100.0/COUNT(*),2)
	AS cancellation_rate
FROM hotel
GROUP BY repeated_guest;
--Note: New guests showed a lower cancellation rate suggesting higher reliability.

--What type of customer(families vs individuals) contribute more to the revenue?
SELECT
	CASE
	WHEN children > 0 THEN 'family' ELSE 'individual' END AS customer_type,
	SUM(total_revenue) AS total_revenue,  ROUND(AVG(total_revenue),2) AS avg_revenue
FROM hotel
WHERE booking_status = 'Check-Out'
GROUP BY customer_type;
--Note: While families contributed higher total revenue, individual travelers generated
--higher revenue per booking.

