-- Kazi schema. Run this once in the Supabase SQL editor:
-- https://supabase.com/dashboard/project/kjwxjhuizftsqulhkhdi/sql
--
-- Also in Authentication → Providers → Email:
-- turn OFF "Confirm email" while developing, so sign-up can sign in immediately.
--
-- The bottom of this file creates Storage buckets (avatars, portfolio,
-- verification, certificates). If bucket insert is blocked, create those
-- four public buckets in Storage → Buckets, then re-run the policies.
--
-- Database → Publications: inquiries must be in supabase_realtime
-- (this file adds it). Turn Realtime on for the inquiries table if needed.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role text not null check (role in ('worker', 'customer')),
  first_name text not null default '',
  last_name text not null default '',
  email text not null default '',
  phone text,
  whatsapp text,
  age integer,
  town text not null default '',
  country text not null default 'Namibia',
  avatar_url text,
  contacted_worker_ids text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.worker_profiles (
  id uuid primary key references public.profiles (id) on delete cascade,
  bio text not null default '',
  specializations text[] not null default '{}',
  experience text,
  portfolio_urls text[] not null default '{}',
  id_document_url text,
  face_scan_url text
);

create table if not exists public.certifications (
  id uuid primary key default gen_random_uuid(),
  worker_id uuid not null references public.worker_profiles (id) on delete cascade,
  title text not null,
  issuer text not null,
  document_url text not null default ''
);

create table if not exists public.inquiries (
  id uuid primary key default gen_random_uuid(),
  worker_id text not null,
  worker_name text not null default '',
  worker_town text not null default '',
  worker_email text not null default '',
  worker_phone text not null default '',
  worker_whatsapp text not null default '',
  customer_id uuid not null references public.profiles (id) on delete cascade,
  customer_name text not null default '',
  customer_town text not null default '',
  customer_country text not null default '',
  customer_email text not null default '',
  customer_phone text not null default '',
  customer_whatsapp text not null default '',
  title text not null,
  description text not null,
  occurred_on date not null,
  timing text not null,
  free_days date[] not null default '{}',
  is_urgent boolean not null default false,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'rejected')),
  rejection_reason text,
  created_at timestamptz not null default now()
);

create index if not exists inquiries_customer_id_idx on public.inquiries (customer_id);
create index if not exists inquiries_worker_id_idx on public.inquiries (worker_id);

alter table public.profiles enable row level security;
alter table public.worker_profiles enable row level security;
alter table public.certifications enable row level security;
alter table public.inquiries enable row level security;

drop policy if exists "profiles_select_authenticated" on public.profiles;
create policy "profiles_select_authenticated"
  on public.profiles for select
  to authenticated
  using (true);

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
  on public.profiles for insert
  to authenticated
  with check (id = auth.uid());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

drop policy if exists "worker_profiles_select_authenticated" on public.worker_profiles;
create policy "worker_profiles_select_authenticated"
  on public.worker_profiles for select
  to authenticated
  using (true);

drop policy if exists "worker_profiles_write_own" on public.worker_profiles;
create policy "worker_profiles_write_own"
  on public.worker_profiles for all
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

drop policy if exists "certifications_select_authenticated" on public.certifications;
create policy "certifications_select_authenticated"
  on public.certifications for select
  to authenticated
  using (true);

drop policy if exists "certifications_write_own" on public.certifications;
create policy "certifications_write_own"
  on public.certifications for all
  to authenticated
  using (worker_id = auth.uid())
  with check (worker_id = auth.uid());

drop policy if exists "inquiries_select" on public.inquiries;
create policy "inquiries_select"
  on public.inquiries for select
  to authenticated
  using (
    customer_id = auth.uid()
    or exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'worker'
    )
  );

drop policy if exists "inquiries_insert_own" on public.inquiries;
create policy "inquiries_insert_own"
  on public.inquiries for insert
  to authenticated
  with check (customer_id = auth.uid());

drop policy if exists "inquiries_update_workers" on public.inquiries;
create policy "inquiries_update_workers"
  on public.inquiries for update
  to authenticated
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'worker'
    )
  );

drop policy if exists "inquiries_update_own_contact" on public.inquiries;
create policy "inquiries_update_own_contact"
  on public.inquiries for update
  to authenticated
  using (customer_id = auth.uid())
  with check (customer_id = auth.uid());

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'inquiries'
  ) then
    execute 'alter publication supabase_realtime add table public.inquiries';
  end if;
end $$;

create or replace function public.delete_own_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_own_account() from public;
grant execute on function public.delete_own_account() to authenticated;

-- Storage buckets for photos and documents.
-- Also create these in Storage → Buckets if SQL insert is blocked.
insert into storage.buckets (id, name, public)
values
  ('avatars', 'avatars', true),
  ('portfolio', 'portfolio', true),
  ('verification', 'verification', true),
  ('certificates', 'certificates', true)
on conflict (id) do update set public = excluded.public;

drop policy if exists "avatars_select" on storage.objects;
create policy "avatars_select"
  on storage.objects for select
  using (bucket_id = 'avatars');

drop policy if exists "avatars_write_own" on storage.objects;
create policy "avatars_write_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "avatars_update_own" on storage.objects;
create policy "avatars_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "avatars_delete_own" on storage.objects;
create policy "avatars_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "portfolio_select" on storage.objects;
create policy "portfolio_select"
  on storage.objects for select
  using (bucket_id = 'portfolio');

drop policy if exists "portfolio_insert_own" on storage.objects;
create policy "portfolio_insert_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'portfolio'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "portfolio_update_own" on storage.objects;
create policy "portfolio_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'portfolio'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "portfolio_delete_own" on storage.objects;
create policy "portfolio_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'portfolio'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "verification_select" on storage.objects;
create policy "verification_select"
  on storage.objects for select
  using (bucket_id = 'verification');

drop policy if exists "verification_insert_own" on storage.objects;
create policy "verification_insert_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'verification'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "verification_update_own" on storage.objects;
create policy "verification_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'verification'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "verification_delete_own" on storage.objects;
create policy "verification_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'verification'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "certificates_select" on storage.objects;
create policy "certificates_select"
  on storage.objects for select
  using (bucket_id = 'certificates');

drop policy if exists "certificates_insert_own" on storage.objects;
create policy "certificates_insert_own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'certificates'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "certificates_update_own" on storage.objects;
create policy "certificates_update_own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'certificates'
    and split_part(name, '/', 1) = auth.uid()::text
  );

drop policy if exists "certificates_delete_own" on storage.objects;
create policy "certificates_delete_own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'certificates'
    and split_part(name, '/', 1) = auth.uid()::text
  );
