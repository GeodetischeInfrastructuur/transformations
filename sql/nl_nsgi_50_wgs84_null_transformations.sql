-------------------------------------------------------
--     Add additonal NSGI WGS 84 version 
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
        'WGS84_GEOGRAPHIC_2D',
        'WGS 84',
        NULL,
        'geographic 2D',
        'EPSG',
        '6422',
        'EPSG',
        '6326',
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
        'WGS84_GEOGRAPHIC_2D_USAGE',
        'geodetic_crs',
        'NSGI',
        'WGS84_GEOGRAPHIC_2D',
        'EPSG',
        '1298',
        'EPSG',
        '1027'
    );

-------------------------------------------------------
--     Transformation: WGS 84 -> ETRF2000 NULL
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
        'WGS_84_TO_ETRF2000_NULL',
        'WGS 84 to ETRF2000 NULL transformation',
        'null transformation between ITRF2000 and ETRF2000',
        'EPSG',
        '9603',
        'Geocentric translations (geog2D domain)',
        'NSGI',
        'WGS84_GEOGRAPHIC_2D',
        'EPSG',
        '9067',
        2.5,
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
        'WGS_84_TO_ETRF2000_NULL_USAGE',
        'helmert_transformation',
        'NSGI',
        'WGS_84_TO_ETRF2000_NULL',
        'EPSG',
        '1262',
        'EPSG',
        '1027'
    );


-------------------------------------------------------
--     Transformation: WGS 84 -> NSGI WGS 84 NULL
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
        'NSGI_WGS_84_TO_WGS_84_NULL',
        'NSGI_WGS 84 to WGS_84 NULL transformation',
        'null transformation between NSGI_WGS 84 and WGS_84',
        'EPSG',
        '9603',
        'Geocentric translations (geog2D domain)',
        'NSGI',
        'WGS84_GEOGRAPHIC_2D',
        'EPSG',
        '4326',
        0.0,
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
        'NSGI_WGS_84_TO_WGS_84_NULL_USAGE',
        'helmert_transformation',
        'NSGI',
        'NSGI_WGS_84_TO_WGS_84_NULL',
        'EPSG',
        '1262',
        'EPSG',
        '1027'
    );


-------------------------------------------------------
--     Transformation (concatenated): 
--     ETRS89 -> WGS 84 NULL
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
        'ETRS89_TO_WGS84_NULL',
        'ETRS89 to WGS 84 null transformation',
        '',
        'EPSG',
        '4258',
        'NSGI',
        'WGS84_GEOGRAPHIC_2D',
        2.5,
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
        'ETRS89_TO_WGS84_NULL',
        1,
        'NSGI',
        'ETRS89_TO_ETRF2000_preferred'
    ),
    (
        'NSGI',
        'ETRS89_TO_WGS84_NULL',
        2,
        'NSGI',
        'WGS_84_TO_ETRF2000_NULL'
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
        'ETRS89_TO_WGS84_NULL_USAGE',
        'concatenated_operation',
        'NSGI',
        'ETRS89_TO_WGS84_NULL',
        'EPSG',
        '1262',
        'EPSG',
        '1181'
    );


-------------------------------------------------------
--     Transformation: ITRF2014 -> WGS 84 NULL
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
        0.1,
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
        'ITRF2014_TO_WGS_84_NULL_USAGE',
        'helmert_transformation',
        'NSGI',
        'ITRF2014_TO_WGS_84_NULL',
        'EPSG',
        '1262',
        'EPSG',
        '1027'
    );

-------------------------------------------------------
--     Transformation: AGRS2010 --> 2D WGS 84 NULL 
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
        'AGRS2010_TO_WGS84_NULL',
        'AGRS2010 to WGS84 via ETRF2000 null transformation',
        'Transformation based on RDNAPTRANS2018 documentation',
        'NSGI',
        'AGRS2010_GEOGRAPHIC_2D',
        'NSGI',
        'WGS84_GEOGRAPHIC_2D',
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
        'AGRS2010_TO_WGS84_NULL',
        1,
        'NSGI',
        'AGRS2010_TO_ETRF2000'
    ),
    ('NSGI', 'AGRS2010_TO_WGS84_NULL', 2, 'NSGI', 'WGS_84_TO_ETRF2000_NULL');

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
        'AGRS2010_TO_WGS84_NULL_USAGE',
        'concatenated_operation',
        'NSGI',
        'AGRS2010_TO_WGS84_NULL',
        'EPSG',
        '1262',
        'EPSG',
        '1181'
    );

-------------------------------------------------------
--     Transformation: RD Bessel --> 2D WGS 84 
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
        'RD_BESSEL_TO_WGS84_NULL',
        'RD Bessel to WGS 84 via ETRF2000 null transformation',
        'Transformation based on RDNAPTRANS2018 documentation',
        'EPSG',
        '4289',
        'NSGI',
        'WGS84_GEOGRAPHIC_2D',
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
        'RD_BESSEL_TO_WGS84_NULL',
        1,
        'NSGI',
        'RD_BESSEL_TO_PSEUDO_RD_BESSEL'
    ),
    (
        'NSGI',
        'RD_BESSEL_TO_WGS84_NULL',
        2,
        'NSGI',
        'AGRS2010_TO_PSEUDO_RD_BESSEL_VARIANT_1'
    ),
    (
        'NSGI',
        'RD_BESSEL_TO_WGS84_NULL',
        3,
        'NSGI',
        'AGRS2010_TO_ETRF2000'
    ),
    (
        'NSGI',
        'RD_BESSEL_TO_WGS84_NULL',
        4,
        'NSGI', 'WGS_84_TO_ETRF2000_NULL'
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
        'RD_BESSEL_TO_WGS84_NULL_USAGE',
        'concatenated_operation',
        'NSGI',
        'RD_BESSEL_TO_WGS84_NULL',
        'EPSG',
        '1262',
        'EPSG',
        '1181'
    );
    
