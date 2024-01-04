-------------------------------------------------------
--     Deprecate all existing transformations related 
--     to RD Bessel (aka Amersfoort)
-------------------------------------------------------



--- First vreate table so that we can rollback this later
create temp table nsgi_nl_helmert_transformation_table_deprecated as
SELECT auth_name,code
from helmert_transformation_table
WHERE
    (
        source_crs_auth_name = 'EPSG'
        and source_crs_code = '4289'
    )
    OR (
        target_crs_auth_name = 'EPSG'
        and target_crs_code = '4289'
    )
	AND deprecated = '0'
;
alter table nsgi_nl_helmert_transformation_table_deprecated add column transformation_table TEXT DEFAULT 'helmert_transformation_table';

create temp table nsgi_nl_grid_transformation_deprecated as
SELECT auth_name,code
from grid_transformation
WHERE
    (
        source_crs_auth_name = 'EPSG'
        and source_crs_code = '4289'
    )
    OR (
        target_crs_auth_name = 'EPSG'
        and target_crs_code = '4289'
    )
	AND deprecated = '0'
;
alter table nsgi_nl_grid_transformation_deprecated add column transformation_table TEXT DEFAULT 'grid_transformation';

create temp table nsgi_nl_other_transformation_deprecated as
SELECT auth_name,code
from other_transformation
WHERE
    (
        source_crs_auth_name = 'EPSG'
        and source_crs_code = '4289'
    )
    OR (
        target_crs_auth_name = 'EPSG'
        and target_crs_code = '4289'
    )
	AND deprecated = '0'
;
alter table nsgi_nl_other_transformation_deprecated add column transformation_table TEXT DEFAULT 'other_transformation';


create table nsgi_nl_deprecated_by as SELECT * from nsgi_nl_helmert_transformation_table_deprecated;
INSERT INTO  nsgi_nl_deprecated_by  SELECT * FROM nsgi_nl_grid_transformation_deprecated;
INSERT INTO  nsgi_nl_deprecated_by  SELECT * FROM nsgi_nl_other_transformation_deprecated;

--- actual deprecation
UPDATE helmert_transformation_table
SET
    deprecated = 1
WHERE
    (
        source_crs_auth_name = 'EPSG'
        and source_crs_code = '4289'
    )
    OR (
        target_crs_auth_name = 'EPSG'
        and target_crs_code = '4289'
    );

UPDATE grid_transformation
SET
    deprecated = 1
WHERE
    (
        source_crs_auth_name = 'EPSG'
        and source_crs_code = '4289'
    )
    OR (
        target_crs_auth_name = 'EPSG'
        and target_crs_code = '4289'
    );

UPDATE concatenated_operation
SET
    deprecated = 1
WHERE
    (
        source_crs_auth_name = 'EPSG'
        and source_crs_code = '4289'
    )
    OR (
        target_crs_auth_name = 'EPSG'
        and target_crs_code = '4289'
    );

-------------------------------------------------------
--     Transformation: AGRS2010 -> NAP height
-------------------------------------------------------
INSERT INTO
    "grid_transformation" (
        auth_name,
        code,
        name,
        description,
        method_auth_name,
        method_code,
        method_name,
        source_crs_auth_name,
        source_crs_code,
        target_crs_auth_name,
        target_crs_code,
        accuracy,
        grid_param_auth_name,
        grid_param_code,
        grid_param_name,
        grid_name,
        grid2_param_auth_name,
        grid2_param_code,
        grid2_param_name,
        grid2_name,
        interpolation_crs_auth_name,
        interpolation_crs_code,
        operation_version,
        deprecated
    )
VALUES
    (
        'NSGI',
        'AGRS2010_TO_NAP',
        'AGRS2010 to NAP height',
        'Transformation based on RDNAPTRANS2018 documentation',
        'EPSG',
        '9665',
        'Geographic3D to GravityRelatedHeight (gtx)',
        'NSGI',
        'AGRS2010_GEOGRAPHIC_3D',
        'EPSG',
        '5709',
        0.001,
        'EPSG',
        '8666',
        'Geoid (height correction) model file',
        'nlgeo2018.gtx',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        'NSGI-Nld 2018',
        0
    );

INSERT INTO
    "usage" (
        auth_name,
        code,
        object_table_name,
        object_auth_name,
        object_code,
        extent_auth_name,
        extent_code,
        scope_auth_name,
        scope_code
    )
