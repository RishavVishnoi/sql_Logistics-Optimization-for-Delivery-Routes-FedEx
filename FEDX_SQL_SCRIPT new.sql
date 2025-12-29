CREATE DATABASE fedx;
USE fedx;

-- Orders table
CREATE TABLE Orders (
    Order_ID VARCHAR(10) PRIMARY KEY,
    Customer_ID VARCHAR(10),
    Order_Date DATETIME,
    Route_ID VARCHAR(10),
    Warehouse_ID VARCHAR(10),
    Order_Amount DECIMAL(10,2),
    Delivery_Type VARCHAR(20),
    Payment_Mode VARCHAR(20)
);

-- Routes table
CREATE TABLE Routes (
    Route_ID VARCHAR(10) PRIMARY KEY,
    Source_City VARCHAR(50),
    Source_Country VARCHAR(50),
    Destination_City VARCHAR(50),
    Destination_Country VARCHAR(50),
    Distance_KM INT,
    Avg_Transit_Time_Hours DECIMAL(8,2)
);

-- Warehouses table
CREATE TABLE Warehouses (
    Warehouse_ID VARCHAR(10) PRIMARY KEY,
    City VARCHAR(50),
    Country VARCHAR(50),
    Capacity_per_day INT,
    Manager_Name VARCHAR(50)
);

-- Delivery Agents table
CREATE TABLE DeliveryAgents (
    Agent_ID VARCHAR(10) PRIMARY KEY,
    Agent_Name VARCHAR(100),
    Zone VARCHAR(50),
    Zone_Country VARCHAR(50),
    Experience_Years FLOAT,
    Avg_Rating FLOAT
);

-- Shipments table
CREATE TABLE Shipments (
    Shipment_ID VARCHAR(10) PRIMARY KEY,
    Order_ID VARCHAR(10),
    Agent_ID VARCHAR(10),
    Route_ID VARCHAR(10),
    Warehouse_ID VARCHAR(10),
    Pickup_Date DATETIME,
    Delivery_Date DATETIME,
    Delivery_Status VARCHAR(20),
    Delay_Hours FLOAT,
    Delivery_Feedback VARCHAR(20),
    Delay_Reason VARCHAR(20)
);


-- Task 1.1 Identify and delete duplicate Order_ID or Shipment_ID records.
SELECT 
    Order_ID, COUNT(Order_ID) AS duplicate_orderID
FROM
    orders
GROUP BY Order_ID
HAVING duplicate_orderID > 1;

SELECT 
    Shipment_ID, COUNT(Shipment_ID) AS duplicate_shipmentID
FROM
    shipments
GROUP BY Shipment_ID
HAVING duplicate_shipmentID > 1;

-- Task 1.2 Replace null or missing Delay_Hours values in the Shipments Table with the average delay for that Route_ID.
SELECT 
    COUNT(delay_hours) AS missing_delayhrs
FROM
    shipments
WHERE
    delay_hours IS NULL;

-- Task 1.3 Convert all date columns (Order_Date, Pickup_Date, Delivery_Date) into YYYY-MM-DD HH:MM:SS format using SQL date functions. 

alter table orders
modify column Order_Date datetime;

alter table shipments
modify column Pickup_Date datetime,
modify column Delivery_Date datetime;

-- Task 1.4 Ensure that no Delivery_Date occurs before Pickup_Date (flag such records).
SELECT 
    *
FROM
    shipments
WHERE
    Pickup_Date > Delivery_Date;

-- Task 1.5 Validate referential integrity between Orders, Routes, Warehouses, and Shipments.

-- Shipments.Order_ID → Orders.Order_ID
ALTER TABLE Shipments
ADD CONSTRAINT fk_shipments_order
FOREIGN KEY (Order_ID)
REFERENCES Orders (Order_ID);

-- Shipments.Agent_ID → DeliveryAgents.Agent_ID
ALTER TABLE Shipments
ADD CONSTRAINT fk_shipments_agent
FOREIGN KEY (Agent_ID)
REFERENCES DeliveryAgents (Agent_ID);

-- Shipments.Route_ID → Routes.Route_ID
ALTER TABLE Shipments
ADD CONSTRAINT fk_shipments_route
FOREIGN KEY (Route_ID)
REFERENCES Routes (Route_ID);

-- Shipments.Warehouse_ID → Warehouses.Warehouse_ID
ALTER TABLE Shipments
ADD CONSTRAINT fk_shipments_warehouse
FOREIGN KEY (Warehouse_ID)
REFERENCES Warehouses (Warehouse_ID);

