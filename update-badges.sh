#!/usr/bin/env bash

sed -i "s/badge\/PROJ-[0-9.]*-blue/badge\/PROJ-$(grep 'FROM osgeo/proj:' Dockerfile | grep -o '[0-9.]*$')-blue/" README.md
sed -i "s/badge\/pyproj-[0-9.]*-blue/badge\/pyproj-$(grep 'pyproj' validate/pyproject.toml | grep -o '[0-9.]*' | head -1)-blue/" README.md