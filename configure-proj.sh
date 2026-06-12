#!/usr/bin/env bash
set -eu

# get proj_dir with: PROJ_DIR=$(python -c 'import pyproj;print(pyproj.datadir.get_data_dir())')
if [ $# -ne 2 ]; then
    echo "$0 <proj-dir> <sql-dir>"
    exit 1
fi

proj_dir="$1" # /usr/share/proj
sql_dir="$2"

# create backup file of proj.db for reverting
cp "$proj_dir/proj.db" "$proj_dir/proj.db.bak"

for sql_file in $( # note -t=seperator, -k=keydef, sorts on third item in [nl,nsgi,00]
    find "$sql_dir/default" -type f | sort -t _ -k 3
); do
    echo "running sql: ${sql_file}"
    sqlite3 "$proj_dir/proj.db" <"$sql_file"
done

cp "$proj_dir/proj.db" "$proj_dir/proj.time.dependent.transformations.db"
echo "running sql: ${sql_dir}/time_dependent/nl_nsgi_00_time_dependent_transformations.sql on file: ${proj_dir}/proj.time.dependent.transformations.db"
sqlite3 "$proj_dir/proj.time.dependent.transformations.db" <"$sql_dir/time_dependent/nl_nsgi_00_time_dependent_transformations.sql"

