{#
    Explode the comma-separated genres ("listed_in") into one row per genre,
    then count titles per genre.
#}

with titles as (

    select * from {{ ref('int_netflix_titles_enriched') }}

),

exploded as (

    select
        t.show_id,
        t.title_type,
        trim(g.value)                                   as genre
    from titles t,
         lateral split_to_table(t.genres, ',') g
    where t.genres is not null

)

select
    genre,
    title_type,
    count(distinct show_id)                             as title_count
from exploded
group by genre, title_type
order by title_count desc
