# Netflix dbt + Snowflake + AWS ELT Pipeline

End-to-end ELT project: AWS infrastructure provisioned with **Terraform**, the Netflix
titles + credits dataset loaded into **Snowflake** via **S3**, and transformed with **dbt**.

```
local CSV ──▶ S3 (raw/) ──▶ Snowflake external stage ──▶ COPY INTO raw tables ──▶ dbt models
```

![Architecture Diagram](Architecture%20Diagram.png)

## Repository structure

```
.
├── terraform/                  AWS infra (S3 bucket, EC2, security group)
│   ├── main.tf  variables.tf  outputs.tf
│   └── terraform.tfvars.example
├── snowflake/
│   ├── ddl/                    Run in numbered order to set up Snowflake
│   │   ├── 01_create_database.sql      DB, schemas, warehouse, role, grants
│   │   ├── 02_create_stage.sql         storage integration, file format, stages
│   │   ├── 03_create_tables.sql        RAW.NETFLIX_TITLES, RAW.CREDITS
│   │   └── 04_load_data_into_tables.sql COPY INTO from S3
│   └── iam/                     AWS IAM policy templates (placeholders, no real IDs)
├── dbt/                        dbt project (profile: dbt_snowflake)
│   ├── models/
│   │   ├── staging/            stg_netflix_titles, stg_credits (+ sources, tests)
│   │   ├── intermediate/       int_netflix_titles_enriched
│   │   └── marts/              mart_titles_by_year, mart_titles_by_genre, mart_top_actors
│   ├── macros/                 generate_schema_name (lands models in real schemas)
│   ├── tests/                  generic (not_negative) + singular (assert_no_future_release_year)
│   └── profiles.example.yml
└── data/                       Source CSVs (credits, netflix_titles)
```

## Setup

### 1. Provision AWS (Terraform)
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # fill in your values
terraform init
terraform apply
```

### 2. Upload the data to S3
```bash
aws s3 cp data/netflix_titles/netflix_titles.csv s3://<YOUR_BUCKET_NAME>/raw/netflix_titles/
aws s3 cp data/credits/credits.csv               s3://<YOUR_BUCKET_NAME>/raw/credits/
```

### 3. Set up Snowflake
Run the scripts in `snowflake/ddl/` in order (`01` → `04`). After `02_create_stage.sql`,
run `DESC INTEGRATION S3_DBT_INTEGRATION` and copy the `STORAGE_AWS_IAM_USER_ARN` and
`STORAGE_AWS_EXTERNAL_ID` into your AWS IAM role trust policy
(see `snowflake/iam/snowflake_trust_policy.json`).

### 4. Configure & run dbt
```bash
cp dbt/profiles.example.yml ~/.dbt/profiles.yml   # fill in account, user; set SNOWFLAKE_PASSWORD env var
cd dbt
dbt debug      # verify the connection
dbt run        # build all models
dbt test       # run data tests
```

## Data model

| Layer | Model | Materialization | Schema |
|-------|-------|----------------|--------|
| staging | `stg_netflix_titles`, `stg_credits` | view | `STAGING` |
| intermediate | `int_netflix_titles_enriched` | view | `INTERMEDIATE` |
| marts | `mart_titles_by_year`, `mart_titles_by_genre`, `mart_top_actors` | table | `MARTS` |

> **Note:** the two datasets use different ID schemes (`netflix_titles.show_id` = `s1…`
> vs `credits.id` = `tm84618`) and do **not** join. Each is modeled independently.

## Security / secrets
All credentials are kept out of git via `.gitignore`. Provided files use placeholders
(`<YOUR_AWS_ACCOUNT_ID>`, `<ORG_NAME>-<ACCOUNT_NAME>`, etc.). Never commit:
`*.pem`, AWS access-key CSVs, your real `profiles.yml`, `terraform.tfvars`, or `*.tfstate`.