-- Orders.Route_ID → Routes.Route_ID
ALTER TABLE Orders
ADD CONSTRAINT fk_orders_route
FOREIGN KEY (Route_ID)
REFERENCES Routes (Route_ID);

-- Orders.Warehouse_ID → Warehouses.Warehouse_ID
ALTER TABLE Orders
ADD CONSTRAINT fk_orders_warehouse
FOREIGN KEY (Warehouse_ID)
REFERENCES Warehouses (Warehouse_ID);

-- Task 2.1 Calculate delivery delay (in hours) for each shipment using Delivery_Date - Pickup_Date.
SELECT 
    shipment_ID,
    pickup_date,
    delivery_date,
    TIMESTAMPDIFF(HOUR,
        pickup_date,
        delivery_date) AS delivery_delay_hrs
FROM
    shipments
WHERE
    NOT delay_reason = 'None';


-- Task 2.2 Find the Top 10 delayed routes based on average delay hours.

SELECT 
    r.Route_ID,
    r.Source_City,
    r.Source_Country,
    r.Destination_City,
    r.Destination_Country,
    AVG(s.Delay_Hours) AS Avg_Delay_Hours
FROM Shipments s
JOIN Routes r ON s.Route_ID = r.Route_ID
WHERE s.Delivery_Status = 'Delivered'
GROUP BY r.Route_ID, r.Source_City, r.Source_Country, r.Destination_City, r.Destination_Country
ORDER BY Avg_Delay_Hours DESC
LIMIT 10;

-- Task 2.3 Use SQL window functions to rank shipments by delay within each Warehouse_ID.
SELECT 
    s.Warehouse_ID,
    s.Shipment_ID,
    s.Pickup_Date,
    s.Delivery_Date,
    s.Delay_Hours,
    DENSE_RANK() OVER (
        PARTITION BY s.Warehouse_ID 
        ORDER BY s.Delay_hours DESC
    ) AS Delay_Rank_Within_Warehouse
FROM Shipments s
WHERE s.Delivery_Status = 'Delivered'
ORDER BY s.Warehouse_ID, Delay_Rank_Within_Warehouse;

-- Task 2.4 Identify the average delay per Delivery_Type (Express / Standard) to compare service-level efficiency.
SELECT 
    o.Delivery_Type,
    COUNT(s.Shipment_ID) AS Shipment_Count,
    AVG(s.Delay_Hours) AS Avg_Delay_Hours
FROM Shipments s
JOIN Orders o ON s.Order_ID = o.Order_ID
WHERE s.Delivery_Status = 'Delivered'
GROUP BY o.Delivery_Type
ORDER BY Avg_Delay_Hours DESC;

-- Task 3.1 For each route, Calculate Average transit time (in hours) across all shipments.
WITH shipment_calc AS (
    SELECT
        Route_ID,
        TIMESTAMPDIFF(
            HOUR,
            Pickup_Date,
            Delivery_Date
        ) AS Transit_Hours
    FROM Shipments
    WHERE Delivery_Status = 'Delivered'
)

SELECT
  Route_ID,
  AVG(Transit_Hours)
FROM shipment_calc
GROUP BY 1
ORDER BY 2 DESC;

-- Task 3.2 Calculate Average delay (in hours) per route.
SELECT 
    s.Route_ID, Source_City, Source_Country, Destination_City, Destination_Country,
    ROUND(AVG(Delay_Hours),2) AS avg_delay
FROM
    shipments s 
INNER JOIN routes r ON s.route_ID = r.route_ID
GROUP BY 1
ORDER BY 6 DESC;

-- Task 3.3 Calculate Distance-to-time efficiency ratio = Distance_KM / Avg_Transit_Time_Hours
SELECT 
    Route_ID,Source_City, Source_Country, Destination_City, Destination_Country,
    Distance_KM / Avg_Transit_Time_Hours AS Distance_to_time_efficiency_ratio
FROM
    routes
ORDER BY 6 DESC;

-- Task 3.4 Identify 3 routes with the worst efficiency ratio (lowest distance-to-time).
SELECT 
    Route_ID,Source_City, Source_Country, Destination_City, Destination_Country,
    Distance_KM / Avg_Transit_Time_Hours AS Distance_to_time_efficiency_ratio
FROM
    routes
ORDER BY 6
LIMIT 3;

-- Task 3.5 Find routes with >20% of shipments delayed beyond expected transit time.

SELECT 
    s.route_id,
    SUM(CASE
        WHEN delay_hours > 0 THEN 1
        ELSE 0
    END) AS delay_shipments,
    COUNT(delay_hours) AS total_shipments,
    (SUM(CASE
        WHEN delay_hours > 0 THEN 1
        ELSE 0
    END) / COUNT(delay_hours)) * 100 AS delay_rate
