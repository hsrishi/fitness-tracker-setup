-- Step 1: Create a virtual warehouse, two new databases (one for raw data, the other for analytics), and three new schemas in the raw database (myfitnesspal, apple health, training)
create warehouse transforming; -- with warehouse_size = 'XSMALL' auto_suspend = 600 auto_resume = true
create database fitness_raw;
create database fitness_analytics;
create schema fitness_raw.myfitnesspal;
create schema fitness_raw.training;
create schema fitness_raw.applehealth;

-- Step 2: Create an external stage for public s3 bucket containing raw data
create stage fitness_s3_stage
  url = 's3://fitness-data-hr/';

-- Step 3: In the fitness_raw database, create tables for myfitnesspal and training
create table fitness_raw.myfitnesspal.measurements
(
  date DATE,
  weight FLOAT
);

create or replace table fitness_raw.myfitnesspal.nutrition
(
  date DATE,
  meal VARCHAR(50),
  time VARCHAR(50),
  calories FLOAT,
  fat_g FLOAT,
  fat_saturated_g FLOAT,
  fat_polyunsaturated_g FLOAT,
  fat_monounsaturated_g FLOAT,
  fat_trans_g FLOAT,
  cholesterol_mg FLOAT,
  sodium_mg FLOAT,
  potassium_mg FLOAT,
  carbs_g FLOAT,
  fiber_g FLOAT,
  sugar_g FLOAT,
  protein_g FLOAT,
  vitamin_A_ug FLOAT,
  vitamin_C_mg FLOAT,
  calcium_mg FLOAT,
  iron_mg FLOAT,
  notes VARCHAR(500)
);

create or replace table fitness_raw.training.btwb
(
  date DATE,
  workout VARCHAR(500),
  result FLOAT,
  prescribed BOOLEAN,
  work_performed VARCHAR(50),
  work_time_ms INT,
  result_formatted VARCHAR(500)--,
--   notes VARCHAR(500),
--   description VARCHAR(1000)
);

copy into fitness_raw.myfitnesspal.measurements
from @fitness_s3_stage/Measurement-Summary-2014-07-04-to-2023-08-18.csv
file_format = (
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1
);

copy into fitness_raw.myfitnesspal.nutrition
from @fitness_s3_stage/Nutrition-Summary-2014-07-04-to-2023-08-18.csv
file_format = (
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1
);

-- format the source file in s3 to replace "," with ";" and remove description and notes columns (contain newline characters)
copy into fitness_raw.training.btwb
from @fitness_s3_stage/btwb_2023-08-16_format_nodesc-notes.csv
file_format = (
  type = 'CSV'
  field_delimiter = ','
  skip_header = 1
);

-- Step 4: Verify that the data was loaded correctly
select * from fitness_raw.myfitnesspal.measurements
select * from fitness_raw.myfitnesspal.nutrition
select * from fitness_raw.training.btwb
