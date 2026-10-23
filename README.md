# Sales Performance Analysis (2024–2025)

An end-to-end data analytics project: raw sales data → cleaning → analysis → interactive Excel dashboard → business recommendations.

> **Note:** the dataset is synthetic (generated for practice). The numbers do not describe a real company.

**Tools:** Excel (Power Query, PivotTables, PivotCharts, Slicers), Python (pandas) for validation, SQL queries for analysis.

---

## 1. Business problem

A retail company sells Electronics, Furniture, Footwear, Accessories and Stationery across 4 regions (East, North, South, West) through 3 channels (Online, Retail Store, Distributor).
**Objective:** understand what drives sales and profit, and recommend actions to grow profit.

**Questions answered**
1. What are total sales, profit, orders and average order value?
2. How do sales and profit trend over time?
3. Which categories and products matter most, and which have low margin?
4. Which regions and cities perform best?
5. Which channels and payment methods are used most?
6. Does discounting hurt profit?
7. Who are the top customers and sales reps?
8. How long does shipping take?

## 2. Data

| File | Rows | Description |
|---|---|---|
| `sales_raw.csv` | 2,045 | Raw transactions (19 columns) |
| `customers.csv` | 300 | Customer master |
| `products.csv` | 12 | Product master (price, margin %) |
| `sales_clean.csv` | 2,000 | Cleaned data used in the dashboard |

## 3. Data quality log

| # | Issue | Column(s) | Rows (approx.) | Fix |
|---|---|---|---|---|
| 1 | Duplicate orders | order_id | 45 | Removed duplicates (2,045 → 2,000 rows) |
| 2 | Mixed date formats (4 types) | order_date, ship_date | all | Converted to one date format (Power Query) |
| 3 | Inconsistent text (`SOUTH`, `south`, `Sou`, trailing spaces) | region, category, customer_name | ~300 | TRIM, PROPER, replace abbreviations |
| 4 | Spelling variants | payment_method, channel | ~55 | Standardized to 5 payment methods and 3 channels |
| 5 | Numbers stored as text (`Rs.7000`, `10%`) | unit_price, discount_pct | ~75 | Removed symbols, converted to numbers |
| 6 | Negative quantity | quantity | ~27 | Absolute value |
| 7 | Missing quantity | quantity | ~50 | Calculated from sales ÷ (price × (1 − discount)) |
| 8 | Missing city | city | ~90 | Looked up from customer master |
| 9 | Missing sales rep | sales_rep | ~60 | Set to `Unassigned` |
| 10 | Outliers in sales (25–40× too large) | sales | ~15 | Recalculated as quantity × price × (1 − discount) |
| 11 | Missing profit | profit | ~70 | Sales × product margin %, filled **after** fixing sales |
| 12 | Missing ship date | ship_date | ~52 | Left blank (not every order has shipped) |

Final validation: 2,000 unique orders, 4 regions, 5 categories, 3 channels, 5 payment methods; total sales ₹4.60 Cr, total profit ₹81.68 L.

**Lesson learned:** the order of cleaning matters. Profit must be filled after outlier sales are fixed, otherwise one inflated sales value created an impossible 880% margin on a single order.

## 4. Dashboard

Interactive Excel dashboard with 5 KPI boxes, 5 charts and 3 slicers (year, category, region).

![Dashboard](dashboard.png)

## 5. Key findings

| KPI | Value |
|---|---|
| Total sales | ₹4.60 Cr |
| Total profit | ₹81.68 L |
| Orders | 2,000 |
| Average order value | ₹23,024 |
| Profit margin | 17.7% |

1. **Electronics drives the business but has the lowest margin.** It is 75% of sales (₹3.47 Cr) at a 16% margin. Laptops alone bring ₹2.2 Cr and Smartphones ₹86 L.
2. **Small categories have much higher margins.** Stationery (38%), Accessories (32%), Footwear (29%) and Furniture (20%) earn more per rupee but together are only 25% of sales.
3. **Sales fell about 21% in 2025** (₹2.57 Cr → ₹2.04 Cr) while the number of orders stayed almost the same (1,010 vs 990). Orders became smaller, so the drop comes from lower order value, not fewer customers. Sales were weakest in Q1–Q2 2025 and recovered in the second half (Q4 2025 up about 14% from Q2).
4. **Regions are balanced.** East (₹1.26 Cr) and West (₹1.22 Cr) lead, North is the smallest (₹0.98 Cr). Margins are 17–18% everywhere.
5. **Two cities stand out.** Patna (₹53 L) and Surat (₹51 L) are well ahead; Vijayawada and Ahmedabad are the lowest.
6. **Discounting did not visibly change margin.** The overall margin stays about 17–18% at every discount level (0–20%), and 0%-discount orders bring the most sales.
7. **Channels are evenly split:** Distributor 35%, Retail Store 34%, Online 31%.
8. **Sales reps:** Suresh Reddy (₹89 L) and Ravi Kumar (₹86 L) lead. About ₹11.6 L of sales have no rep assigned.
9. **Customers:** the top 10 customers account for about 14% of sales, so there is little dependence on a single customer.
10. **Delivery:** average 4.5 days from order to shipping (range 1–8 days).

## 6. Recommendations

1. **Protect Electronics, but improve its margin.** Review supplier cost and avoid discounting laptops and smartphones, since they carry the lowest margin.
2. **Grow high-margin categories.** Bundle Accessories and Footwear with Electronics orders to raise margin per order.
3. **Investigate the 2025 drop in order value.** Fewer large Electronics orders is the likely cause; check pricing, stock and promotions in H1 2025.
4. **Learn from Patna and Surat.** Replicate what works there (channels, reps, offers) in the weakest cities.
5. **Assign every order to a sales rep** so performance can be tracked (₹11.6 L is unassigned).
6. **Run a discount test.** Discounts did not raise margin; test whether lower discounts keep volume and improve profit.

## 7. Method summary

1. Profiled the raw data and logged every issue.
2. Cleaned with Excel (TRIM, PROPER, Find & Replace, Power Query, lookups) and validated results against a pandas script.
3. Built 10 PivotTables for analysis.
4. Created the dashboard with PivotCharts and slicers connected to every pivot.
5. Wrote insights and recommendations.

## 8. Files

```
sales_raw.csv, customers.csv, products.csv   raw data
clean_sales.py                              cleaning and validation script
sales_clean.csv / sales_clean.xlsx          cleaned data and dashboard workbook
dashboard.png                               dashboard screenshot
README.md                                   this file
```

## 9. Resume line

> Cleaned and analyzed 2,000+ sales transactions (2 years, 4 regions, 5 categories) by fixing duplicates, mixed date formats, missing values and outliers with Excel and Python; built an interactive Excel dashboard with KPIs, trends and slicers; found a 21% year-over-year sales decline driven by lower order value and recommended margin and discount actions.
