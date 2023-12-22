-------------------------------------------------------
--     Append NSGI to authority references
-------------------------------------------------------
UPDATE authority_to_authority_preference
SET
    allowed_authorities = 'NSGI,' || allowed_authorities
WHERE
    source_auth_name = 'EPSG'
    AND target_auth_name = 'EPSG';

INSERT INTO
    "authority_to_authority_preference" (
        source_auth_name,
        target_auth_name,
        allowed_authorities
    )
VALUES
    ('NSGI', 'EPSG', 'NSGI,PROJ,EPSG');

-------------------------------------------------------
--     Remove ESRI from authority references
-------------------------------------------------------
UPDATE
    authority_to_authority_preference
SET
    allowed_authorities = REPLACE(allowed_authorities,',ESRI','')
WHERE
    source_auth_name = 'EPSG'
    AND target_auth_name = 'EPSG';

DELETE FROM
    authority_to_authority_preference
WHERE
    source_auth_name = 'ESRI';
-------------------------------------------------------
--     Add extents of NSGI transformations
-------------------------------------------------------
INSERT INTO
    "extent" (
        auth_name,
        code,
        name,
        description,
        south_lat,
        north_lat,
        west_lon,
        east_lon,
        deprecated
    )
VALUES
    (
        'NSGI',
        'EXTENT_3D_RDNAPTRANS2018',
        'Extent for 3D RDNAPTRANS2018',
        'Extent limited by extent of NLGEO2018 grid',
        50,
        56,
        2,
        8,
        0
    );

-------------------------------------------------------
--     Deprecate all existing transformations related 
--     to RD Bessel (aka Amersfoort)
-------------------------------------------------------
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
--     Add additonal NL datum (AGRS.NL)
-------------------------------------------------------
INSERT INTO
    "geodetic_datum" (
        auth_name,
        code,
        name,
        description,
        ellipsoid_auth_name,
        ellipsoid_code,
        prime_meridian_auth_name,
        prime_meridian_code,
        publication_date,
        frame_reference_epoch,
        ensemble_accuracy,
        anchor,
        deprecated
    )
VALUES
    (
        'NSGI',
        'AGRS.NL',
        'Active GNSS Reference Sytem for the Netherlands',
        NULL,
        'EPSG',
        '7019',
        'EPSG',
        '8901',
        '1997-01-01',
        NULL,
        NULL,
        NULL,
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
        'AGRS.NL_USAGE',
        'geodetic_datum',
        'NSGI',
        'AGRS.NL',
        'EPSG',
        '1298',
        'EPSG',
        '1027'
    );

-------------------------------------------------------
--     Add additonal NL crss 
--     (pseudo RD Bessel, AGRS2010)
-------------------------------------------------------
INSERT INTO
    "geodetic_crs" (
        auth_name,
        code,
        name,
        description,
        type,
        coordinate_system_auth_name,
        coordinate_system_code,
        datum_auth_name,
        datum_code,
        text_definition,
        deprecated
    )
VALUES
    (
        'NSGI',
        'PSEUDO_RD_BESSEL',
        'pseudo RD Bessel',
        NULL,
        'geographic 2D',
        'EPSG',
        '6422',
        'EPSG',
        '6289',
        NULL,
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
        'PSEUDO_RD_BESSEL_USAGE',
        'geodetic_crs',
        'NSGI',
        'PSEUDO_RD_BESSEL',
        'EPSG',
        '1262',
        'EPSG',
        '1269'
    );

INSERT INTO
    "geodetic_crs" (
        auth_name,
        code,
        name,
        description,
        type,
        coordinate_system_auth_name,
        coordinate_system_code,
        datum_auth_name,
        datum_code,
        text_definition,
        deprecated
    )
VALUES
    (
        'NSGI',
        'AGRS2010_GEOCENTRIC',
        'AGRS2010',
        NULL,
        'geocentric',
        'EPSG',
        '6500',
        'NSGI',
        'AGRS.NL',
        NULL,
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
        'AGRS2010_GEOCENTRIC_USAGE',
        'geodetic_crs',
        'NSGI',
        'AGRS2010_GEOCENTRIC',
        'EPSG',
        '1298',
        'EPSG',
        '1027'
    );

INSERT INTO
    "geodetic_crs" (
        auth_name,
        code,
        name,
        description,
        type,
        coordinate_system_auth_name,
        coordinate_system_code,
        datum_auth_name,
        datum_code,
        text_definition,
        deprecated
    )
