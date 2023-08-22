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