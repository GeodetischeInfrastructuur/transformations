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
--     Modify extend of NL CRSs
-------------------------------------------------------
UPDATE
    usage
SET
    extent_auth_name = 'NSGI' AND extent_code = 'EXTENT_3D_RDNAPTRANS2018'
WHERE
    object_auth_name = 'EPSG' AND code = '28992'
;
UPDATE
    usage
SET
    extent_auth_name = 'NSGI' AND extent_code = 'EXTENT_3D_RDNAPTRANS2018'
WHERE
    object_auth_name = 'EPSG' AND code = '7415'
;
UPDATE
    usage
SET
    extent_auth_name = 'NSGI' AND extent_code = 'EXTENT_3D_RDNAPTRANS2018'
WHERE
    object_auth_name = 'EPSG' AND code = '9286'
;

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
        'AGRS.NL',
        'Active GNSS Reference Sytem for the Netherlands',
        'EPSG',
        '7019',
        'EPSG',
        '8901',
        '1997-01-01',
        NULL,
        NULL,
        NULL,
        0
    ),
    (
        'NSGI',
        'Bonaire_Datum',
        'Bonaire',
        'Geodetic Datum for Bonaire DPnet',
        'EPSG',
        '7022',
        'EPSG',
        '8901',
        '2023-12-11',
        NULL,
        NULL,
        NULL,
        0
    ),
    (
        'NSGI',
        'Bonaire2004_Datum',
        'Bonaire 2004',
        'Geodetic Datum for Bonaire based on ITRF2000',
        'EPSG',
        '7019',
        'EPSG',
        '8901',
        '2023-12-11',
        NULL,
        NULL,
        NULL,
        0
    ),
    (
        'NSGI',
        'Saba_Datum',
        'Saba',
        'Geodetic Datum for Saba DPnet',
        'EPSG',
        '7022',
        'EPSG',
        '8901',
        '2023-12-11',
        NULL,
        NULL,
        NULL,
        0
    ),
    (
        'NSGI',
        'St_Eustatius_Datum',
        'St Eustatius',
        'Geodetic Datum for St Eustatius DPnet',
        'EPSG',
        '7022',
        'EPSG',
        '8901',
        '2023-12-11',
        NULL,
        NULL,
        NULL,
        0
    ),
    (
        'NSGI',
        'BES2020',
        'Geodetic Datum for Bonaire, Saba and St Eustatius based on ITRF2014',
        NULL,
        'EPSG',
        '7019',
        'EPSG',
        '8901',
        '2023-12-11',
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
    ),
    (
        'NSGI',
        'Bonaire_Datum_USAGE',
        'geodetic_datum',
        'NSGI',
        'Bonaire_Datum',
        'EPSG',
        '3822',
        'EPSG',
        '1027'
    ),
    (
        'NSGI',
        'Bonaire2004_Datum_USAGE',
        'geodetic_datum',
        'NSGI',
        'Bonaire2004_Datum',
        'EPSG',
        '3822',
        'EPSG',
        '1027'
    ),
    (
        'NSGI',
        'Saba_Datum_USAGE',
        'geodetic_datum',
        'NSGI',
        'Saba_Datum',
        'EPSG',
        '3820',
        'EPSG',
        '1027'
    ),
    (
        'NSGI',
        'St_Eustatius_Datum_USAGE',
        'geodetic_datum',
        'NSGI',
        'St_Eustatius_Datum',
        'EPSG',
        '3820',
        'EPSG',
        '1027'
    ),
    (
        'NSGI',
        'BES2020_USAGE',
        'geodetic_datum',
        'NSGI',
        'BES2020',
        'EPSG',
        '3805',
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
        TYPE,
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
        'Pseudo_RD_Bessel',
        'pseudo RD Bessel',
        NULL,
        'geographic 2D',
        'EPSG',
        '6422',
        'EPSG',
        '6289',
        NULL,
        0
    ),
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
    ),
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
    ),
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
    ),
    (
        'NSGI',
        'Bonaire_Local_2004_GEOCENTRIC',
        'Bonaire',
        NULL,
        'geocentric',
        'EPSG',
        '6500',
        'NSGI',
        'Bonaire_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'Bonaire_Local_2004_GEOGRAPHIC_3D',
        'Bonaire',
        NULL,
        'geographic 3D',
        'EPSG',
        '6423',
        'NSGI',
        'Bonaire_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'Bonaire_Local_2004_GEOGRAPHIC_2D',
        'Bonaire',
        NULL,
        'geographic 2D',
        'EPSG',
        '6422',
        'NSGI',
        'Bonaire_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'Bonaire2004_GEOCENTRIC',
        'Bonaire 2004',
        'ITRF2000 realisation approximately epoch 2001.0 of Bonaire computed in 2004',
        'geocentric',
        'EPSG',
        '6500',
        'NSGI',
        'Bonaire2004_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'Bonaire2004_GEOGRAPHIC_3D',
        'Bonaire 2004',
        'ITRF2000 realisation approximately epoch 2001.0 of Bonaire computed in 2004',
        'geographic 3D',
        'EPSG',
        '6423',
        'NSGI',
        'Bonaire2004_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'Bonaire2004_GEOGRAPHIC_2D',
        'Bonaire 2004',
        'ITRF2000 realisation approximately epoch 2001.0 of Bonaire computed in 2004',
        'geographic 2D',
        'EPSG',
        '6422',
        'NSGI',
        'Bonaire2004_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'Saba_Local_2020_GEOCENTRIC',
        'Saba',
        NULL,
        'geocentric',
        'EPSG',
        '6500',
        'NSGI',
        'Saba_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'Saba_Local_2020_GEOGRAPHIC_3D',
        'Saba',
        NULL,
        'geographic 3D',
        'EPSG',
        '6423',
        'NSGI',
        'Saba_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'Saba_Local_2020_GEOGRAPHIC_2D',
        'Saba',
        NULL,
        'geographic 2D',
        'EPSG',
        '6422',
        'NSGI',
        'Saba_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'Saba2020_GEOCENTRIC',
        'Saba 2020', 
        'ITRF2014 realisation at epoch 2020.0 of Saba',
        'geocentric',
        'EPSG',
        '6500',
        'NSGI',
        'BES2020',
        NULL,
        0
    ),
    (
        'NSGI',
        'Saba2020_GEOGRAPHIC_3D',
        'Saba 2020', 
        'ITRF2014 realisation at epoch 2020.0 of Saba',
        'geographic 3D',
        'EPSG',
        '6423',
        'NSGI',
        'BES2020',
        NULL,
        0
    ),
    (
        'NSGI',
        'Saba2020_GEOGRAPHIC_2D',
        'Saba 2020', 
        'ITRF2014 realisation at epoch 2020.0 of Saba',
        'geographic 2D',
        'EPSG',
        '6422',
        'NSGI',
        'BES2020',
        NULL,
        0
    ),
    (
        'NSGI',
        'St_Eustatius_Local_2020_GEOCENTRIC',
        'St Eustatius',
        NULL,
        'geocentric',
        'EPSG',
        '6500',
        'NSGI',
        'St_Eustatius_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'St_Eustatius_Local_2020_GEOGRAPHIC_3D',
        'St Eustatius',
        NULL,
        'geographic 3D',
        'EPSG',
        '6423',
        'NSGI',
        'St_Eustatius_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'St_Eustatius_Local_2020_GEOGRAPHIC_2D',
        'St Eustatius',
        NULL,
        'geographic 2D',
        'EPSG',
        '6422',
        'NSGI',
        'St_Eustatius_Datum',
        NULL,
        0
    ),
    (
        'NSGI',
        'St_Eustatius2020_GEOCENTRIC',
        'St Eustatius 2020',
        'ITRF2014 realisation at epoch 2020.0 of St_Eustatius',
        'geocentric',
        'EPSG',
        '6500',
        'NSGI',
        'BES2020',
        NULL,
        0
    ),
    (
        'NSGI',
        'St_Eustatius2020_GEOGRAPHIC_3D',
        'St Eustatius 2020',
        'ITRF2014 realisation at epoch 2020.0 of St_Eustatius',
        'geographic 3D',
        'EPSG',
        '6423',
        'NSGI',
        'BES2020',
        NULL,
        0
    ),
    (
        'NSGI',
        'St_Eustatius2020_GEOGRAPHIC_2D',
        'St Eustatius 2020',
        'ITRF2014 realisation at epoch 2020.0 of St_Eustatius',
        'geographic 2D',
        'EPSG',
        '6422',
        'NSGI',
        'BES2020',
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
        'Pseudo_RD_Bessel_USAGE',
        'geodetic_crs',
        'NSGI',
        'Pseudo_RD_Bessel',
        'EPSG',
        '1262',
        'EPSG',
        '1269'
    ),
    (
        'NSGI',
        'AGRS2010_GEOCENTRIC_USAGE',
        'geodetic_crs',
        'NSGI',
        'AGRS2010_GEOCENTRIC',
        'EPSG',
        '1298',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'AGRS2010_GEOGRAPHIC_3D_USAGE',
        'geodetic_crs',
        'NSGI',
        'AGRS2010_GEOGRAPHIC_3D',
        'EPSG',
        '1298',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'AGRS2010_GEOGRAPHIC_2D_USAGE',
        'geodetic_crs',
        'NSGI',
        'AGRS2010_GEOGRAPHIC_2D',
        'EPSG',
        '1298',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'Bonaire_Local_2004_GEOCENTRIC_USAGE',
        'geodetic_crs',
        'NSGI',
        'Bonaire_Local_2004_GEOCENTRIC',
        'EPSG',
        '3822',
        'EPSG',
        '1269'
    ),
    (
        'NSGI',
        'Bonaire_Local_2004_GEOGRAPHIC_3D_USAGE',
        'geodetic_crs',
        'NSGI',
        'Bonaire_Local_2004_GEOGRAPHIC_3D',
        'EPSG',
        '3822',
        'EPSG',
        '1269'
    ),
    (
        'NSGI',
        'Bonaire_Local_2004_GEOGRAPHIC_2D_USAGE',
        'geodetic_crs',
        'NSGI',
        'Bonaire_Local_2004_GEOGRAPHIC_2D',
        'EPSG',
        '3822',
        'EPSG',
        '1269'
    ),
    (
        'NSGI',
        'Bonaire2004_GEOCENTRIC_USAGE',
        'geodetic_crs',
        'NSGI',
        'Bonaire2004_GEOCENTRIC',
        'EPSG',
        '3822',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'Bonaire2004_GEOGRAPHIC_3D_USAGE',
        'geodetic_crs',
        'NSGI',
        'Bonaire2004_GEOGRAPHIC_3D',
        'EPSG',
        '3822',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'Bonaire2004_GEOGRAPHIC_2D_USAGE',
        'geodetic_crs',
        'NSGI',
        'Bonaire2004_GEOGRAPHIC_2D',
        'EPSG',
        '3822',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'Saba_Local_2020_GEOCENTRIC_USAGE',
        'geodetic_crs',
        'NSGI',
        'Saba_Local_2020_GEOCENTRIC',
        'EPSG',
        '3820',
        'EPSG',
        '1269'
    ),
    (
        'NSGI',
        'Saba_Local_2020_GEOGRAPHIC_3D_USAGE',
        'geodetic_crs',
        'NSGI',
        'Saba_Local_2020_GEOGRAPHIC_3D',
        'EPSG',
        '3820',
        'EPSG',
        '1269'
    ),
    (
        'NSGI',
        'Saba_Local_2020_GEOGRAPHIC_2D_USAGE',
        'geodetic_crs',
        'NSGI',
        'Saba_Local_2020_GEOGRAPHIC_2D',
        'EPSG',
        '3820',
        'EPSG',
        '1269'
    ),
    (
        'NSGI',
        'Saba2020_GEOCENTRIC_USAGE',
        'geodetic_crs',
        'NSGI',
        'Saba2020_GEOCENTRIC',
        'EPSG',
        '3820',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'Saba2020_GEOGRAPHIC_3D_USAGE',
        'geodetic_crs',
        'NSGI',
        'Saba2020_GEOGRAPHIC_3D',
        'EPSG',
        '3820',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'Saba2020_GEOGRAPHIC_2D_USAGE',
        'geodetic_crs',
        'NSGI',
        'Saba2020_GEOGRAPHIC_2D',
        'EPSG',
        '3820',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'St_Eustatius_Local_2020_GEOCENTRIC_USAGE',
        'geodetic_crs',
        'NSGI',
        'St_Eustatius_Local_2020_GEOCENTRIC',
        'EPSG',
        '3820',
        'EPSG',
        '1269'
    ),
    (
        'NSGI',
        'St_Eustatius_Local_2020_GEOGRAPHIC_3D_USAGE',
        'geodetic_crs',
        'NSGI',
        'St_Eustatius_Local_2020_GEOGRAPHIC_3D',
        'EPSG',
        '3820',
        'EPSG',
        '1269'
    ),
    (
        'NSGI',
        'St_Eustatius_Local_2020_GEOGRAPHIC_2D_USAGE',
        'geodetic_crs',
        'NSGI',
        'St_Eustatius_Local_2020_GEOGRAPHIC_2D',
        'EPSG',
        '3820',
        'EPSG',
        '1269'
    ),
    (
        'NSGI',
        'St_Eustatius2020_GEOCENTRIC_USAGE',
        'geodetic_crs',
        'NSGI',
        'St_Eustatius2020_GEOCENTRIC',
        'EPSG',
        '3820',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'St_Eustatius2020_GEOGRAPHIC_3D_USAGE',
        'geodetic_crs',
        'NSGI',
        'St_Eustatius2020_GEOGRAPHIC_3D',
        'EPSG',
        '3820',
        'EPSG',
        '1181'
    ),
    (
        'NSGI',
        'St_Eustatius2020_GEOGRAPHIC_2D_USAGE',
        'geodetic_crs',
        'NSGI',
        'St_Eustatius2020_GEOGRAPHIC_2D',
        'EPSG',
        '3820',
        'EPSG',
        '1181'
    );