VALUES
    (
        'NSGI',
        'AGRS2010_TO_NAP_USAGE',
        'grid_transformation',
        'NSGI',
        'AGRS2010_TO_NAP',
        'NSGI',
        'EXTENT_3D_RDNAPTRANS2018',
        'EPSG',
        '1133'
    );

-------------------------------------------------------
--     Transformation: RD Bessel -> pseudo RD Bessel
-------------------------------------------------------
INSERT INTO
    "grid_transformation" (
        auth_name,
        code,
        name,
        description,
        method_auth_name,
        method_code,
        method_name,
        source_crs_auth_name,
        source_crs_code,
        target_crs_auth_name,
        target_crs_code,
        accuracy,
        grid_param_auth_name,
        grid_param_code,
        grid_param_name,
        grid_name,
        grid2_param_auth_name,
        grid2_param_code,
        grid2_param_name,
        grid2_name,
        interpolation_crs_auth_name,
        interpolation_crs_code,
        operation_version,
        deprecated
    )
VALUES
    (
        'NSGI',
        'RD_BESSEL_TO_PSEUDO_RD_BESSEL',
        'RD Bessel to pseudo RD Bessel grid shift',
        'Transformation based on RDNAPTRANS2018 documentation',
        'EPSG',
        '9615',
        'NTv2',
        'EPSG',
        '4289',
        'NSGI',
        'PSEUDO_RD_BESSEL',
        0.001,
        'EPSG',
        '8656',
        'Latitude and longitude difference file',
        'nl_nsgi_rdcorr2018.tif,null',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        'NSGI-Nld 2018',
        0
    );

INSERT INTO
    "usage" (
        auth_name,
        code,
        object_table_name,
        object_auth_name,
        object_code,
        extent_auth_name,
        extent_code,
        scope_auth_name,
        scope_code
    )
VALUES
    (
        'NSGI',
        'RD_BESSEL_TO_PSEUDO_RD_BESSEL_USAGE',
        'grid_transformation',
        'NSGI',
        'RD_BESSEL_TO_PSEUDO_RD_BESSEL',
        'EPSG',
        '1262',
        'EPSG',
        '1051'
    );

-------------------------------------------------------
--     Transformation: AGRS2010 -> pseudo RD Bessel
-------------------------------------------------------
INSERT INTO
    "other_transformation" (
        auth_name,
        code,
        name,
        description,
        method_auth_name,
        method_code,
        method_name,
        source_crs_auth_name,
        source_crs_code,
        target_crs_auth_name,
        target_crs_code,
        accuracy,
        deprecated
    )
VALUES
    (
        'NSGI',
        'AGRS2010_TO_PSEUDO_RD_BESSEL_VARIANT_1',
        'AGRS2010 to pseudo RD Bessel variant 1',
        'Transformation based on RDNAPTRANS2018 documentation',
        'PROJ',
        'PROJString',
        '+proj=pipeline +step +proj=axisswap +order=2,1 +step +proj=unitconvert +xy_in=deg +xy_out=rad +step +proj=push +v_3 +step +proj=set +v_3=43 +omit_inv +step +proj=cart +ellps=GRS80 +step +proj=helmert +x=-565.7346 +y=-50.4058 +z=-465.2895 +rx=-0.395023 +ry=0.330776 +rz=-1.876073 +s=-4.07242 +convention=coordinate_frame +exact +step +proj=cart +inv +ellps=bessel +step +proj=set +v_3=0 +omit_fwd +step +proj=pop +v_3 +step +proj=unitconvert +xy_in=rad +xy_out=deg +step +proj=axisswap +order=2,1',
        'NSGI',
        'AGRS2010_GEOGRAPHIC_2D',
        'NSGI',
        'PSEUDO_RD_BESSEL',
        0.001,
        0
    );

INSERT INTO
    "usage" (
        auth_name,
        code,
        object_table_name,
        object_auth_name,
        object_code,
        extent_auth_name,
        extent_code,
        scope_auth_name,
        scope_code
    )
VALUES
    (
        'NSGI',
        'AGRS2010_TO_PSEUDO_RD_BESSEL_VARIANT_1_USAGE',
        'other_transformation',
        'NSGI',
        'AGRS2010_TO_PSEUDO_RD_BESSEL_VARIANT_1',
        'NSGI',
        'EXTENT_3D_RDNAPTRANS2018',
        'EPSG',
        '1181'
    );

