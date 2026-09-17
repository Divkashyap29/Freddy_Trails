-- Physical and sensory detail about each business.
-- Two consumers: story generation (hooks) and photo verification (reference
-- descriptions). Collected on-site by a person, not scraped.

create table feature_types (
    code        text primary key,
    label       text not null,
    description text not null,
    created_at  timestamptz not null default now()
);

insert into feature_types (code, label, description) values
    ('visual',   'Visual',   'Murals, signs, paintings, stained glass, anything you look at'),
    ('spatial',  'Spatial',  'Booths, staircases, window seats, how the room is arranged'),
    ('ambient',  'Ambient',  'Smells, sounds, textures, temperature'),
    ('historic', 'Historic', 'What the building was before, dates, former occupants'),
    ('object',   'Object',   'Tills, bookshelves, machines, oddities on a shelf');

create table business_features (
    id            uuid primary key default uuidv7(),
    business_id   uuid not null references businesses (id) on delete cascade,
    feature_type  text not null references feature_types (code),
    description   text not null,
    location_hint text,
    is_current    boolean not null default true,
    source        text not null check (source in ('self_reported', 'observed')),
    verified_at   timestamptz,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
);

create trigger business_features_set_updated_at
    before update on business_features
    for each row
    execute function set_updated_at();

create index business_features_business_id_idx
    on business_features (business_id);