# Olist E-Commerce Business Intelligence Analysis

End-to-end SQL and Python analytics project on the Brazilian Olist e-commerce dataset. Demonstrates multi-table SQL querying, window functions, cohort analysis, and business-facing data storytelling — paired with an interactive Tableau dashboard.

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 99K+ orders across 8 relational tables (2016–2018).

> Raw CSVs are not committed. Download from Kaggle and place in `/data/`.

**Schema:**

```
orders ──< order_items >── products >── categories
  │                            │
  ├── order_payments        sellers
  ├── order_reviews
  └── customers
```

## Analyses

| # | Analysis | SQL Techniques |
|---|----------|----------------|
| 1 | Monthly Revenue Trends & MoM Growth | CTE, `LAG`, cumulative `SUM`, `DATE_TRUNC` |
| 2 | Customer Cohort Retention | Multi-step CTE, `DATEDIFF`, cohort self-join |
| 3 | Product Category Performance | 5-table JOIN, `RANK`, `NTILE`, conditional aggregation |
| 4 | Delivery Delay → Review Score Impact | `CASE WHEN` bucketing, `DATEDIFF`, conditional COUNT |
| 5 | Seller Performance Segmentation | `NTILE`, `RANK`, multi-metric window functions |

## Key Findings

- **7× GMV growth** from Jan 2017 to Aug 2018; Q4 2017 Black Friday spike visible in monthly trend
- **<10% Month-1 retention** — Olist customers are largely one-time buyers; loyalty program opportunity
- **Health & Beauty** is the top revenue category (R$1.24M) with strong satisfaction (4.19 ⭐)
- **Delivery timing is the #1 satisfaction driver**: late orders (7+ days) score 1.70 vs. 4.31 for early — only 11.8% satisfied vs. 83.4%
- **Only 3.8% of sellers** are "Star Sellers" (top quartile in both revenue and satisfaction)

## Business Recommendations

| Finding | Recommendation |
|---------|----------------|
| Revenue growth slowing mid-2018 | Expand seller base in underpenetrated categories |
| <10% customer retention | Loyalty program targeting repeat-purchase categories |
| Late delivery destroys NPS | Enforce stricter SLA; flag high-risk deliveries at checkout |
| Few Star Sellers | Coaching program surfacing best practices from top performers |

## Tableau Dashboard

> 📊 [View Interactive Dashboard on Tableau Public](https://public.tableau.com/app/profile/xiao.long/viz/OlistE-CommerceBusinessIntelligence/OlistE-CommerceBusinessIntelligence?publish=yes)

Covers: GMV trend, cohort retention heatmap, category treemap, delivery impact chart, seller segmentation.

## Setup

```bash
# Install dependencies
pip install duckdb pandas matplotlib seaborn jupyter

# Download Olist dataset from Kaggle → place CSVs in /data/

# Run analysis notebook
jupyter notebook notebooks/analysis.ipynb
```

## Project Structure

```
├── sql/                    # SQL scripts (DuckDB)
│   ├── 01_revenue_trends.sql
│   ├── 02_customer_cohorts.sql
│   ├── 03_category_performance.sql
│   ├── 04_delivery_impact.sql
│   └── 05_seller_performance.sql
├── notebooks/
│   └── analysis.ipynb      # Full analysis with visualizations
├── outputs/                # Exported CSVs for Tableau + chart PNGs
└── README.md
```
