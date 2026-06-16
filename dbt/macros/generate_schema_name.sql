{#
    Use the custom schema name verbatim (STAGING / INTERMEDIATE / MARTS)
    instead of dbt's default of <target_schema>_<custom_schema>.
    These schemas already exist in DBT_SNOWFLAKE_DEV.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim | upper }}
    {%- endif -%}
{%- endmacro %}
