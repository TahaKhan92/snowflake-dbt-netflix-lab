with source as (

    select * from {{ source('raw', 'CREDITS') }}

),

renamed as (

    select
        person_id            as person_id,
        trim(id)             as title_id,        -- e.g. tm84618 (NOT netflix show_id)
        trim(name)           as person_name,
        trim(character)      as character_name,
        upper(trim(role))    as role             -- ACTOR / DIRECTOR
    from source

)

select * from renamed
