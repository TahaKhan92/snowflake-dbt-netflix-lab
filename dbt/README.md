# dbt project — `dbt_snowflake` profile

Transforms the raw Netflix data in Snowflake into staging → intermediate → marts layers.

```bash
cp profiles.example.yml ~/.dbt/profiles.yml   # fill in your account/user; set SNOWFLAKE_PASSWORD
dbt debug
dbt run
dbt test
```

See the [repository README](../README.md) for the full pipeline and setup steps.
