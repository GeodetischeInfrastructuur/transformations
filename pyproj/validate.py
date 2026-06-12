import argparse
import math
import os
import sys
from types import SimpleNamespace
from pyproj import transformer

rdnap2etrf2000 = transformer.TransformerGroup("EPSG:7415", "EPSG:7931")
rd2etrf2000 = transformer.TransformerGroup("EPSG:28992", "EPSG:9067")
etrf20002rdnap = transformer.TransformerGroup("EPSG:7931", "EPSG:7415")
etrf20002rd = transformer.TransformerGroup("EPSG:9067", "EPSG:28992")

RESULT = (
    ",".join(
        [
            "nr",
            "lat_diff",
            "lon_diff",
            "h_diff",
            "rdx_diff",
            "rdy_diff",
            "nap_diff",
            "lat_orig",
            "lon_orig",
            "h_orig",
            "rdx_orig",
            "rdy_orig",
            "nap_orig",
            "lat_calc",
            "lon_calc",
            "h_calc",
            "rdx_calc",
            "rdy_calc",
            "nap_calc",
        ]
    )
    + "\n"
)


def validate_results(results):
    validation_results = []

    lat_long_thresh = 10**-8
    h_thresh = 10**-3

    rd_x_y_h_thresh = 10**-3

    for item in results:
        if any(
            value > lat_long_thresh for value in [item["lat_diff"], item["lon_diff"]]
        ):
            item["reason"] = (
                f"lat_diff or long_diff exceeds treshold: {item["lat_diff"]},{ item["lon_diff"]}"
            )
            validation_results.append(item)
            continue
        if not math.isinf(item["h_diff"]) and item["h_diff"] > h_thresh:
            item["reason"] = f'h_diff exceeds treshold: {item["h_diff"]}'
            validation_results.append(item)
            continue

        if any(
            value > rd_x_y_h_thresh
            for value in [
                item["rdx_diff"],
                item["rdy_diff"],
            ]
        ):
            item["reason"] = (
                f"rdx_diff or rdy_diff exceeds treshold: {item["rdx_diff"]},{ item["rdy_diff"]}"
            )
            validation_results.append(item)

        if not math.isnan(item["nap_diff"]) and item["nap_diff"] > rd_x_y_h_thresh:
            item["reason"] = f'nap_diff exceeds treshold: {item["nap_diff"]}'
            validation_results.append(item)
            continue

    return validation_results


def save_results_to_csv(results, output_path):
    with open(output_path, "w") as f:
        f.write(RESULT)
        for result in results:
            r = SimpleNamespace(
                **result
            )  # to be able to access dictionary keys as attributes in r - for readability
            if "reason" in result:
                result_string = f"{r.nr},{r.lat_diff:.9f},{r.lon_diff:.9f},{r.h_diff:.4f},{r.rdx_diff:.4f},{r.rdy_diff:.4f},{r.nap_diff:.4f},{r.lat},{r.lon},{r.h},{r.rdx},{r.rdy},{r.nap},{r.lat_calc:.9f},{r.lon_calc:.9f},{r.h_calc:.4f},{r.rdx_calc:.4f},{r.rdy_calc:.4f},{r.nap_calc:.4f},{r.reason}\n"
            else:
                result_string = f"{r.nr},{r.lat_diff:.9f},{r.lon_diff:.9f},{r.h_diff:.4f},{r.rdx_diff:.4f},{r.rdy_diff:.4f},{r.nap_diff:.4f},{r.lat},{r.lon},{r.h},{r.rdx},{r.rdy},{r.nap},{r.lat_calc:.9f},{r.lon_calc:.9f},{r.h_calc:.4f},{r.rdx_calc:.4f},{r.rdy_calc:.4f},{r.nap_calc:.4f}\n"

            f.write(result_string)


def main(input_csv, output_csv):
    global RESULT

    results = []
    with open(input_csv, "r") as Z001:
        for _, point in enumerate(Z001.readlines()):
            nr, lat, lon, h, rdx, rdy, nap = point.split()

            if nap != "*":
                lat_calc, lon_calc, h_calc = rdnap2etrf2000.transformers[0].transform(
                    rdx, rdy, nap
                )

                rdx_calc, rdy_calc, nap_calc = etrf20002rdnap.transformers[0].transform(
                    lat, lon, h
                )

            if (math.isinf(rdx_calc) or math.isinf(rdy_calc)) or nap == "*":
                nap_calc = float("inf")
                rdx_calc, rdy_calc = etrf20002rd.transformers[0].transform(lat, lon)

            if (math.isinf(lat_calc) or math.isinf(lon_calc)) or nap == "*":
                h_calc = float("inf")
                lat_calc, lon_calc = rd2etrf2000.transformers[0].transform(rdx, rdy)

            lat_diff, lon_diff, h_diff = (
                abs(float(lat) - lat_calc),
                abs(float(lon) - lon_calc),
                abs(float(h) - h_calc),
            )
            rdx_diff, rdy_diff, nap_diff = (
                abs(float(rdx) - rdx_calc),
                abs(float(rdy) - rdy_calc),
                abs(float(nap if nap != "*" else math.inf) - nap_calc),
            )

            result = {
                "nr": nr,
                "lat_diff": lat_diff,
                "lon_diff": lon_diff,
                "h_diff": h_diff,
                "rdx_diff": rdx_diff,
                "rdy_diff": rdy_diff,
                "nap_diff": nap_diff,
                "lat": lat,
                "lon": lon,
                "h": h,
                "rdx": rdx,
                "rdy": rdy,
                "nap": nap,
                "lat_calc": lat_calc,
                "lon_calc": lon_calc,
                "h_calc": h_calc,
                "rdx_calc": rdx_calc,
                "rdy_calc": rdy_calc,
                "nap_calc": nap_calc,
            }
            results.append(result)

    save_results_to_csv(results, output_csv)

    invalid_results = validate_results(results)

    if len(invalid_results) > 0:
        filename, file_extension = os.path.splitext(output_csv)
        output_invalid_csv = f"{filename}.invalid{file_extension}"
        save_results_to_csv(invalid_results, output_invalid_csv)

        print(
            f"validation result: FAILED\nmessage: accurate transformation of one or more points failed ({len(invalid_results)}), invalid points saved in {output_invalid_csv}, all points saved in {output_csv}",
            file=sys.stderr,
        )
        sys.exit(1)

    print(
        f"validation result: OK\nmessage: all points transformed and validated succesfully, output saved in {output_csv}"
    )
    sys.exit(0)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="validate",
        description="run self-validation transformation and validate results",
        epilog="Created by https://www.nsgi.nl",
    )
    parser.add_argument("input_csv")  # positional argument
    parser.add_argument("output_csv")  # positional argument
    args = parser.parse_args()
    main(args.input_csv, args.output_csv)
