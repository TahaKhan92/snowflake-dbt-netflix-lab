{#
    Generic (reusable) test: fails if the given column contains negative values.
    Usage in a schema yml:
        columns:
          - name: some_number
            data_tests:
              - not_negative
#}
{% test not_negative(model, column_name) %}

select {{ column_name }}
from {{ model }}
where {{ column_name }} < 0

{% endtest %}
