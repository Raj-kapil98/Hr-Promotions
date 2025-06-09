🚀 HR Promotion Prediction Project

🎯 Objective

Identify the top 5 promotion-eligible employees in each department using structured SQL-based analysis on employee datasets. This project simulates a real-world HR analyst use case with PostgreSQL and Power BI.

🗂️ Folder Structure

hr-promotion-analyst/
├── data/                     # Raw CSV files
│   ├── train.csv             # With actual promotions
│   └── test.csv              # Without promotion labels
│
├── sql/                      # All analysis SQL scripts
│   ├── 1_data_exploration.sql
│   ├── 2_promotion_score.sql
│   └── 3_top5_per_department.sql
│
├── views/                    # View used in dashboards
│   └── hr_summary_view.sql
│
├── output/                   # Final results
│   └── top_5_prediction_results.csv
│
└── README.md

📊 Dataset Overview

📁 train.csv

Includes employee attributes

Contains is_promoted label for analysis

📁 test.csv

Same attributes as train.csv

Lacks is_promoted — used for prediction

🧰 Tech Stack

Database: PostgreSQL

Querying: SQL Window Functions & Joins

Version Control: GitHub

Visualization (optional): Power BI or Excel

🧪 Step-by-Step SQL Analysis

1️⃣ Data Exploration — 1_data_exploration.sql

-- Count rows and missing fields
SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE previous_year_rating IS NULL) AS null_rating
FROM train;

-- Age and training score range
SELECT MIN(age), MAX(age), AVG(avg_training_score) FROM train;

-- Overall promotion rate
SELECT COUNT(*) FILTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100 AS promotion_rate FROM train;

2️⃣ Promotion Score Formula — 2_promotion_score.sql

-- Add weighted score based on logic
SELECT *,
  (CASE WHEN previous_year_rating >= 4 THEN 10 ELSE 3 END) +
  (CASE WHEN avg_training_score >= 85 THEN 10 ELSE 3 END) +
  (CASE WHEN "awards_won?" = 1 THEN 10 ELSE 0 END) +
  (CASE WHEN length_of_service >= 5 THEN 5 ELSE 2 END) +
  (CASE WHEN no_of_trainings >= 3 THEN 3 ELSE 1 END) AS promotion_score
INTO test_scored
FROM test;

3️⃣ Top 5 Candidates per Department — 3_top5_per_department.sql

-- Rank and pick top 5 from each department
SELECT *
FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY department ORDER BY promotion_score DESC) AS rank
  FROM test_scored
) AS ranked
WHERE rank <= 5;

4️⃣ Bonus View for BI — views/hr_summary_view.sql

CREATE VIEW hr_promotion_summary AS
SELECT department, gender, education,
       COUNT(*) AS total,
       COUNT(*) FILTER (WHERE is_promoted = 1) AS promoted,
       ROUND(COUNT(*) FILTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100, 2) AS promotion_rate
FROM train
GROUP BY department, gender, education;

🔍 Key Business Insights

✅ High performance (rating ≥ 4) and awards are top indicators for promotion.

📈 Employees with training scores above 85 have a higher chance.

👁️ Departmental patterns show uneven promotion rates — needs policy check.

💡 What Can Be Improved?

Add Machine Learning scoring instead of rule-based.

Automate ranking with stored procedures.

Integrate with Power BI for HR Dashboards.

👤 Author

Raj Kapil Data & Reporting Enthusiast

📬 Contact: LinkedIn Profile https://www.linkedin.com/in/raj-kapil-8b971a298/?originalSubdomain=in

🎓 “Let data drive fairness and performance in HR decisions.”

