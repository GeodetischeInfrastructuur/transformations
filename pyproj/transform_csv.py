"""Transform point features between EPSG:7931 (ETRS89) and EPSG:7415 (RD New + NAP).

Usage:
    python transform_csv.py <src> [<dst>]

    src  – space-delimited text file
           EPSG:7931 columns: point_id latitude longitude height
           EPSG:7415 columns: point_id x_coordinate y_coordinate height
    dst  – output path (default: stdout)

Direction is detected from the input column names.
"""

import csv
import sys

from pyproj import Transformer

tf_to_rdnap = Transformer.from_crs("EPSG:7931", "EPSG:7415")
tf_to_etrs89 = Transformer.from_crs("EPSG:7415", "EPSG:7931")

src_path = sys.argv[1] if len(sys.argv) > 1 else None
dst_path = sys.argv[2] if len(sys.argv) > 2 else None

infile = open(src_path) if src_path else sys.stdin
outfile = open(dst_path, "w") if dst_path else sys.stdout

reader = csv.DictReader(infile, delimiter=" ", skipinitialspace=True)

if "latitude" in reader.fieldnames:
    # EPSG:7931 → EPSG:7415
    outfile.write(f"{'point_id':<10}  {'x_coordinate':>13}  {'y_coordinate':>13}  {'height':>9}\n")
    for row in reader:
        x, y, h = tf_to_rdnap.transform(row["latitude"], row["longitude"], row["height"])
        outfile.write(f"{row['point_id']:<10}  {x:>13.4f}  {y:>13.4f}  {h:>9.4f}\n")
else:
    # EPSG:7415 → EPSG:7931
    outfile.write(f"{'point_id':<10}  {'latitude':>16}  {'longitude':>13}  {'height':>9}\n")
    for row in reader:
        lat, lon, h = tf_to_etrs89.transform(row["x_coordinate"], row["y_coordinate"], row["height"])
        outfile.write(f"{row['point_id']:<10}  {lat:>16.9f}  {lon:>13.9f}  {h:>9.4f}\n")

if src_path:
    infile.close()
if dst_path:
    outfile.close()