--- Map projections
INSERT INTO
    "conversion"
VALUES
    (
        'NSGI',
        'Bonaire_DPnet_conversion',
        'Local map projection system of Bonaire',
        '',
        'EPSG',
        '9807',
        'Transverse Mercator',
        'EPSG',
        '8801',
        'Latitude of natural origin',
        12.180658675,
        'EPSG',
        '9102',
        'EPSG',
        '8802',
        'Longitude of natural origin',
        -68.251802281,
        'EPSG',
        '9102',
        'EPSG',
        '8805',
        'Scale factor at natural origin',
        1.0,
        'EPSG',
        '9201',
        'EPSG',
        '8806',
        'False easting',
        23209.5600,
        'EPSG',
        '9001',
        'EPSG',
        '8807',
        'False northing',
        21423.9900,
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
        0
    ),
    (
        'NSGI',
        'Saba_DPnet_conversion',
        'Local map projection of Saba',
        '',
        'EPSG',
        '9807',
        'Transverse Mercator',
        'EPSG',
        '8801',
        'Latitude of natural origin',
        0.0,
        'EPSG',
        '9102',
        'EPSG',
        '8802',
        'Longitude of natural origin',
        -63.0,
        'EPSG',
        '9102',
        'EPSG',
        '8805',
        'Scale factor at natural origin',
        0.9996,
        'EPSG',
        '9201',
        'EPSG',
        '8806',
        'False easting',
        29973.97,
        'EPSG',
        '9001',
        'EPSG',
        '8807',
        'False northing',
        -1947925.94,
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
        0
    ),
    (
        'NSGI',
        'St_Eustatius_DPnet_conversion',
        'Local map projection of St_Eustatius',
        '',
        'EPSG',
        '9807',
        'Transverse Mercator',
        'EPSG',
        '8801',
        'Latitude of natural origin',
        0.0,
        'EPSG',
        '9102',
        'EPSG',
        '8802',
        'Longitude of natural origin',
        -63.0,
        'EPSG',
        '9102',
        'EPSG',
        '8805',
        'Scale factor at natural origin',
        0.9996,
        'EPSG',
        '9201',
        'EPSG',
        '8806',
        'False easting',
        500000.0,
        'EPSG',
        '9001',
        'EPSG',
        '8807',
        'False northing',
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
        'Bonaire_DPnet_conversion_USAGE',
        'conversion',
        'NSGI',
        'Bonaire_DPnet_conversion',
        'EPSG',
        '3822',
        'EPSG',
        '1056'
    ),
    (
        'NSGI',
        'Saba_DPnet_conversion_USAGE',
        'conversion',
        'NSGI',
        'Saba_DPnet_conversion',
        'EPSG',
        '3820',
        'EPSG',
        '1056'
    ),
    (
        'NSGI',
        'St_Eustatius_DPnet_conversion_USAGE',
        'conversion',
        'NSGI',
        'St_Eustatius_DPnet_conversion',
        'EPSG',
        '3820',
        'EPSG',
        '1056'
    );