VALUES
    (
        'NSGI',
        'AGRS2010_GEOGRAPHIC_3D',
        'AGRS2010',
        NULL,
        'geographic 3D',
        'EPSG',
        '6423',
        'NSGI',
        'AGRS.NL',
        NULL,
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
        'AGRS2010_GEOGRAPHIC_3D_USAGE',
        'geodetic_crs',
        'NSGI',
        'AGRS2010_GEOGRAPHIC_3D',
        'EPSG',
        '1298',
        'EPSG',
        '1027'
    );

INSERT INTO
    "geodetic_crs" (
        auth_name,
        code,
        name,
        description,
        type,
        coordinate_system_auth_name,
        coordinate_system_code,
        datum_auth_name,
        datum_code,
        text_definition,
        deprecated
    )
VALUES
    (
        'NSGI',
        'AGRS2010_GEOGRAPHIC_2D',
        'AGRS2010',
        NULL,
        'geographic 2D',
        'EPSG',
        '6422',
        'NSGI',
        'AGRS.NL',
        NULL,
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
        'AGRS2010_GEOGRAPHIC_2D_USAGE',
        'geodetic_crs',
        'NSGI',
        'AGRS2010_GEOGRAPHIC_2D',
        'EPSG',
        '1298',
        'EPSG',
        '1027'
    );

-------------------------------------------------------
--     Transformation: ETRF2000 --> AGRS2010
-------------------------------------------------------
INSERT INTO
    "helmert_transformation" (
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
        tx,
        ty,
        tz,
        translation_uom_auth_name,
        translation_uom_code,
        rx,
        ry,
        rz,
        rotation_uom_auth_name,
        rotation_uom_code,
        scale_difference,
        scale_difference_uom_auth_name,
        scale_difference_uom_code,
        rate_tx,
        rate_ty,
        rate_tz,
        rate_translation_uom_auth_name,
        rate_translation_uom_code,
        rate_rx,
        rate_ry,
        rate_rz,
        rate_rotation_uom_auth_name,
        rate_rotation_uom_code,
        rate_scale_difference,
        rate_scale_difference_uom_auth_name,
        rate_scale_difference_uom_code,
        epoch,
        epoch_uom_auth_name,
        epoch_uom_code,
        px,
        py,
        pz,
        pivot_uom_auth_name,
        pivot_uom_code,
        operation_version,
        deprecated
    )
