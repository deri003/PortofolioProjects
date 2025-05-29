-- Student habits VS Academic performance
-- https://www.kaggle.com/datasets/jayaantanaath/student-habits-vs-academic-performance

-- Data Cleaning
SELECT *
FROM student.student_habits_performance;

SELECT COUNT(*)
FROM student.student_habits_performance;

CREATE TABLE student.student_habits_performance1
LIKE student.student_habits_performance;

INSERT INTO student.student_habits_performance1
SELECT *
FROM student.student_habits_performance;

SELECT *
FROM student.student_habits_performance1;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY student_id, age, gender, study_hours_per_day, social_media_hours, netflix_hours, part_time_job,
attendance_percentage, sleep_hours, diet_quality, exercise_frequency, parental_education_level,
internet_quality, mental_health_rating, extracurricular_participation, exam_score) AS row_num
FROM student.student_habits_performance1;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY student_id, age, gender, study_hours_per_day, social_media_hours, netflix_hours, part_time_job,
attendance_percentage, sleep_hours, diet_quality, exercise_frequency, parental_education_level,
internet_quality, mental_health_rating, extracurricular_participation, exam_score) AS row_num
FROM student.student_habits_performance1
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT DISTINCT gender
FROM student.student_habits_performance1;

SELECT COUNT(*)
FROM student.student_habits_performance1
WHERE gender = 'Other';

DELETE
FROM student.student_habits_performance1
WHERE gender = 'Other';

SELECT COUNT(*)
FROM student.student_habits_performance1;

SELECT DISTINCT part_time_job
FROM student.student_habits_performance1;

SELECT DISTINCT diet_quality
FROM student.student_habits_performance1;

SELECT DISTINCT parental_education_level
FROM student.student_habits_performance1;

SELECT DISTINCT internet_quality
FROM student.student_habits_performance1;

SELECT DISTINCT extracurricular_participation
FROM student.student_habits_performance1;

SELECT *
FROM student.student_habits_performance1
WHERE 
    student_id IS NULL OR TRIM(student_id) = '' OR
    gender IS NULL OR TRIM(gender) = '' OR
    part_time_job IS NULL OR TRIM(part_time_job) = '' OR
    diet_quality IS NULL OR TRIM(diet_quality) = '' OR
    exercise_frequency IS NULL OR TRIM(exercise_frequency) = '' OR
    parental_education_level IS NULL OR TRIM(parental_education_level) = '' OR
    internet_quality IS NULL OR TRIM(internet_quality) = '' OR
    mental_health_rating IS NULL OR TRIM(mental_health_rating) = '' OR
    extracurricular_participation IS NULL OR TRIM(extracurricular_participation) = '' OR
    age IS NULL OR
    study_hours_per_day IS NULL OR
    social_media_hours IS NULL OR
    netflix_hours IS NULL OR
    attendance_percentage IS NULL OR
    sleep_hours IS NULL OR
    exam_score IS NULL;
    
-- Exploratory Data Analysis
SELECT MAX(exam_score), MIN(exam_score)
FROM student.student_habits_performance1;
-- The highest exam score is 100 while the lowest is 18.4

SELECT COUNT(student_id), exam_score
FROM student.student_habits_performance1
WHERE exam_score = 100;
-- A total of 47 students obtained an exam score of 100.

SELECT AVG(study_hours_per_day), AVG(social_media_hours), AVG(attendance_percentage), AVG(sleep_hours), AVG(exercise_frequency), AVG(mental_health_rating)
FROM student.student_habits_performance1
WHERE exam_score = 100;

SELECT AVG(study_hours_per_day), AVG(social_media_hours), AVG(attendance_percentage), AVG(sleep_hours), AVG(exercise_frequency), AVG(mental_health_rating)
FROM student.student_habits_performance1
WHERE exam_score <= 75;

SELECT AVG(study_hours_per_day), AVG(social_media_hours), AVG(attendance_percentage), AVG(sleep_hours), AVG(exercise_frequency), AVG(mental_health_rating)
FROM student.student_habits_performance1
WHERE exam_score <= 50;

-- The lower the student's exam_score is directly proportional to the average study_hours_per_day, average attendance_percentage, average exercise_frequency, and average mental_health_rating. This means that the lack of study_hours_per_day, lack of attendance_percentage, lack of exercise_frequency and low mental_health_rating greatly affect the low exam_score of students.
-- The lower the student's exam_score is inversely proportional to the average social_media_hours, meaning that the more often students are active on social media, the lower the student's exam_score.

SELECT exam_score, part_time_job, COUNT(*) AS part_time_job
FROM student.student_habits_performance1
WHERE exam_score = 100
GROUP BY part_time_job;
-- Of the 47 students who achieved an exam_score off 100, 38 students did not take part_time_jobs.

SELECT exam_score, extracurricular_participation, COUNT(*) AS extracurricular_participation
FROM student.student_habits_performance1
WHERE exam_score = 100
GROUP BY extracurricular_participation;
-- Of the 47 students who achieved an exam_score off 100, 32 students did not participate in extracurricular_participation.
