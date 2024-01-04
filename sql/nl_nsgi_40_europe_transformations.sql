-------------------------------------------------------
--     Transformation: AGRS2010 --> ETRF2000
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
        'AGRS2010_TO_ETRF2000',
        'AGRS2010 to ETRF2000 NULL transformation',
        'null transformation between AGRS2010 and ETRF2010',
        'EPSG',
        '9603',
        'Geocentric translations (geog2D domain)',
        'NSGI',
        'AGRS2010_GEOGRAPHIC_2D',
        'EPSG',
        '9067',
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
        'AGRS2010_TO_ETRF2000_USAGE',
        'helmert_transformation',
        'NSGI',
        'AGRS2010_TO_ETRF2000',
        'EPSG',
        '1262',
        'EPSG',
        '1027'
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
        'AGRS2010_TO_ETRF2000'
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
        'ETRS89_TO_ETRF2000_preferred',
        'ETRS89 to ETRF2000',
        'Accuracy 0.099 m, from datum ensemble definition',
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
        'ETRS89_TO_ETRF2000_preferred_USAGE',
        'helmert_transformation',
        'NSGI',
        'ETRS89_TO_ETRF2000_preferred',
        'EPSG',
        '1298',
        'EPSG',
        '1024'
    );
    