--- Projected crs
INSERT INTO
    "projected_crs"
VALUES
    (
        'NSGI',
        'Bonaire_DPnet',
        'Bonaire / Bonaire DPnet',
        'Local coordinate system of Bonaire',
        'EPSG',
        '4499',
        'NSGI',
        'Bonaire_Local_2004_GEOGRAPHIC_2D',
        'NSGI',
        'Bonaire_DPnet_conversion',
        NULL,
        0
    ),
    (
        'NSGI',
        'Saba_DPnet',
        'Saba / Saba Dpnet',
        'Local coordinate system of Saba',
        'EPSG',
        '4499',
        'NSGI',
        'Saba_Local_2020_GEOGRAPHIC_2D',
        'NSGI',
        'Saba_DPnet_conversion',
        NULL,
        0
    ),
    (
        'NSGI',
        'St_Eustatius_DPnet',
        'St Eustatius /  St Eustatius DPnet',
        'Local coordinate system of St_Eustatius',
        'EPSG',
        '4499',
        'NSGI',
        'St_Eustatius_Local_2020_GEOGRAPHIC_2D',
        'NSGI',
        'St_Eustatius_DPnet_conversion',
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
        'Bonaire_DPnet_USAGE',
        'projected_crs',
        'NSGI',
        'Bonaire_DPnet',
        'EPSG',
        '3822',
        'EPSG',
        '1056'
    ),
    (
        'NSGI',
        'Saba_DPnet_USAGE',
        'projected_crs',
        'NSGI',
        'Saba_DPnet',
        'EPSG',
        '3820',
        'EPSG',
        '1056'
    ),
    (
        'NSGI',
        'St_Eustatius_DPnet_USAGE',
        'projected_crs',
        'NSGI',
        'St_Eustatius_DPnet',
        'EPSG',
        '3820',
        'EPSG',
        '1056'
    );

