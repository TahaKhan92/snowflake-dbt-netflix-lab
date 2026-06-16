{#
    Most prolific actors by number of distinct titles they appear in.
    Sourced from credits only (does not join to netflix_titles).
#}

with credits as (

    select * from {{ ref('stg_credits') }}

)

select
    person_id,
    person_name,
    count(distinct title_id)                            as title_count
from credits
where role = 'ACTOR'
group by person_id, person_name
order by title_count desc
limit 100
