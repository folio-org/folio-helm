drop view public.vmodules_hierarchy cascade;
drop view public.vmodules_dependencies cascade;
drop view public.vmodules_dependencies_with_interfaces cascade;
drop view public.vinterface_required cascade;
drop view public.vinterface_provided cascade;
drop view public.vlatest_modules cascade;


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

create or replace view public.vinterface_provided
as
select m.id             module_id,
       m.name           module_name,
       provides.id      interface_id,
       provides.version interface_version
from public.vlatest_modules m,
     jsonb_to_recordset(m.modulejson -> 'provides') as provides (id text, version text)
where provides.id not like '\_%';

create or replace view public.vinterface_required
as
select module_id, module_name, interface_id, interface_version
from (select m.id module_id, m.name module_name, requires.id interface_id, requires.version interface_version
      from public.vlatest_modules m,
           jsonb_to_recordset(m.modulejson -> 'requires') as requires (id text, version text)
      union all
      select m.id module_id, m.name module_name, null interface_id, null interface_version
      from public.vlatest_modules m
      where coalesce(jsonb_array_length(modulejson -> 'requires'), 0) = 0) r;

create or replace view public.vmodules_dependencies_with_interfaces
as
select ip.interface_id      provided_interface_id,
       ip.interface_version provided_interface_version,
       ip.module_id         module_provider,
       ip.module_name       module_provider_name,
       ir.interface_id      requested_interface_id,
       ir.interface_version requested_interface_version,
       ir.module_id         module_requestor,
       ir.module_name       module_requestor_name
from public.vinterface_provided ip
         right outer join public.vinterface_required ir on (ip.interface_id = ir.interface_id);

create or replace view public.vmodules_dependencies
as
select distinct md.module_provider, md.module_provider_name, md.module_requestor, md.module_requestor_name
from public.vmodules_dependencies_with_interfaces md;

create or replace view public.vmodules_hierarchy
as
with recursive modules_hierarchy(module_provider, module_provider_name, module_requestor, module_requestor_name, depth) as (
    select module_provider, module_provider_name, module_requestor, module_requestor_name, 1
    from public.vmodules_dependencies md
    where md.module_provider is null
    union all
    select mdd.module_provider, mdd.module_provider_name, mdd.module_requestor, mdd.module_requestor_name, mh.depth + 1
    from public.vmodules_dependencies mdd
             inner join modules_hierarchy mh on (mdd.module_provider = mh.module_requestor)
)
select module_provider,
       module_provider_name,
       module_requestor,
       module_requestor_name,
       depth,
       max(depth) over (partition by module_requestor)      max_depth,
       row_number() over (order by depth, module_requestor) row_order
from modules_hierarchy;

