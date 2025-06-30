create database health;
-- importing the table into the created database
-- 1.	Data Cleaning and Structuring
-- Preprocess the internal healthcare dataset.
select * from healthcare_dataset;

-- Check count of NULLs in each column
-- Count missing (NULL) values for each column
SELECT
  SUM(Patient_ID IS NULL) AS Missing_Patient_ID,
  SUM(Visit_Date IS NULL) AS Missing_Visit_Date,
  SUM(Age IS NULL) AS Missing_Age,
  SUM(Gender IS NULL) AS Missing_Gender,
  SUM(Region IS NULL) AS Missing_Region,
  SUM(Diagnosis_Code IS NULL) AS Missing_Diagnosis_Code,
  SUM(Diagnosis_Description IS NULL) AS Missing_Diagnosis_Description,
  SUM(Treatment_Code IS NULL) AS Missing_Treatment_Code,
  SUM(Treatment_Description IS NULL) AS Missing_Treatment_Description,
  SUM(Cost IS NULL) AS Missing_Cost,
  SUM(Outcome IS NULL) AS Missing_Outcome,
  SUM(NHS_Guideline_Adherence IS NULL) AS Missing_NHS_Adherence
FROM healthcare_dataset;

-- Convert Visit_Date to DATE format
UPDATE healthcare_dataset
SET Visit_Date = STR_TO_DATE(Visit_Date, '%m/%d/%Y')
WHERE Visit_Date IS NOT NULL;

-- Alter column data types
ALTER TABLE healthcare_dataset
MODIFY Visit_Date DATE,
MODIFY Age INT,
MODIFY Cost DECIMAL(10,2);

-- Remove unreasonable ages
DELETE FROM healthcare_dataset
WHERE Age < 0 OR Age > 120;

-- Remove negative or extreme cost values
DELETE FROM healthcare_dataset
WHERE Cost < 0 OR Cost > 50000;

-- Organize structured healthcare records, including diagnoses, costs and treatments.
SELECT 
    Diagnosis_Code,
    Diagnosis_Description,
    Treatment_Code,
    Treatment_Description,
    COUNT(DISTINCT Patient_ID) AS Total_Patients,
    COUNT(*) AS Total_Visits,
    ROUND(SUM(Cost), 2) AS Total_Cost,
    ROUND(AVG(Cost), 2) AS Average_Cost,
    SUM(CASE WHEN NHS_Guideline_Adherence = 'Yes' THEN 1 ELSE 0 END) AS NHS_Adherent_Visits,
    SUM(CASE WHEN NHS_Guideline_Adherence = 'No' THEN 1 ELSE 0 END) AS Non_Adherent_Visits
FROM healthcare_dataset
GROUP BY 
    Diagnosis_Code, Diagnosis_Description,
    Treatment_Code, Treatment_Description
ORDER BY Total_Cost DESC;

-- 	Use SQL to identify high-frequency diagnoses treatment, treatment description, and cost trends.
-- High-Frequency Diagnoses with Treatment & Cost
SELECT 
    Diagnosis_code,
    Treatment_Code,
    Treatment_Description,
    COUNT(*) AS Frequency,
    AVG(Cost) AS Avg_Cost,
    SUM(Cost) AS Total_Cost
FROM 
    healthcare_dataset
GROUP BY 
    Diagnosis_code, Treatment_Code, Treatment_Description
ORDER BY 
    Frequency DESC;
-- 	Analyze patient outcomes by age group, gender, and regional location
SELECT 
    CASE 
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 35 THEN '18-35'
        WHEN Age BETWEEN 36 AND 55 THEN '36-55'
        WHEN Age BETWEEN 56 AND 75 THEN '56-75'
        ELSE '76+' 
    END AS Age_Group,
    Gender,
    Region,
    COUNT(*) AS Total_Patients
FROM healthcare_dataset
GROUP BY Age_Group, Gender, Region
ORDER BY Age_Group, Gender, Region;
