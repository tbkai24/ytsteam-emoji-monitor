create table if not exists public.emoji_app_settings (
  id bigint primary key,
  website_name text,
  logo_url text,
  hero_title text,
  hero_subtitle text,
  hero_image_url text,
  embeds_title text,
  embeds_subtitle text,
  footer_text text,
  x_url text,
  facebook_url text,
  instagram_url text,
  enable_range_1h boolean not null default true,
  enable_range_24h boolean not null default true,
  enable_range_7d boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.emoji_app_settings (
  id,
  website_name,
  enable_range_1h,
  enable_range_24h,
  enable_range_7d
)
values (1, 'SB19 Youtube Streamers', true, true, true)
on conflict (id) do nothing;

create table if not exists public.emoji_monitoring_snapshots (
  id bigint generated always as identity primary key,
  captured_at timestamptz not null default now(),
  views bigint,
  likes bigint,
  comments bigint,
  views_per_hour numeric,
  created_at timestamptz not null default now()
);

create index if not exists emoji_monitoring_snapshots_captured_at_idx
  on public.emoji_monitoring_snapshots (captured_at desc);

create table if not exists public.emoji_milestones (
  id bigint generated always as identity primary key,
  title text not null,
  target_count bigint not null check (target_count > 0),
  current_count bigint not null default 0,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists emoji_milestones_sort_order_idx
  on public.emoji_milestones (sort_order asc, created_at asc);

create table if not exists public.emoji_embeds (
  id bigint generated always as identity primary key,
  title text not null,
  url text not null,
  thumbnail_url text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists emoji_embeds_sort_order_idx
  on public.emoji_embeds (sort_order asc, created_at asc);

create table if not exists public.emoji_embed_click_events (
  id bigint generated always as identity primary key,
  embed_id bigint not null references public.emoji_embeds (id) on delete cascade,
  clicked_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists emoji_embed_click_events_embed_id_clicked_at_idx
  on public.emoji_embed_click_events (embed_id, clicked_at desc);

create index if not exists emoji_embed_click_events_clicked_at_idx
  on public.emoji_embed_click_events (clicked_at desc);

create table if not exists public.emoji_trending_current (
  id bigint generated always as identity primary key,
  video_id text not null,
  category text not null default 'overall',
  country text not null,
  rank integer not null check (rank > 0),
  source text,
  captured_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  constraint emoji_trending_current_video_category_country_key unique (video_id, category, country)
);

create index if not exists emoji_trending_current_video_rank_idx
  on public.emoji_trending_current (video_id, category, rank, country);

alter table public.emoji_app_settings enable row level security;
alter table public.emoji_monitoring_snapshots enable row level security;
alter table public.emoji_milestones enable row level security;
alter table public.emoji_embeds enable row level security;
alter table public.emoji_embed_click_events enable row level security;
alter table public.emoji_trending_current enable row level security;

drop policy if exists "Public can read emoji app settings" on public.emoji_app_settings;
create policy "Public can read emoji app settings"
  on public.emoji_app_settings
  for select
  using (true);

drop policy if exists "Authenticated can manage emoji app settings" on public.emoji_app_settings;
create policy "Authenticated can manage emoji app settings"
  on public.emoji_app_settings
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "Public can read emoji monitoring snapshots" on public.emoji_monitoring_snapshots;
create policy "Public can read emoji monitoring snapshots"
  on public.emoji_monitoring_snapshots
  for select
  using (true);

drop policy if exists "Authenticated can manage emoji monitoring snapshots" on public.emoji_monitoring_snapshots;
create policy "Authenticated can manage emoji monitoring snapshots"
  on public.emoji_monitoring_snapshots
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "Public can read emoji milestones" on public.emoji_milestones;
create policy "Public can read emoji milestones"
  on public.emoji_milestones
  for select
  using (true);

drop policy if exists "Authenticated can manage emoji milestones" on public.emoji_milestones;
create policy "Authenticated can manage emoji milestones"
  on public.emoji_milestones
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "Public can read emoji embeds" on public.emoji_embeds;
create policy "Public can read emoji embeds"
  on public.emoji_embeds
  for select
  using (true);

drop policy if exists "Authenticated can manage emoji embeds" on public.emoji_embeds;
create policy "Authenticated can manage emoji embeds"
  on public.emoji_embeds
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "Public can insert emoji embed clicks" on public.emoji_embed_click_events;
create policy "Public can insert emoji embed clicks"
  on public.emoji_embed_click_events
  for insert
  with check (true);

drop policy if exists "Authenticated can read emoji embed clicks" on public.emoji_embed_click_events;
create policy "Authenticated can read emoji embed clicks"
  on public.emoji_embed_click_events
  for select
  using (auth.role() = 'authenticated');

drop policy if exists "Authenticated can manage emoji embed clicks" on public.emoji_embed_click_events;
create policy "Authenticated can manage emoji embed clicks"
  on public.emoji_embed_click_events
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

drop policy if exists "Public can read emoji trending current" on public.emoji_trending_current;
create policy "Public can read emoji trending current"
  on public.emoji_trending_current
  for select
  using (true);

drop policy if exists "Authenticated can manage emoji trending current" on public.emoji_trending_current;
create policy "Authenticated can manage emoji trending current"
  on public.emoji_trending_current
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');
