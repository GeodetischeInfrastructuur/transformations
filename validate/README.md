# VALIDATIE

## Handmatig

Om te verifieren of de transformatie `EPSG:7931` -> `EPSG:7415` correct werk voer het volgende uit in een terminal (vanaf de root van dit project).

```bash
docker build -f validate/Dockerfile -t geodetischeinfrastructuur/pyproj:3.6.1 validate/
docker run --rm geodetischeinfrastructuur/pyproj:3.6.1 python -c "from pyproj import transformer; etrf = transformer.TransformerGroup('EPSG:7931', 'EPSG:7415'); print('{0[0]:.4f} {0[1]:.4f} {0[2]:.4f}'.format(etrf.transformers[0].transform(52.115330444, 7.684748554, 41.4160)))"
```

Dit moet de volgende output geven:

```txt
312352.6004 461058.5812 -2.5206
```

## Validatie tegen NSGI validatie service

```sh
(
    cd validate
    curl -o 002_RDNAP.txt 'https://www.nsgi.nl/documents/1888506/1945213/002_RDNAP.txt/5d6dc6b8-a59d-40d0-0363-8a9b59e51c62?t=1574879689583'
    curl -o 002_ETRS89.txt 'https://www.nsgi.nl/documents/1888506/1944539/002_ETRS89.txt/6aa954da-d345-de97-386a-4fbd956edf52?t=1574879755720'
)

docker run -v $(pwd)/validate:/data \
  geodetischeinfrastructuur/pyproj:3.6.1 \
  python /data/transform_csv.py /data/002_ETRS89.txt /data/002_ETRS89_transformed.txt

docker run -v $(pwd)/validate:/data \
  geodetischeinfrastructuur/pyproj:3.6.1 \
  python /data/transform_csv.py /data/002_RDNAP.txt /data/002_RDNAP_transformed.txt
```

Upload de gegeneerde bestanden bij de [validatieservice](https://www.nsgi.nl/coordinatenstelsels-en-transformaties/tools/validatieservice). Score moet voor *Nederland+EEZ* 100% zijn.

## Zelf validatie met Z001_ETRS89andRDNAP.txt

Validate bestand `Z001_ETRS89andRDNAP.txt` bevat voor bekende punten correcte coordinaten voor zowel ETRS89 als RDNAP. Het volgende script transformeert voor deze punten zowel de ETRS89 als de RDNAP coordinaten. Vervolgens wordt ook de afwijking van getransformeerde coordinaten ten op zichte van de bekende coordinateen voor dat punt bepaalt (per CRS).

```bash
docker run -d --rm -v `pwd`/validate:/validate geodetischeinfrastructuur/pyproj:3.6.1 python ./validate/validate.py ./validate/Z001_ETRS89andRDNAP.txt ./validate/validation-output.csv
```

Dit moet een `validate/validation-output.csv` bestand opleveren. Indien correct dan hebben de getransformeerde coordinaten een minimale afwijking ten opzichte van de bekende coordinaten.