-- vertical datum
INSERT INTO
    "vertical_datum"
VALUES
    (
        'NSGI',
        'Bonaire_KADpeil_Datum',
        'KAD Peil Bonaire',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        0
    ),
    (
        'NSGI',
        'St_Eustatius_Height_Datum',
        'Height datum for Sint Eustatius',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        0
    ),
    (
        'NSGI',
        'Saba_Height_Datum',
        'Height datum for Saba',
        NULL,
        NULL,
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
        'Saba_Height_Datum_USAGE',
        'vertical_datum',
        'NSGI',
        'Saba_Height_Datum',
        'EPSG',
        '3820',
        'EPSG',
        '1179'
    ),
    (
    'NSGI',
    'St_Eustatius_Height_Datum_USAGE',
    'vertical_datum',
    'NSGI',
    'St_Eustatius_Height_Datum',
    'EPSG',
    '3820',
    'EPSG',
    '1179'
    ),
    (
    'NSGI',
    'Bonaire_KADpeil_Datum_USAGE',
    'vertical_datum',
    'NSGI',
    'Bonaire_KADpeil_Datum',
    'EPSG',
    '3822',
    'EPSG',
    '1179'
    );

-- vertical crss
INSERT INTO
    "vertical_crs"
VALUES
    (
        'NSGI',
        'Bonaire_KADpeil',
        'Bonaire KADpeil',
        NULL,
        'EPSG',
        '6499',
        'NSGI',
        'Bonaire_KADpeil_Datum',
        0
    ),
    (
        'NSGI',
        'St_Eustatius_Height',
        'St Eustatius height',
        NULL,
        'EPSG',
        '6499',
        'NSGI',
        'St_Eustatius_Height_Datum',
        0
    ),
    (
        'NSGI',
        'Saba_Height',
        'Saba height',
        NULL,
        'EPSG',
        '6499',
        'NSGI',
        'Saba_Height_Datum',
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
        'Bonaire_KADpeil_USAGE',
        'vertical_crs',
        'NSGI',
        'Bonaire_KADpeil',
        'EPSG',
        '3822',
        'EPSG',
        '1179'
    ),
    (
        'NSGI',
        'St_Eustatius_Height_USAGE',
        'vertical_crs',
        'NSGI',
        'St_Eustatius_Height',
        'EPSG',
        '3820',
        'EPSG',
        '1179'
    ),
    (
        'NSGI',
        'Saba_Height_USAGE',
        'vertical_crs',
        'NSGI',
        'Saba_Height',
        'EPSG',
        '3820',
        'EPSG',
        '1179'
    )    ;