VALUES
    (
        'NSGI',
        'ETRF2000_TO_AGRS2010',
        'ETRF2000 to AGRS2010 NULL transformation',
        'null transformation between ETRF2010 and AGRS2010 ',
        'EPSG',
        '9603',
        'Geocentric translations (geog2D domain)',
        'EPSG',
        '9067',
        'NSGI',
        'AGRS2010_GEOGRAPHIC_2D',
        0.000,
        0.0,
        0.0,
        0.0,
        'EPSG',
        '9001',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        '',
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
        'ETRF2000_TO_AGRS2010_USAGE',
        'helmert_transformation',
        'NSGI',
        'ETRF2000_TO_AGRS2010',
        'EPSG',
        '1262',
        'EPSG',
        '1027'
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

-------------------------------------------------------
--     Transformation (concatenated): 
--     RD Bessel --> 2D ETRF2000
-------------------------------------------------------
INSERT INTO
    "concatenated_operation" (
        auth_name,
        code,
        name,
        description,
        source_crs_auth_name,
        source_crs_code,
        target_crs_auth_name,
        target_crs_code,
        accuracy,
        operation_version,
        deprecated
    )
VALUES
    (
        'NSGI',
        'RD_BESSEL_TO_ETRF2000_VARIANT_1',
        'Rd Bessel to ETRF2000',
        'Transformation based on RDNAPTRANS2018 documentation',
        'EPSG',
        '4289',
        'EPSG',
        '9067',
        0.001,
        'NSGI 2019',
        0
    );

INSERT INTO
    "concatenated_operation_step" (
        operation_auth_name,
        operation_code,
        step_number,
        step_auth_name,
        step_code
    )
VALUES
    (
        'NSGI',
        'RD_BESSEL_TO_ETRF2000_VARIANT_1',
        3,
        'NSGI',
        'ETRF2000_TO_AGRS2010'
    ),
    (
        'NSGI',
        'RD_BESSEL_TO_ETRF2000_VARIANT_1',
        2,
        'NSGI',
        'AGRS2010_TO_PSEUDO_RD_BESSEL_VARIANT_1'
    ),
    (
        'NSGI',
        'RD_BESSEL_TO_ETRF2000_VARIANT_1',
        1,
        'NSGI',
        'RD_BESSEL_TO_PSEUDO_RD_BESSEL'
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
        'RD_BESSEL_TO_ETRF2000_VARIANT_1_USAGE',
        'concatenated_operation',
        'NSGI',
        'RD_BESSEL_TO_ETRF2000_VARIANT_1',
        'EPSG',
        '1262',
        'EPSG',
        '1181'
    );

-------------------------------------------------------
--     Transformation: ITRF2014 -> WGS 84
-------------------------------------------------------
INSERT INTO
    "helmert_transformation" (
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
        tx,
        ty,
        tz,
        translation_uom_auth_name,
        translation_uom_code,
        rx,
        ry,
        rz,
        rotation_uom_auth_name,
        rotation_uom_code,
        scale_difference,
        scale_difference_uom_auth_name,
        scale_difference_uom_code,
        rate_tx,
        rate_ty,
        rate_tz,
        rate_translation_uom_auth_name,
        rate_translation_uom_code,
        rate_rx,
        rate_ry,
        rate_rz,
        rate_rotation_uom_auth_name,
        rate_rotation_uom_code,
        rate_scale_difference,
        rate_scale_difference_uom_auth_name,
        rate_scale_difference_uom_code,
        epoch,
        epoch_uom_auth_name,
        epoch_uom_code,
        px,
        py,
        pz,
        pivot_uom_auth_name,
        pivot_uom_code,
        operation_version,
        deprecated
    )
VALUES
    (
        'NSGI',
        'ITRF2014_TO_WGS_84_NULL',
        'ITRF2014 to WGS 84 NULL transformation',
        'null transformation between ITRF2014 and WGS 84 ',
        'EPSG',
        '1053',
        'Time-dependent Position Vector tfm (geocentric)',
        'EPSG',
        '9000',
        'EPSG',
        '4326',
        0.0,
        0.0,
        0.0,
        0.0,
        'EPSG',
        '1025',
        0.0,
        0.0,
        0.0,
        'EPSG',
        '1031',
        0.0,
        'EPSG',
        '1028',
        0.0,
        0.0,
        0.0,
        'EPSG',
        '1027',
        0.0,
        0.0,
        0.0,
        'EPSG',
        '1032',
        0.0,
        'EPSG',
        '1030',
        2021.0,
        'EPSG',
        '1029',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        '',
        0
    );

-------------------------------------------------------
--     Transformation: ETRF2000 -> WGS 84
-------------------------------------------------------
INSERT INTO
    "helmert_transformation" (
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
        tx,
        ty,
        tz,
        translation_uom_auth_name,
        translation_uom_code,
        rx,
        ry,
        rz,
        rotation_uom_auth_name,
        rotation_uom_code,
        scale_difference,
        scale_difference_uom_auth_name,
        scale_difference_uom_code,
        rate_tx,
        rate_ty,
        rate_tz,
        rate_translation_uom_auth_name,
        rate_translation_uom_code,
        rate_rx,
        rate_ry,
        rate_rz,
        rate_rotation_uom_auth_name,
        rate_rotation_uom_code,
        rate_scale_difference,
        rate_scale_difference_uom_auth_name,
        rate_scale_difference_uom_code,
        epoch,
        epoch_uom_auth_name,
        epoch_uom_code,
        px,
        py,
        pz,
        pivot_uom_auth_name,
        pivot_uom_code,
        operation_version,
        deprecated
    )
VALUES
    (
        'NSGI',
        'ETRF2000_TO_WGS_84_NULL',
        'ETRF2000 to WGS 84 NULL transformation',
        'null transformation between ETRF2010 and WGS 84 ',
        'EPSG',
        '9603',
        'Geocentric translations (geog2D domain)',
        'EPSG',
        '9067',
        'EPSG',
        '4326',
        2.0,
        0.0,
        0.0,
        0.0,
        'EPSG',
        '9001',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        '',
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
        'ETRF2000_TO_WGS_84_NULL_USAGE',
        'helmert_transformation',
        'NSGI',
        'ETRF2000_TO_WGS_84_NULL',
        'EPSG',
        '1262',
        'EPSG',
        '1027'
    );

-------------------------------------------------------
--     Transformation: RD Bessel --> 2D ITRF2014 
--     Added to shorten the transformation routes 
--     between NL projected and WGS 84 ensenmble
-------------------------------------------------------
INSERT INTO
    "concatenated_operation" (
        auth_name,
        code,
        name,
        description,
        source_crs_auth_name,
        source_crs_code,
        target_crs_auth_name,
        target_crs_code,
        accuracy,
        operation_version,
        deprecated
    )
VALUES
    (
        'NSGI',
        'RD_BESSEL_TO_ITRF2014',
        'RD Bessel to ITRF2014 via ETRF2000',
        'Transformation based on RDNAPTRANS2018 documentation',
        'EPSG',
        '4289',
        'EPSG',
        '9000',
        0.001,
        'NSGI 2019',
        0
    );

INSERT INTO
    "concatenated_operation_step" (
        operation_auth_name,
        operation_code,
        step_number,
        step_auth_name,
        step_code
    )
VALUES
    (
        'NSGI',
        'RD_BESSEL_TO_ITRF2014',
        1,
        'NSGI',
        'RD_BESSEL_TO_PSEUDO_RD_BESSEL'
    ),
    (
        'NSGI',
        'RD_BESSEL_TO_ITRF2014',
        2,
        'NSGI',
        'AGRS2010_TO_PSEUDO_RD_BESSEL_VARIANT_1'
    ),
    (
        'NSGI',
        'RD_BESSEL_TO_ITRF2014',
        3,
        'NSGI',
        'ETRF2000_TO_AGRS2010'
    ),
    (
        'NSGI',
        'RD_BESSEL_TO_ITRF2014',
        4,
        'EPSG',
        '8405'
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
        'RD_BESSEL_TO_ITRF2014_USAGE',
        'concatenated_operation',
        'NSGI',
        'RD_BESSEL_TO_ITRF2014',
        'EPSG',
        '1262',
        'EPSG',
        '1181'
    );

-------------------------------------------------------
--     Transformation: AGRS2010 --> 2D ITRF2014 
--     Added to shorten the transformation routes
--     between NL projected and WGS 84 ensenmble for 3D
-------------------------------------------------------
INSERT INTO
    "concatenated_operation" (
        auth_name,
        code,
        name,
        description,
        source_crs_auth_name,
        source_crs_code,
        target_crs_auth_name,
        target_crs_code,
        accuracy,
        operation_version,
        deprecated
    )
VALUES
    (
        'NSGI',
        'AGRS2010_TO_ITRF2014',
        'AGRS2010 to ITRF2014 via ETRF2000',
        'Transformation based on RDNAPTRANS2018 documentation',
        'NSGI',
        'AGRS2010_GEOGRAPHIC_2D',
        'EPSG',
        '9000',
        0.001,
        'NSGI 2019',
        0
    );

INSERT INTO
    "concatenated_operation_step" (
        operation_auth_name,
        operation_code,
        step_number,
        step_auth_name,
        step_code
    )
VALUES
    (
        'NSGI',
        'AGRS2010_TO_ITRF2014',
        1,
        'NSGI',
        'ETRF2000_TO_AGRS2010'
    ),
    ('NSGI', 'AGRS2010_TO_ITRF2014', 2, 'EPSG', '8405');

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
        'AGRS2010_TO_ITRF2014_USAGE',
        'concatenated_operation',
        'NSGI',
        'AGRS2010_TO_ITRF2014',
        'EPSG',
        '1262',
        'EPSG',
        '1181'
    );

