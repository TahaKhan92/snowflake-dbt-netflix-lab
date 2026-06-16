USE ROLE ACCOUNTADMIN;  -- need higher role to create integrations

-- Storage integration (one-time setup)
CREATE OR REPLACE STORAGE INTEGRATION S3_DBT_INTEGRATION
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/SnowflakeS3Role'
    STORAGE_ALLOWED_LOCATIONS = ('s3://dbt-snowflake-project-data-bucket-2026/raw/');

-- Check the integration — copy STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID
DESC INTEGRATION S3_DBT_INTEGRATION;

-- Create file format for CSV
CREATE OR REPLACE FILE FORMAT DBT_SNOWFLAKE_DEV.RAW.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null', 'N/A', '')
    EMPTY_FIELD_AS_NULL = TRUE
    TRIM_SPACE = TRUE;

-- Create stage for netflix_titles
CREATE OR REPLACE STAGE DBT_SNOWFLAKE_DEV.RAW.S3_NETFLIX_STAGE
    STORAGE_INTEGRATION = S3_DBT_INTEGRATION
    URL = 's3://dbt-snowflake-project-data-bucket-2026/raw/netflix_titles/'
    FILE_FORMAT = DBT_SNOWFLAKE_DEV.RAW.CSV_FORMAT;

-- Create stage for credits
CREATE OR REPLACE STAGE DBT_SNOWFLAKE_DEV.RAW.S3_CREDITS_STAGE
    STORAGE_INTEGRATION = S3_DBT_INTEGRATION
    URL = 's3://dbt-snowflake-project-data-bucket-2026/raw/credits/'
    FILE_FORMAT = DBT_SNOWFLAKE_DEV.RAW.CSV_FORMAT;