--- Compound crs
INSERT INTO
    "compound_crs"
VALUES
    (
        'NSGI',
        'Bonaire_DPnet_KADpeil',
        'Bonaire / Bonaire DPnet + Bonaire KADpeil',
        NULL,
        'NSGI',
        'Bonaire_DPnet',
        'NSGI',
        'Bonaire_KADpeil',
        0
    ),
    (
        'NSGI',
        'St_Eustatius_DPnet_Height',
        'St Eustatius / St Eustatius DPnet + St Eustatius height',
        NULL,
        'NSGI',
        'St_Eustatius_DPnet',
        'NSGI',
        'St_Eustatius_Height',
        0
    ),
    (
        'NSGI',
        'Saba_DPnet_Height',
        'Saba / Saba DPnet + Saba height',
        NULL,
        'NSGI',
        'Saba_DPnet',
        'NSGI',
        'Saba_Height',
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
        'Bonaire_DPnet_KADpeil_USAGE',
        'compound_crs',
        'NSGI',
        'Bonaire_DPnet_KADpeil',
        'EPSG',
        '3822',
        'EPSG',
        '1142'
    ),
    (
        'NSGI',
        'St_Eustatius_DPnet_Height_USAGE',
        'compound_crs',
        'NSGI',
        'St_Eustatius_DPnet_Height',
        'EPSG',
        '3820',
        'EPSG',
        '1142'
    ),
    (
        'NSGI',
        'Saba_DPnet_Height_USAGE',
        'compound_crs',
        'NSGI',
        'Saba_DPnet_Height',
        'EPSG',
        '3820',
        'EPSG',
        '1142'
    );