-------------------------------------------------------
--     Transformation: ETRS89_TO_ETRF2000
--     Added to give preference to ETRS89_TO_ETRF2000
-------------------------------------------------------
INSERT INTO
    "helmert_transformation" (
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
        tx,
        ty,
        tz,
        translation_uom_auth_name,
        translation_uom_code,
        rx,
        ry,
        rz,
        rotation_uom_auth_name,
        rotation_uom_code,
        scale_difference,
        scale_difference_uom_auth_name,
        scale_difference_uom_code,
        rate_tx,
        rate_ty,
        rate_tz,
        rate_translation_uom_auth_name,
        rate_translation_uom_code,
        rate_rx,
        rate_ry,
        rate_rz,
        rate_rotation_uom_auth_name,
        rate_rotation_uom_code,
        rate_scale_difference,
        rate_scale_difference_uom_auth_name,
        rate_scale_difference_uom_code,
        epoch,
        epoch_uom_auth_name,
        epoch_uom_code,
        px,
        py,
        pz,
        pivot_uom_auth_name,
        pivot_uom_code,
        operation_version,
        deprecated
    )
VALUES
    (
        'NSGI',
        'ETRS89_TO_ETRF2000',
        'ETRS89 to ETRF2000',
        'Accuracy 0.999 m, from datum ensemble definition',
        'EPSG',
        '9603',
        'Geocentric translations (geog2D domain)',
        'EPSG',
        '4258',
        'EPSG',
        '9067',
        0.099,
        0.0,
        0.0,
        0.0,
        'EPSG',
        '9001',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        '',
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
        'ETRS89_TO_ETRF2000_USAGE',
        'helmert_transformation',
        'NSGI',
        'ETRS89_TO_ETRF2000',
        'EPSG',
        '1298',
        'EPSG',
        '1024'
    );
