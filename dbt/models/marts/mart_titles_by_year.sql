{#
    Content counts by release year and type, plus average movie runtime.
#}

with titles as (

    select * from {{ ref('int_netflix_titles_enriched') }}

)

select
    release_year,
    title_type,
    count(*)                                            as title_count,
    avg(duration_minutes)                               as avg_movie_minutes,
    avg(num_seasons)                                    as avg_seasons
from titles
where release_year is not null
group by release_year, title_type
order by release_year desc, title_type
