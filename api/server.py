# Start server: flask --app server run
# Demo request: http://localhost:5000/predict?lat=21.906992&lon=-102.309807

from flask import Flask, request, abort
from tensorflow import keras
import rasterio
from shapely.geometry import Point
from pyproj import Proj, Transformer
import numpy as np
import pandas as pd
import geopandas as gpd
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
model = keras.models.load_model("assets/geo_recortes.keras")
ruta_landsat_tiff = "assets/imagen.tif"


### Prepare neighborhood data (denue)
with rasterio.open(ruta_landsat_tiff) as src:
    srs_raster = src.crs.to_proj4()


ruta_csv = "assets/denue.csv"
try:
    df = pd.read_csv(ruta_csv, encoding='utf-8')
except UnicodeDecodeError:
    # If 'utf-8' fails, try 'latin1' encoding
    df = pd.read_csv(ruta_csv, encoding='latin1')

# Selecciona las columnas deseadas
df_limpio = df[["codigo_act", "per_ocu", "latitud", "longitud"]].copy()
df_limpio["codigo_act"] = df_limpio["codigo_act"].astype(str).str.slice(0, 2)
df_limpio["codigo_act"] = df_limpio["codigo_act"].astype(float)
# Reemplaza los valores 32 y 33 por 31
df_limpio['codigo_act'].replace({32: 31, 33: 31}, inplace=True)

# Reemplaza el valor 49 por 48
df_limpio['codigo_act'].replace({49: 48}, inplace=True)

df_limpio = df_limpio.drop('per_ocu', axis=1)

# Crea una columna 'geometry' utilizando las columnas de latitud y longitud
geometry = [Point(xy) for xy in zip(df_limpio['longitud'], df_limpio['latitud'])]
df_limpio['geometry'] = geometry

# Convierte el DataFrame de pandas en un GeoDataFrame de GeoPandas
gdf = gpd.GeoDataFrame(df_limpio, geometry='geometry')


srs_gdf = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
transformador = Transformer.from_proj(Proj(srs_gdf), Proj(srs_raster))
gdf["geometry"] = gdf["geometry"].apply(lambda geom: Point(transformador.transform(geom.x, geom.y)))


import numpy as np
from sklearn.neighbors import NearestNeighbors

# Extrae las coordenadas de 'geometry' y conviértelas en un array numpy de forma vectorizada
coordinates = np.array([[geom.x, geom.y] for geom in gdf['geometry']])

# Crea un objeto NearestNeighbors para buscar los vecinos cercanos
k_neighbors = 5  # Número de vecinos cercanos que deseas considerar
neighbors = NearestNeighbors(n_neighbors=k_neighbors, algorithm='ball_tree', metric='haversine')
neighbors.fit(coordinates)

# Encuentra los vecinos cercanos para todas las filas en un solo paso
distances, indices = neighbors.kneighbors(coordinates)

# Preparar un DataFrame para los códigos de los vecinos
neighbor_codes_df = pd.DataFrame(index=gdf.index, columns=[f'surrounding_code_{i+1}' for i in range(k_neighbors)])

# Asignar los códigos de los vecinos a las nuevas columnas
for i in range(k_neighbors):
    neighbor_codes_df.iloc[:, i] = gdf.iloc[indices[:, i]]['codigo_act'].values

# Concatena las columnas nuevas al GeoDataFrame original
gdf = pd.concat([gdf, neighbor_codes_df], axis=1)