FROM
    shipments s
WHERE
    delivery_status = 'delivered'
GROUP BY 1
HAVING delay_rate > 20
ORDER BY delay_rate DESC;


-- Task 4.1 Find the top 3 warehouses with the highest average delay in shipments dispatched.
SELECT 
    warehouse_ID, AVG(Delay_Hours) AS avg_delay
FROM
    shipments
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- Task 4.2 Calculate total shipments vs delayed shipments for each warehouse.
SELECT 
    warehouse_id,
    COUNT(*) AS total_shipments,
    SUM(CASE
        WHEN delay_hours > 0 THEN 1
        ELSE 0
    END) AS delayed_shipments
FROM
    shipments
GROUP BY 1;

-- Task 4.3 Use CTEs to identify warehouses where average delay exceeds the global average delay.

WITH warehouse_stats AS (
    SELECT
        s.Warehouse_ID,
        AVG(s.Delay_Hours) AS Avg_Delay_Hours
    FROM Shipments s
    WHERE s.Delivery_Status = 'Delivered'   -- consider only completed shipments
    GROUP BY s.Warehouse_ID
),
global_delay AS (
    SELECT AVG(s.Delay_Hours) AS Global_Avg_Delay_Hours
    FROM Shipments s
    WHERE s.Delivery_Status = 'Delivered'
)
SELECT
    ws.Warehouse_ID,
    w.City,
    w.Country,
    ROUND(ws.Avg_Delay_Hours, 2) AS Warehouse_Avg_Delay_Hours,
    ROUND(gd.Global_Avg_Delay_Hours, 2) AS Global_Avg_Delay_Hours
FROM warehouse_stats ws
CROSS JOIN global_delay gd
JOIN Warehouses w
  ON ws.Warehouse_ID = w.Warehouse_ID
WHERE ws.Avg_Delay_Hours > gd.Global_Avg_Delay_Hours
ORDER BY ws.Avg_Delay_Hours DESC;

-- Task 4.4 Rank all warehouses based on on-time delivery percentage.
WITH cte as(
SELECT warehouse_id,(sum(case when delay_hours=0 then 1 else 0 end)/count(*))*100 as on_time_delivery_percentage
FROM shipments
GROUP BY 1)

SELECT *, DENSE_RANK() OVER ( order by on_time_delivery_percentage desc) as rk_warehouse
FROM cte;

-- Task 5.1 Rank delivery agents (per route) by on-time delivery percentage.
WITH agent_route_stats AS (
    SELECT
        s.Route_ID,
        s.Agent_ID,
        COUNT(*) AS Total_Shipments,
        SUM(CASE WHEN s.Delay_Hours = 0 THEN 1 ELSE 0 END) AS OnTime_Shipments,
        SUM(CASE WHEN s.Delay_Hours = 0 THEN 1 ELSE 0 END) * 1.0
            / COUNT(*) AS OnTime_Percent
    FROM Shipments s
    WHERE s.Delivery_Status = 'Delivered'
    GROUP BY s.Route_ID, s.Agent_ID
)
SELECT
    ars.Route_ID,
    ars.Agent_ID,
    da.Agent_Name,
    ars.Total_Shipments,
    ROUND(ars.OnTime_Percent * 100, 2) AS OnTime_Percent,
    DENSE_RANK() OVER (
        PARTITION BY ars.Route_ID
        ORDER BY ars.OnTime_Percent DESC, ars.Total_Shipments DESC
    ) AS Route_OnTime_Rank
FROM agent_route_stats ars
JOIN DeliveryAgents da
  ON ars.Agent_ID = da.Agent_ID
ORDER BY ars.Route_ID, Route_OnTime_Rank;

-- Task 5.2 Find agents whose on-time % is below 85%.
WITH agent_stats AS (
    SELECT
        s.Agent_ID,
        SUM(CASE WHEN s.Delay_Hours = 0 THEN 1 ELSE 0 END) * 1.0
            / COUNT(*) AS OnTime_Percent
    FROM Shipments s
    WHERE s.Delivery_Status = 'Delivered'
    GROUP BY s.Agent_ID
)
SELECT
    a.Agent_ID,
    da.Agent_Name,
    ROUND(a.OnTime_Percent * 100, 2) AS OnTime_Percent
FROM agent_stats a
JOIN DeliveryAgents da
  ON a.Agent_ID = da.Agent_ID
WHERE a.OnTime_Percent < 85
ORDER BY a.OnTime_Percent ASC;

