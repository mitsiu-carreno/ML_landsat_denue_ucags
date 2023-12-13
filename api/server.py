# Start server: flask --app server run
# Demo request: http://localhost:5000/predict?lat=21.906992&lon=-102.309807

from flask import Flask, request, abort
from tensorflow import keras
import rasterio
from shapely.geometry import Point
from pyproj import Proj, Transformer
import numpy as np
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
model = keras.models.load_model("assets/geo_recortes.keras")
ruta_landsat_tiff = "assets/imagen.tif"


@app.route("/")
def hello_world():
    return "<p>Usage:</br>url/predict?lat=&lt;XXXX:float&gt;&lon=&lt;YYYY:float&gt;</p>"


@app.route("/predict", methods=["GET"])
def search():
    args = request.args
    lat = args.get("lat")
    lon = args.get("lon")
    print(lon)

    if None in (lat, lon):
        abort(400)

    try:
        lat = float(lat)
        lon = float(lon)
    except (ValueError, TypeError):
        abort(406)

    col_pixel, row_pixel = GetPixelFromCoords(lat, lon)

    ## ToDo Validate that lat, lon exists in image

    cutout = GetImageCutout(col_pixel, row_pixel)

    result = Predict(cutout)[0]

    print(result)
    print(result.shape)
    
    ## ToDO Integrar "SCIAN_2023124_141359987.xlsx" (ref notebook de Andrea) para mostrar labels entendibles

    #return [col_pixel, row_pixel]
    return {index[0]: str(v) for index, v in np.ndenumerate(result)}


@app.errorhandler(400)
def bad_request(e):
    # note that we set the 404 status explicitly
    return (
        "<h1>Missing parameters</h1><p>You <strong>must</strong> specify lat and lon</p></br><p>Usage:</br>url/predict?lat=&lt;XXXX:float&gt;&lon=&lt;YYYY:float&gt;</p>",
        400,
    )


@app.errorhandler(406)
def not_acceptable(e):
    return (
        "<h1>Wrong parameters</h1><p>Lat and lon parameters should be <strong>numeric</strong> values</p></br><p>Usage:</br>url/predict?lat=&lt;XXXX:float&gt;&lon=&lt;YYYY:float&gt;</p>",
        406,
    )


def GetPixelFromCoords(lat, lon):
    with rasterio.open(ruta_landsat_tiff) as src:
        srs_raster = src.crs.to_proj4()

    # xy = zip(lon, lat)
    geometry = Point(lon, lat)

    srs_gdf = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    transformador = Transformer.from_proj(Proj(srs_gdf), Proj(srs_raster))

    geometry2 = Point(transformador.transform(geometry.x, geometry.y))

    with rasterio.open(ruta_landsat_tiff) as src:
        col_pixel, row_pixel = src.index(geometry2.x, geometry2.y)

    return col_pixel, row_pixel


def GetImageCutout(col, row, size=3):
    _5p = np.empty([5, 5, 6])
    _3p = np.empty([3, 3, 6])
    with rasterio.open(ruta_landsat_tiff) as src:
        # 5 Pixels
        for sub_row in range(0, 5):
            for sub_col in range(0, 5):
                _5p[sub_row][sub_col] = src.read(
                    window=(
                        (row + (sub_row - 2), row + (sub_row - 1)),
                        (col + (sub_col - 2), col + (sub_col - 1)),
                    )
                ).reshape(_5p.shape[-1:])
    _3p = _5p[1:4, 1:4, :]

    return _3p


def Predict(cutout):
    cutout = cutout.reshape(1, 3, 3, 6)
    return model.predict(cutout)



if __name__ == "__main__":
    app.run(host='0.0.0.0')