### End preparing neighborhood data


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


    resultado = latlon_to_gdf(lat, lon)

    # Extraer coordenadas x, y
    resultado['x'] = resultado['geometry'].x
    resultado['y'] = resultado['geometry'].y
    [coordenada_x,coordenada_y] = [resultado['x'][0],resultado['y'][0] ]

    #Encontrar vecinos cercanos
    neighbors_values = find_nearest_neighbors([coordenada_x,coordenada_y],gdf)

    # Diccionario dado
    diccionario = {0: 11.0, 1: 21.0, 2: 22.0, 3: 23.0, 4: 31.0, 5: 43.0, 6: 46.0, 7: 48.0, 8: 51.0, 9: 52.0, 10: 53.0, 11: 54.0, 12: 55.0, 13: 56.0, 14: 61.0, 15: 62.0, 16: 71.0, 17: 72.0, 18: 81.0, 19: 93.0}

    vectores_resultantes = crear_vectores(diccionario, neighbors_values)
    vectores_resultantes = np.array(vectores_resultantes).reshape(-1, 100)

    predicciones = model.predict(vectores_resultantes)

    # Encuentra el índice del valor más alto en cada predicción
    indice_predicciones = np.argmax(predicciones, axis=1)

    numeros_correspondientes = [obtener_numero_por_indice(diccionario, indice) for indice in indice_predicciones]
    diccionario_actividades = {
        11.0: "Agricultura, cría y explotación de animales, aprovechamiento forestal, pesca y caza",
        21.0: "Minería",
        22.0: "Generación, transmisión, distribución y comercialización de energía eléctrica, suministro de agua y de gas natural por ductos al consumidor final",
        23.0: "Construcción",
        31.0: "Industrias manufactureras",
        32.0: "Industrias manufactureras",
        33.0: "Industrias manufactureras",
        43.0: "Comercio al por mayor",
        46.0: "Comercio al por menor",
        48.0: "Transportes, correos y almacenamiento",
        49.0: "Transportes, correos y almacenamiento",
        51.0: "Información en medios masivos",
        52.0: "Servicios financieros y de seguros",
        53.0: "Servicios inmobiliarios y de alquiler de bienes muebles e intangibles",
        54.0: "Servicios profesionales, científicos y técnicos",
        55.0: "Dirección y administración de grupos empresariales o corporativos",
        56.0: "Servicios de apoyo a los negocios y manejo de residuos, y servicios de remediación",
        61.0: "Servicios educativos",
        62.0: "Servicios de salud y de asistencia social",
        71.0: "Servicios de esparcimiento culturales y deportivos, y otros servicios recreativos",
        72.0: "Servicios de alojamiento temporal y de preparación de alimentos y bebidas",
        81.0: "Otros servicios excepto actividades gubernamentales",
        93.0: "Actividades legislativas, gubernamentales, de impartición de justicia y de organismos internacionales y extraterritoriales"
    }
    actividad = diccionario_actividades.get(numeros_correspondientes[0], "No se encontró la actividad")

    return actividad

    #return {index[0]: str(v) for index, v in np.ndenumerate(result)}


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


def latlon_to_gdf(latitud, longitud):

    with rasterio.open(ruta_landsat_tiff) as src:
        srs_raster = src.crs.to_proj4()
    # Crea un DataFrame con una sola fila que contiene la latitud y longitud proporcionadas
    data = {'latitud': [latitud], 'longitud': [longitud]}
    df = pd.DataFrame(data)

    # Crea una columna 'geometry' utilizando las columnas de latitud y longitud
    geometry = [Point(xy) for xy in zip(df['longitud'], df['latitud'])]
    df['geometry'] = geometry

    # Crea un GeoDataFrame de GeoPandas
    gdf = gpd.GeoDataFrame(df, geometry='geometry')

        
    srs_gdf = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    transformador = Transformer.from_proj(Proj(srs_gdf), Proj(srs_raster))
    gdf["geometry"] = gdf["geometry"].apply(lambda geom: Point(transformador.transform(geom.x, geom.y)))  
    
    return gdf

def find_nearest_neighbors(input_coords, gdf, k_neighbors=5):
    # Extrae las coordenadas del gdf
    coordinates = np.array([[geom.x, geom.y] for geom in gdf['geometry']])

    # Crea e inicializa el objeto NearestNeighbors
    neighbors = NearestNeighbors(n_neighbors=k_neighbors, algorithm='ball_tree', metric='haversine')
    neighbors.fit(coordinates)

    # Encuentra los vecinos más cercanos para las coordenadas dadas
    distances, indices = neighbors.kneighbors([input_coords])

    # Extrae los códigos de actividad de los vecinos más cercanos
    neighbor_codes = gdf.iloc[indices[0]]['codigo_act'].values

    return neighbor_codes

def crear_vectores(diccionario, neighbors_values):
    # Inicializar la lista de vectores resultantes
    vectores_resultantes = []

    # Iterar sobre cada valor en neighbors_values
    for valor in neighbors_values:
        # Crear un vector de 20 ceros
        vector = [0] * 20

        # Buscar la clave en el diccionario que corresponda al valor actual
        clave = next((k for k, v in diccionario.items() if v == valor), None)

        # Si se encuentra la clave, poner un 1 en la posición correspondiente del vector
        if clave is not None:
            vector[clave] = 1

        # Extender la lista con los elementos del vector
        vectores_resultantes.extend(vector)

    return vectores_resultantes


def obtener_numero_por_indice(diccionario, indice):
    # Busca el valor en el diccionario usando el índice dado
    valor = diccionario.get(indice, None)
    return valor


if __name__ == "__main__":
    app.run(host='0.0.0.0')
