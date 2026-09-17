create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create table businesses (
    id            uuid primary key default uuidv7(),
    name          text not null,
    address       text not null,
    phone_number  text,
    email         text,
    latitude      double precision not null check (latitude between -90 and 90),
    longitude     double precision not null check (longitude between -180 and 180),
    is_active     boolean not null default true,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
);

create trigger businesses_set_updated_at
    before update on businesses
    for each row
    execute function set_updated_at();