# 📦 Logistics Optimization for Delivery Routes – FedEx (SQL Analytics Project)

## 📌 Project Overview
FedEx operates one of the world’s largest logistics and courier networks, connecting **220+ countries** through major global hubs such as **Memphis, Dubai, Singapore, Paris, and London**.  
With the rapid growth of **global e-commerce**, especially during peak seasons, FedEx faces increasing challenges related to:

- Flight delays and weather disruptions  
- Customs clearance bottlenecks  
- Last-mile congestion  
- Rising operational costs and reduced on-time delivery performance  

This project builds a **SQL-driven logistics analytics system** to analyze shipment performance, identify delay patterns, optimize routes, and improve overall delivery efficiency across FedEx’s global network.

---

## 🎯 Project Objectives
The key objectives of this project are to:

- Identify **root causes of delivery delays**
- Optimize **international and regional delivery routes**
- Analyze **warehouse and delivery agent performance**
- Improve **on-time delivery reliability**
- Provide **actionable, data-driven recommendations** to reduce costs and delays

---

## 🗂️ Dataset Description
The project uses a relational database consisting of the following tables:

### 1️⃣ Orders
| Column | Description |
|------|------------|
| Order_ID | Unique order identifier |
| Customer_ID | Customer identifier |
| Order_Date | Date & time of order |
| Route_ID | Route used |
| Warehouse_ID | Dispatch warehouse |
| Order_Amount | Order value |
| Delivery_Type | Express / Standard |
| Payment_Mode | Payment method |

### 2️⃣ Routes
| Column | Description |
|------|------------|
| Route_ID | Route identifier |
| Source_City | Origin city |
| Source_Country | Origin country |
| Destination_City | Destination city |
| Destination_Country | Destination country |
| Distance_KM | Distance in kilometers |
| Avg_Transit_Time_Hours | Expected transit time |

### 3️⃣ Warehouses
| Column | Description |
|------|------------|
| Warehouse_ID | Warehouse identifier |
| City | Warehouse city |
| Country | Warehouse country |
| Capacity_per_day | Daily handling capacity |
| Manager_Name | Warehouse manager |

### 4️⃣ Delivery Agents
| Column | Description |
|------|------------|
| Agent_ID | Agent identifier |
| Agent_Name | Agent name |
| Zone | Assigned zone |
| Zone_Country | Country |
| Experience_Years | Experience |
| Avg_Rating | Customer rating |

### 5️⃣ Shipment Tracking
| Column | Description |
|------|------------|
| Shipment_ID | Shipment identifier |
| Order_ID | Related order |
| Agent_ID | Delivery agent |
| Route_ID | Route used |
| Warehouse_ID | Dispatch warehouse |
| Pickup_Date | Pickup timestamp |
| Delivery_Date | Delivery timestamp |
| Delivery_Status | Delivered / In Transit / Returned |
| Delay_Hours | Delay duration |
| Delivery_Feedback | Customer feedback |

---

![ER Diagram](assets/ERdiagram.jpg)

## 🧠 Tasks Performed

### ✅ Task 1: Data Cleaning & Preparation
- Removed duplicate `Order_ID` and `Shipment_ID` records
- Replaced missing `Delay_Hours` with **route-level average delay**
- Standardized date formats (`YYYY-MM-DD HH:MM:SS`)
- Flagged invalid records where `Delivery_Date < Pickup_Date`
- Validated **referential integrity** across all tables

---

### ⏱️ Task 2: Delivery Delay Analysis
- Calculated shipment-level delivery delays
- Identified **Top 10 most delayed routes**
- Ranked shipments by delay within each warehouse (window functions)
- Compared average delay between **Express vs Standard deliveries**

---

### 🚚 Task 3: Route Optimization Insights
For each route:
- Calculated **average transit time**
- Calculated **average delay**
- Computed **distance-to-time efficiency ratio**
- Identified **worst-performing routes**
- Detected routes where **>20% shipments exceed expected transit time**

---

### 🏭 Task 4: Warehouse Performance
- Identified **top 3 warehouses with highest average delay**
- Compared total vs delayed shipments per warehouse
- Used **CTEs** to flag warehouses exceeding global average delay
- Ranked warehouses by **on-time delivery percentage**

---

### 👤 Task 5: Delivery Agent Performance
- Ranked agents per route by on-time delivery %
- Identified agents below **85% on-time performance**
- Compared **experience and ratings** of top 5 vs bottom 5 agents
- Proposed **training and workload optimization strategies**

---

### 📊 Task 6: Shipment Tracking Analytics
- Displayed latest shipment status and delivery date
- Identified routes with majority **In Transit / Returned** shipments
- Detected **frequent delay reasons**
- Flagged shipments with **>120 hours delay** for investigation

---

### 📈 Task 7: Advanced KPI Reporting
Calculated KPIs using SQL aggregations and CASE statements:
- Average delivery delay per **source country**
- **On-Time Delivery %**
- Average delay per route
- Warehouse utilization %

---

## 🔍 Key Findings

### 🚦 Route Performance Issues
**Worst Efficiency Ratio (Distance ÷ Time):**
- Singapore → China (R003)
- Netherlands → Turkey (R015)

**Highest Average Delay Routes:**
- UAE → China (R002)
- China → Australia (R007)
- Turkey → Singapore (R020)
- Singapore → China (R003)
- China → Japan (R008)

---

### 🧑‍💼 Delivery Agent Insights
- Low-performing agents have:
  - Lower ratings: **4.43 vs 4.52**
  - Less experience: **2.78 vs 3.63 years**

**Recommended Actions:**
- Mentor pairing with experienced agents
- Skill-focused training workshops
- Gradual workload complexity increase
- Workload caps to prevent burnout
- Quarterly performance tracking

---

### 🏭 Warehouse & Operations Insights
- Warehouses in **UK, China, and Netherlands** exceed global average delay
- Overall **on-time delivery rate is extremely low (7.15%)**
- Most frequent delay reason: **Traffic**
- Warehouse utilization is under-optimized  
  - Highest utilization observed: **10.3%**

---

### 🚀 Service-Level Insights
- Express deliveries show **higher average delay (23 hrs)** than Standard (19 hrs)

---

## 🛠️ Tools & Technologies
- SQL (MySQL / PostgreSQL compatible)
- Relational Databases
- Window Functions, CTEs, Subqueries
- Data Cleaning & KPI Reporting

---

## 📌 Business Impact
This project demonstrates how **SQL-driven analytics** can:
- Improve route and hub optimization
- Enhance delivery reliability
- Reduce operational inefficiencies
- Support data-driven logistics decision-making

---

## 📄 Author
**Rishav Vishnoi**  
MBA | Business Analytics & Operations  
SQL • Logistics Analytics • Supply Chain Optimization
