{#
    Enrich staged titles:
      - parse "90 min" / "2 Seasons" duration into numeric columns
      - convert the textual date_added ("September 25, 2021") into a real DATE
#}

with titles as (

    select * from {{ ref('stg_netflix_titles') }}

),

enriched as (

    select
        show_id,
        title_type,
        title,
        director,
        cast_members,
        country,
        release_year,
        rating,
        genres,
        description,

        -- "September 25, 2021" -> DATE (TRY_ avoids hard failures on bad values)
        try_to_date(date_added_raw, 'MMMM DD, YYYY')            as date_added,

        duration_raw,

        -- Movies are measured in minutes
        case
            when title_type = 'Movie'
            then try_to_number(split_part(duration_raw, ' ', 1))
        end                                                      as duration_minutes,

        -- TV Shows are measured in seasons
        case
            when title_type = 'TV Show'
            then try_to_number(split_part(duration_raw, ' ', 1))
        end                                                      as num_seasons

    from titles

)

select * from enriched
