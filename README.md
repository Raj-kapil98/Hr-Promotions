HR Promotion Analyst Project (SQL Based)

🧠 Objective

Predict the top 5 employees in each department likely to be promoted using HR data. The dataset includes employee details such as education, experience, training score, and past ratings.

📁 Project Structure

hr-promotion-analyst/
├── data/
│   ├── train.csv
│   └── test.csv
│
├── sql/
│   ├── 1_data_exploration.sql
│   ├── 2_promotion_score.sql
│   └── 3_top5_per_department.sql
│
├── views/
│   └── hr_summary_view.sql
│
├── output/
│   └── top_5_prediction_results.csv
│
└── README.md

🧾 Dataset Description

train.csv

Includes employee data and actual promotion status (is_promoted column).

Used to understand patterns in promotion.

test.csv

Similar structure but no is_promoted column.

Used to identify potential candidates for next promotion.

🛠️ Tools Used

PostgreSQL

SQL Window Functions

GitHub for versioning

🔍 SQL Logic Summary

1. Data Exploration (1_data_exploration.sql)

-- Total rows and missing values
SELECT
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE previous_year_rating IS NULL) AS null_rating,
  COUNT(*) FILTER (WHERE education IS NULL) AS null_education,
  COUNT(*) FILTER (WHERE "awards_won?" IS NULL) AS null_awards
FROM train;

-- Summary statistics
SELECT
  MIN(age) AS min_age,
  MAX(age) AS max_age,
  AVG(avg_training_score) AS avg_score
FROM train;

-- Promotion rate
SELECT 
  COUNT(*) AS total_employees,
  COUNT(*) FILTER (WHERE is_promoted = 1) AS promoted_employees,
  ROUND(COUNT(*) FILTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100, 2) AS promotion_rate
FROM train;

-- Promotion by department
SELECT department,
       COUNT(*) AS total,
       COUNT(*) FILTER (WHERE is_promoted = 1) AS promoted,
       ROUND(COUNT(*) FILTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100, 2) AS promotion_rate
FROM train
GROUP BY department
ORDER BY promotion_rate DESC;

2. Scoring Formula (2_promotion_score.sql)

-- Generate promotion score based on weighted business logic
SELECT *,
  (CASE WHEN previous_year_rating >= 4 THEN 10
        WHEN previous_year_rating = 3 THEN 7
        ELSE 3 END) +
  (CASE WHEN avg_training_score >= 85 THEN 10
        WHEN avg_training_score >= 70 THEN 7
        ELSE 3 END) +
  (CASE WHEN "awards_won?" = 1 THEN 10 ELSE 0 END) +
  (CASE WHEN length_of_service >= 5 THEN 5 ELSE 2 END) +
  (CASE WHEN no_of_trainings >= 3 THEN 3 ELSE 1 END) AS promotion_score
INTO test_scored
FROM test;

3. Top 5 Per Department (3_top5_per_department.sql)

-- Select top 5 employees by department based on promotion score
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY department ORDER BY promotion_score DESC) AS rank
  FROM test_scored
) ranked
WHERE rank <= 5;

4. Optional View for Dashboard (views/hr_summary_view.sql)

-- Summary view for BI dashboard
CREATE VIEW hr_promotion_summary AS
SELECT department, gender, education, region,
       COUNT(*) AS total_employees,
       COUNT(*) FILTER (WHERE is_promoted = 1) AS promoted_employees,
       ROUND(COUNT(*) FILTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100, 2) AS promotion_rate
FROM train
GROUP BY department, gender, education, region;

📌 Key Insights

High ratings and awards are strong indicators for promotion.

Training score matters especially when above 85.

Gender bias and regional impact should be monitored.

📤 Future Improvements

Use ML classification models (Logistic Regression, Random Forest) for scoring.

Automate scoring with a scheduled stored procedure.

Build an HR Dashboard with Power BI.

🧑‍💻 Author

Raj Kapil
