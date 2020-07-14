#!/bin/sh
echo Started at : $(date)
echo Preparing Databse
export PGPASSWORD=$DB_PASSWORD

psql -h $DB_HOST -d $DB_DATABASE -U $DB_USERNAME -a -q -f ./create_views.sql
echo Views have been created
psql -h $DB_HOST -d $DB_DATABASE -U $DB_USERNAME -c "COPY (select module_requestor from (select module_requestor, row_number() over (order by depth, module_requestor) row_order from (select distinct depth, module_requestor from public.vmodules_hierarchy where ($SQL_WHERE) and max_depth = depth) x) y order by row_order) TO STDOUT" > /tmp/modules_ordered.txt

echo List of modules has been created

cat /tmp/modules_ordered.txt

cat /tmp/modules_ordered.txt | while read id ; do
  export MODULE_ID=${id}
  ./create-deploy.sh
done

echo Completed at : $(date)
