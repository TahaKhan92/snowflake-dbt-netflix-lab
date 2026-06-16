with source as (

    select * from {{ source('raw', 'NETFLIX_TITLES') }}

),

renamed as (

    select
        trim(show_id)                              as show_id,
        trim(type)                                 as title_type,        -- 'Movie' / 'TV Show'
        trim(title)                                as title,
        trim(director)                             as director,
        trim("CAST")                               as cast_members,      -- CAST is a reserved word
        trim(country)                              as country,
        date_added                                 as date_added_raw,    -- e.g. "September 25, 2021"
        release_year                               as release_year,
        trim(rating)                               as rating,
        trim(duration)                             as duration_raw,      -- e.g. "90 min" / "2 Seasons"
        trim(listed_in)                            as genres,            -- comma-separated
        description                                as description
    from source

)

select * from renamed
