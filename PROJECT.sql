CREATE TABLE TEST (employee_id INT,
department VARCHAR (100),
region VARCHAR (100),
education VARCHAR (100),
gender VARCHAR (50),
recruitment_channel VARCHAR(200),
no_of_trainings INT,
age INT,
previous_year_rating DECIMAL(10,2),
length_of_service INT,
awards_won INT,
avg_training_score INT);
SELECT * FROM TEST;
DROP TABLE TEST ;

copy TEST FROM 'D:/archive (2)/test.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE TRAIN  (employee_id INT,
department VARCHAR (100),
region VARCHAR (100),
education VARCHAR (100),
gender VARCHAR (100),
recruitment_channel VARCHAR (100),
no_of_trainings INT,
age INT,
previous_year_rating DECIMAL(10,2),
length_of_service INT,
awards_won INT,
avg_training_score INT,
is_promoted INT
);
copy TRAIN FROM 'D:/archive (2)/train.csv' DELIMITER ',' CSV HEADER;
SELECT * FROM TRAIN;

--- data cleaning steps

SELECT
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE previous_year_rating IS NULL) AS null_rating,
  COUNT(*) FILTER (WHERE education IS NULL) AS null_education,
  COUNT(*) FILTER (WHERE awards_won IS NULL) AS null_awards
FROM train;

SELECT
  MIN(age) AS min_age,
  MAX(age) AS max_age,
  AVG(avg_training_score) AS avg_score
FROM train;

---  Overall Promotion Rate

SELECT 
  COUNT(*) AS total_employees,
  COUNT(*) FILTER (WHERE is_promoted = 1) AS promoted_employees,
  ROUND(COUNT(*) FIromotion by DepartmentLTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100, 2) AS promotion_rate
FROM train;


--- promotion by Department

SELECT department,
       COUNT(*) AS total,
       COUNT(*) FILTER (WHERE is_promoted = 1) AS promoted,
       ROUND(COUNT(*) FILTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100, 2) AS promotion_rate
FROM train
GROUP BY department
ORDER BY promotion_rate DESC;


---Previous Year Rating vs Promotion
SELECT previous_year_rating,
       COUNT(*) AS total,
       COUNT(*) FILTER (WHERE is_promoted = 1) AS promoted,
       ROUND(COUNT(*) FILTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100, 2) AS rate
FROM train
GROUP BY previous_year_rating
ORDER BY previous_year_rating;

---Average Training Score Buckets

SELECT
  CASE 
    WHEN avg_training_score >= 85 THEN 'High (85-100)'
    WHEN avg_training_score >= 70 THEN 'Medium (70-84)'
    ELSE 'Low (<70)'
  END AS score_group,
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE is_promoted = 1) AS promoted,
  ROUND(COUNT(*) FILTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100, 2) AS promotion_rate
FROM train
GROUP BY score_group
ORDER BY promotion_rate DESC;


--- genderwise promotion analysis

SELECT gender,
       COUNT(*) AS total,
       COUNT(*) FILTER (WHERE is_promoted = 1) AS promoted,
       ROUND(COUNT(*) FILTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100, 2) AS promotion_rate
FROM train
GROUP BY gender;


CREATE VIEW hr_promotion_summary AS
SELECT department, gender, education, region,
       COUNT(*) AS total_employees,
       COUNT(*) FILTER (WHERE is_promoted = 1) AS promoted_employees,
       ROUND(COUNT(*) FILTER (WHERE is_promoted = 1)::DECIMAL / COUNT(*) * 100, 2) AS promotion_rate
FROM train
GROUP BY department, gender, education, region;

---create a score using weighted rules based on business intuition:

SELECT *,
  -- Score each factor from 0 to 1 or 0 to 10
  (CASE WHEN previous_year_rating >= 4 THEN 10
        WHEN previous_year_rating = 3 THEN 7
        ELSE 3 END) +
  (CASE WHEN avg_training_score >= 85 THEN 10
        WHEN avg_training_score >= 70 THEN 7
        ELSE 3 END) +
  (CASE WHEN "awards_won" = 1 THEN 10 ELSE 0 END) +
  (CASE WHEN length_of_service >= 5 THEN 5 ELSE 2 END) +
  (CASE WHEN no_of_trainings >= 3 THEN 3 ELSE 1 END) AS promotion_score
INTO test_scored
FROM test;

---Now extract top 5 per department:

SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY department ORDER BY promotion_score DESC) AS rank
  FROM test_scored
) ranked
WHERE rank <= 5;




