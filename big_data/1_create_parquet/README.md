# Procedimiento:
1. Una vez descargados todos los .zip y .tar es necesario tenerlos descomprimidos en carpetas por año, esto se puede lograr con el comando:
```bash
unzip “./zips_2021/*.zip” -d ./jsons_2021
```
o
```bash
find -name *.tar -exec tar -xvf {} -d ./jsons_2021 \; 
```
2. Se debe tener en una misma carpeta todos los jsons correspondientes a un mismo año (ej. ./jsons_2021/twitter-2021.07.10.json, ./jsons_2021/twitter-2021.07.11.json, …)
3. Se deben settear las siguientes variables:
    - year=2021  # Correspondiente al año a procesar
    - input_json_path="./jsons_2021/"  # Correspondiente a la ruta con los jsons
    - output_json_path="./full_2021.json"  # Correspondiente a la ruta y archivo a generar
4. Ejecutar el script trim_json.sh
```bash
./trim_json.sh
```
Al finalizar deberá existir el archivo definido en `output_json_path` con los json correspondiente al país de México 
5. Para transformar del json generado al formato parquet se ejecuta el script full_json_handler.py con el path al json
```bash
python full_json_handler.py ./data/full_2021.json
```