-- Tak 5.3 Compare the average rating and experience (in years) of the top 5 vs bottom 5 agents using subqueries.

select avg(b5_rating), avg(b5_exp), avg(t5_rating), avg(t5_exp)
from (
SELECT agent_id, AVG(AVG_RATING) as b5_rating, AVG(experience_years) as b5_exp
from deliveryagents
group by 1
order by 2 asc
limit 5) as bot5, 
(SELECT agent_id, AVG(AVG_RATING) as t5_rating, AVG(experience_years) as t5_exp
from deliveryagents
group by 1
order by 2 desc
limit 5) as top5;
    

-- Task 6.1 For each shipment, display the latest status (Delivered, In Transit, or Returned) along with the latest Delivery_Date

WITH latest_scan AS (
    SELECT
        Shipment_ID,
        MAX(Delivery_Date) AS Latest_DeliveryDate
    FROM Shipments
    GROUP BY Shipment_ID
)
SELECT
    s.Shipment_ID,
    s.Route_ID,
    s.Delivery_Status,
    s.Delivery_Date AS Latest_DeliveryDate
FROM Shipments s
JOIN latest_scan ls
  ON s.Shipment_ID = ls.Shipment_ID
 AND s.Delivery_Date = ls.Latest_DeliveryDate;
 
-- Task 6.2 Identify routes where the majority of shipments are still “In Transit” or “Returned”.
    SELECT
        Route_ID,
        COUNT(*) AS Total_Shipments,
        SUM(CASE WHEN Delivery_Status IN ('In Transit','Returned')
                 THEN 1 ELSE 0 END) AS InTransit_or_Returned,
        SUM(CASE WHEN Delivery_Status IN ('In Transit','Returned')
                 THEN 1 ELSE 0 END) * 100
            / COUNT(*) AS InTransit_or_Returned
    FROM Shipments
    GROUP BY Route_ID
    ORDER BY InTransit_or_Returned DESC
    LIMIT 3;
 
 -- Task 6.3 Find the most frequent delay reasons (if available in delay-related columns or flags).
 
 SELECT
    Delay_Reason,
    COUNT(*) AS Reason_Count
FROM Shipments
WHERE NOT Delay_Reason ='None'
GROUP BY Delay_Reason
ORDER BY Reason_Count DESC;

-- Task 6.4 Identify orders with exceptionally high delay (>120 hours) to investigate potential bottlenecks.

SELECT
    Shipment_ID,
    Order_ID,
    Route_ID,
    Warehouse_ID,
    Delivery_Status,
    Delay_Hours,
    Delay_Reason
FROM Shipments
WHERE Delay_Hours > 120
ORDER BY Delay_Hours DESC;

-- Task 7.1 Calculate Average Delivery Delay per Source_Country.

SELECT
    r.Source_Country,
    ROUND(AVG(s.Delay_Hours),2) AS Avg_Delay_Hours
FROM Shipments s
JOIN Routes r
  ON s.Route_ID = r.Route_ID
GROUP BY
    r.Source_Country
ORDER BY
    Avg_Delay_Hours DESC;
    
-- Task 7.2 Calculate On-Time Delivery % = (Total On-Time Deliveries / Total Deliveries) * 100.

SELECT
    COUNT(*) AS Total_Deliveries,
    SUM(CASE WHEN s.Delay_Hours <= 0 THEN 1 ELSE 0 END) AS OnTime_Deliveries,
    ROUND(
        SUM(CASE WHEN s.Delay_Hours <= 0 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS OnTime_Percent
FROM Shipments s
WHERE s.Delivery_Status = 'Delivered';

-- Task 7.3 Calculate Average Delay (in hours) per Route_ID

SELECT
    Route_ID,
    ROUND(AVG(Delay_Hours),2) AS Avg_Delay_Hours
FROM Shipments
GROUP BY
    Route_ID
ORDER BY
    Avg_Delay_Hours DESC;
    
-- Task 7.4 Calculate Warehouse Utilization % = (Shipments_Handled / Capacity_per_day) * 100

SELECT
    w.Warehouse_ID,
    COUNT(s.Shipment_ID) AS Shipments_Handled,
    w.Capacity_per_day,
    ROUND(COUNT(s.Shipment_ID) * 100.0 / w.Capacity_per_day,2
    ) AS Warehouse_Utilization_Percent
FROM Warehouses w
LEFT JOIN Shipments s
  ON s.Warehouse_ID = w.Warehouse_ID
GROUP BY
    w.Warehouse_ID, w.Capacity_per_day
ORDER BY
    Warehouse_Utilization_Percent DESC;







 









