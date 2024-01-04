-------------------------------------------------------
--     Transformation: ITRF2014 -> ETRF2000 time dependent
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
        'ITRF2014_TO_ETRF2000',
        'ITRF2014 to ETRF2000 time dependent',
        'time dependent transformation between ITRF2014 and ETRF2000',
        'EPSG',
        '1053',
        'Time-dependent Position Vector tfm (geocentric)',
        'EPSG',
        '9000',
        'EPSG',
        '9067',
        '2.0',
        '54.7',
        '52.2',
        '-74.1',
        'EPSG',
        '1025',
        '1.701',
        '10.29',
        '-16.632',
        'EPSG',
        '1031',
        '2.12',
        'EPSG',
        '1028',
        '0.1',
        '0.1',
        '-1.9',
        'EPSG',
        '1027',
        '0.081',
        '0.49',
        '-0.792',
        'EPSG',
        '1032',
        '0.11',
        'EPSG',
        '1030',
        '2010.0',
        'EPSG',
        '1029',
        '',
        '',
        '',
        '',
        '',
        'EUREF-Eur 2000',
        '0'
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
        'ITRF2014_TO_ETRF2000_USAGE',
        'helmert_transformation',
        'NSGI',
        'ITRF2014_TO_ETRF2000',
        'EPSG',
        '1262',
        'EPSG',
        '1027'
    );

-------------------------------------------------------
--     Transformation (concatenated): 
--     ETRS89 -> ITRF2014 _TIMEDEPENDENT
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
        'ETRS89_TO_ITRF2014_TIMEDEPENDENT',
        'ETRS89 to ITRF2014 _TIMEDEPENDENT',
        '',
        'EPSG',
        '4258',
        'EPSG',
        '9000',
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
        'ETRS89_TO_ITRF2014_TIMEDEPENDENT',
        1,
        'NSGI',
        'ETRS89_TO_ETRF2000_preferred'
    ),
    (
        'NSGI',
        'ETRS89_TO_ITRF2014_TIMEDEPENDENT',
        2,
        'NSGI',
        'ITRF2014_TO_ETRF2000'
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
        'ETRS89_TO_ITRF2014_TIMEDEPENDENT_USAGE',
        'concatenated_operation',
        'NSGI',
        'ETRS89_TO_ITRF2014_TIMEDEPENDENT',
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
        'AGRS2010_TO_ETRF2000'
    ),
    ('NSGI', 'AGRS2010_TO_ITRF2014', 2, 'NSGI', 'ITRF2014_TO_ETRF2000');

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
        'AGRS2010_TO_ETRF2000'
    ),
    (
        'NSGI',
        'RD_BESSEL_TO_ITRF2014',
        4,
        'NSGI', 'ITRF2014_TO_ETRF2000'
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
    
