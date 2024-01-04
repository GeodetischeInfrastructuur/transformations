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

