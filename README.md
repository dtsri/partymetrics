# 🎈 Birthday & Event Planning Analytics

An end-to-end analytics project simulating a birthday/event-planning business — built to answer real operational and budgeting questions using SQL, Python, and Power BI.

**Author:** Sri Harsha Emandi
**Tools:** MS SQL Server (SSMS) · Python (Pandas, NumPy, Faker) · Power BI (DAX, Power Query)

---

## 📌 Problem Statement

Event-planning businesses juggle vendors, budgets, guest counts, and timelines across dozens of events a year. This project analyzes a synthetic but realistically-modeled events dataset to answer: **which vendors are reliable, which events overrun budget, and what patterns can the business act on?**

## 🗂️ Dataset

A 4-table relational dataset (synthetic, generated with Python — see `generate_data.py`), designed with intentional real-world business rules rather than pure randomness:

| Table | Description |
|---|---|
| `events` | One row per event — date, season, city, theme, venue type, guest count, budget (planned/actual), satisfaction score, cancellation flag |
| `customers` | Customer segment, city, repeat-customer status |
| `vendor_orders` | One row per vendor booking per event — category, cost, delay minutes, delivery status |
| `cakes` | Cake flavor, size, customization level, cost per event |

**Business rules engineered into the data** (later validated through analysis, not just assumed):
- Outdoor events with 120+ guests carry a higher budget-overrun rate
- Decoration vendors have a higher delay rate than other categories
- Outdoor + rainy/stormy weather increases cancellation likelihood

> **Note:** This is a synthetic dataset built to practice realistic business analytics. The value of the project is in the schema design, the business-rule logic, the SQL/DAX analysis, and the insights extracted — not in claiming the data is real.

## ❓ Business Questions Explored

- Which vendor category is least reliable, and how does that compare to cost?
- Do outdoor events with large guest counts overrun budgets more than others?
- Which season drives the most events and the highest spend?
- What's the relationship between planning time and budget?
- Which cake flavors and themes are most popular, including among repeat customers?
- How does spend accumulate month over month across the year?
- Weekend vs. weekday differences in budget and turnout?

## 🛠️ SQL Analysis

15+ queries covering joins, CTEs, aggregations, and window functions, including:
- `GROUP BY` + `HAVING` to identify repeat customers from raw event history
- CTEs to pre-aggregate vendor delay status before joining to event-level satisfaction
- Window functions: running total of monthly budget (`SUM() OVER`), vendor cost ranking within category (`RANK() OVER PARTITION BY`)

See `sql_analysis.sql` for the full query set with inline comments.

## 📊 Power BI Dashboard

Five pages, each built around a specific business question rather than a generic chart dump:

1. **Overview** — KPI summary (total events, budget, satisfaction, overrun %), events by season & venue type, satisfaction gauge
2. **Vendor Reliability** — combo chart of vendor cost vs. delay rate, supporting detail table
3. **Budget & Venue Analysis** — scatter plot (guest count vs. budget overrun, colored by venue type), overrun % by venue type
4. **Seasonality & Customer** — weekday vs. weekend budget comparison, running total of budget by month
5. **Key Insights** — headline findings written for a business audience

DAX measures include `Vendor Late %`, `Avg Budget Overrun %`, `Repeat Customer %`, and a running-total measure using `CALCULATE` + `REMOVEFILTERS`.

## 💡 Key Insights

- **Outdoor events with more than 120 guests overran their planned budget by an average of 19%**, compared to just 4% for indoor/home events under 120 guests — a nearly 5x difference. This suggests outdoor large-scale events need dedicated budget buffers or repriced packages.
- **Decoration vendors have the highest delay rate among all vendor categories at ~27%**, despite Catering being the highest-cost category — meaning cost risk and reliability risk sit in two different places. Decoration is the stronger candidate for renegotiated SLAs or backup vendor sourcing.
- Summer and Festive seasons drive the highest event volume and total spend, useful for seasonal vendor-capacity planning.
- A month-over-month running total shows budget spend growing steadily across the two-year window, useful for tracking cumulative business growth.

## 📁 Repo Structure

```
/birthday-event-analytics
  ├── generate_data.py      # Synthetic data generator (Python)
  ├── sql_analysis.sql      # Full SQL query set with comments
  ├── dashboard.pbix        # Power BI dashboard file
  ├── screenshots/          # Dashboard page exports
  └── README.md
```

## 🔁 How to Reproduce

1. Run `generate_data.py` in Google Colab or locally to generate the 4 CSVs
2. Import the CSVs into SQL Server (Flat File Import) and set up relationships (`event_id`, `customer_id` as keys)
3. Run the queries in `sql_analysis.sql`
4. Open `dashboard.pbix` in Power BI Desktop, connect to your SQL Server instance, and refresh

---

*Built as part of an ongoing data analytics portfolio. Feedback welcome.*
