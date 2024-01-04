-------------------------------------------------------
--     Duplicate WGS 84 realizations to ITRS realizations with NSGI authority
-------------------------------------------------------
create temp table nsgi_wgs_84_to_itrs as
select * from helmert_transformation_table where name like 'WGS 84 (G%) to ITRF% (1)';
UPDATE nsgi_wgs_84_to_itrs SET auth_name='NSGI';
INSERT INTO helmert_transformation_table SELECT * FROM nsgi_wgs_84_to_itrs;

create temp table nsgi_wgs_84_to_itrs_usage as
SELECT *
from usage
WHERE object_auth_name IN (
    SELECT auth_name
    FROM helmert_transformation_table
    where name like 'WGS 84 (G%) to ITRF% (1)' and auth_name <> 'NSGI'
)
AND
object_code IN (
    SELECT code
    FROM helmert_transformation_table
    where name like 'WGS 84 (G%) to ITRF% (1)' and auth_name <> 'NSGI'
);
UPDATE nsgi_wgs_84_to_itrs_usage SET auth_name='NSGI';
UPDATE nsgi_wgs_84_to_itrs_usage SET object_auth_name='NSGI';
UPDATE nsgi_wgs_84_to_itrs_usage SET code=object_code || '_USAGE';
INSERT INTO usage SELECT * FROM nsgi_wgs_84_to_itrs_usage;

-------------------------------------------------------
--     Duplicate ITRS realizations to ITRS realizations with NSGI authority
-------------------------------------------------------
create temp table nsgi_itrs_to_itrs as
select * from helmert_transformation_table where name like '%TRF% to %TRF% (1)' and deprecated = '0';
UPDATE nsgi_itrs_to_itrs SET auth_name='NSGI';
INSERT INTO helmert_transformation_table SELECT * FROM nsgi_itrs_to_itrs;

create temp table nsgi_itrs_to_itrs_usage as
SELECT *
from usage
WHERE object_auth_name IN (
    SELECT auth_name
    FROM helmert_transformation_table
    where name like '%TRF% to %TRF% (1)' and auth_name <> 'NSGI' and deprecated = '0'
)
AND
object_code IN (
    SELECT code
    FROM helmert_transformation_table
    where name like '%TRF% to %TRF% (1)' and auth_name <> 'NSGI' and deprecated = '0'
)
AND
object_table_name = 'helmert_transformation';
UPDATE nsgi_itrs_to_itrs_usage SET auth_name='NSGI';
UPDATE nsgi_itrs_to_itrs_usage SET object_auth_name='NSGI';
UPDATE nsgi_itrs_to_itrs_usage SET code=object_code || '_USAGE';
INSERT INTO usage SELECT * FROM nsgi_itrs_to_itrs_usage;

-------------------------------------------------------
--     Duplicate WGS 84 realizations to WGS 84 realizations with NSGI authority
-------------------------------------------------------
create temp table nsgi_wgs_84s_to_wgs_84 as
select * from helmert_transformation_table where name like 'WGS 84 (G%) to WGS 84 (G%) (1)' and deprecated = '0';
UPDATE nsgi_wgs_84s_to_wgs_84 SET auth_name='NSGI';
INSERT INTO helmert_transformation_table SELECT * FROM nsgi_wgs_84s_to_wgs_84;

create temp table nsgi_wgs_84s_to_wgs_84_usage as
SELECT *
from usage
WHERE object_auth_name IN (
    SELECT auth_name
    FROM helmert_transformation_table
    where name like 'WGS 84 (G%) to WGS 84 (G%) (1)' and auth_name <> 'NSGI' and deprecated = '0'
)
AND
object_code IN (
    SELECT code
    FROM helmert_transformation_table
    where name like 'WGS 84 (G%) to WGS 84 (G%) (1)' and auth_name <> 'NSGI' and deprecated = '0'
)
AND
object_table_name = 'helmert_transformation';
UPDATE nsgi_wgs_84s_to_wgs_84_usage SET auth_name='NSGI';
UPDATE nsgi_wgs_84s_to_wgs_84_usage SET object_auth_name='NSGI';
UPDATE nsgi_wgs_84s_to_wgs_84_usage SET code=object_code || '_USAGE';
INSERT INTO usage SELECT * FROM nsgi_wgs_84s_to_wgs_84_usage;




-------------------------------------------------------
--     Duplicate ETRS9 ensemble to ETRS89 realizations with NSGI authority
-------------------------------------------------------
create temp table nsgi_etrs89_to_etrf as
select * from helmert_transformation_table where name like 'ETRS89 to ETRF%' and name not like 'ETRS89 to ETRF2000';
UPDATE nsgi_etrs89_to_etrf SET auth_name='NSGI';
INSERT INTO helmert_transformation_table SELECT * FROM nsgi_etrs89_to_etrf;

create temp table nsgi_etrs89_to_etrf_usage as
SELECT *
from usage
WHERE object_auth_name IN (
    SELECT auth_name
    FROM helmert_transformation_table
    where name like 'ETRS89 to ETRF%' and name not like 'ETRS89 to ETRF2000' and auth_name <> 'NSGI'
)
AND
object_code IN (
    SELECT code
    FROM helmert_transformation_table
    where name like 'ETRS89 to ETRF%' and name not like 'ETRS89 to ETRF2000' and auth_name <> 'NSGI'
);
UPDATE nsgi_etrs89_to_etrf_usage SET auth_name='NSGI';
UPDATE nsgi_etrs89_to_etrf_usage SET object_auth_name='NSGI';
UPDATE nsgi_etrs89_to_etrf_usage SET code=object_code || '_USAGE';
INSERT INTO usage SELECT * FROM nsgi_etrs89_to_etrf_usage;

-------------------------------------------------------
--     Append NSGI to authority references
-------------------------------------------------------
UPDATE authority_to_authority_preference
SET
    allowed_authorities = 'NSGI,PROJ';
