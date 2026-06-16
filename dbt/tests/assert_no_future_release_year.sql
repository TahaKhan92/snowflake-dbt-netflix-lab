-- Singular test: no title should claim a release year in the future.
-- The test passes when this query returns zero rows.

select
    show_id,
    title,
    release_year
from {{ ref('stg_netflix_titles') }}
where release_year > year(current_date())
