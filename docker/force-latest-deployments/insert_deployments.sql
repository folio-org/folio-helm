create or replace view public.vlatest_modules
as
select id, name, modulejson
from (
         select id, modulejson, name, first_value(id) over (partition by name order by v1 desc, v2 desc, v3 desc, build desc) last_id
         from (
                  select id,
                         modulejson,
                         name,
                         v1,
                         v2,
                         v3,
                         (case when build = 0 then (max(build) over (partition by name, v1, v2, v3)) + 1 else build end) build
                  from (
                           select id,
                                  modulejson,
                                  xid[1]                                                as name,
                                  xid[2]::int                                           as v1,
                                  xid[3]::int                                           as v2,
                                  (case when xid[4] = '' then '0' else xid[4] end)::int as v3,
                                  (case when xid[5] = '' then '0' else xid[5] end)::int as build
                           from (
                                    select id, modulejson, (regexp_match(id, '(.+)-(\d+)\.(\d+)\.?(\d*)-?\D*(\d*)')) xid
                                    From (select modulejson ->> 'id' id, modulejson from public.modules) x
                                ) y) z) a) b
where id = last_id;

insert into public.deployments
select json_build_object('url', 'http://' || name, 'instId', id, 'srvcId', id) jsonb
from public.vlatest_modules;

