from pyproj import transformer, datadir
import sys

print("PATH of the used PROJ: " + datadir.get_data_dir())

rdnap2etrf = transformer.TransformerGroup("EPSG:7415", "EPSG:7931")
etrf2rdnap = transformer.TransformerGroup("EPSG:7931", "EPSG:7415")

result = (
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

with open(sys.argv[1], "r") as Z001:
 
    for _, point in enumerate(Z001.readlines()):
        nr, lat, lon, h, rdx, rdy, nap = point.split()

        if nap == "*":
            nap = float("inf")

        lat_calc, lon_calc, h_calc = rdnap2etrf.transformers[0].transform(rdx, rdy, nap)
        rdx_calc, rdy_calc, nap_calc = etrf2rdnap.transformers[0].transform(lat, lon, h)

        lat_diff, lon_diff, h_diff = (
            float(lat) - lat_calc,
            float(lon) - lon_calc,
            float(h) - h_calc,
        )
        rdx_diff, rdy_diff, nap_diff = (
            float(rdx) - rdx_calc,
            float(rdy) - rdy_calc,
            float(nap) - nap_calc,
        )

        result += f"{nr},{lat_diff:.9f},{lon_diff:.9f},{h_diff:.4f},\
 {rdx_diff:.4f},{rdy_diff:.4f},{nap_diff:.4f},{lat},\
 {lon},{h},{rdx},{rdy},{nap},{lat_calc:.9f},{lon_calc:.9f},\
 {h_calc:.4f},{rdx_calc:.4f},{rdy_calc:.4f},{nap_calc:.4f}\n"

with open(sys.argv[2], "w") as f:    
    f.write(result)