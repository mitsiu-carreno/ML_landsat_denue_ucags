# Structure

# Contenedores

IMPORTANTE: `podman-compose` y `docker-compose` pueden intercambiarse según el software instalado

## Levantar todos los servicios (model, api, front)
```bash
podman-compose up
```

## Detener contenedor(es)
Para detener cualquier contenedor básta con teclear `ctrl + c` o `ctrl + shift + c` 

## Levantar contenedor model (Jupyter notebook con red neuronal)
```bash
podman-compose up model
```
El comando generará una salida como la siguiente:
![podman-compose up model outut](./container-model.png "podman-compose up model output")
y puedes copiar y pegar la url seleccionada en tu navegador

## Levantar contenedor api (Flask api con predicciones)
```bash
podman-compose up api
```
Cuando termine de levantarse el contenedor puedes acceder a la ruta:
`http://localhost:5000/predict?lat=21.906992&lon=-102.309807`
desde tu navegador

## Editar código y que se refleje en contenedores
### Model
Basta con editar desde jupyter (en el navegador) y los cambios se reflejarán en los archivos del repositorio

### Api
Lo más sencillo es editar los documentos en el repositorio y bajar (`podman-compose down api`) y volver a levantar (`podman-compose up api`) para ver los cambios realizados

## Generar nuevo .keras (no interactivo)
Primero debemos entrar al contenedor (en un shell distinto al que esta corriendo el contenedor) con el siguiente comando
```bash
podman exec -it ml_landsat_denue_ucags_model_1 bash
```
Una vez dentro del contenedor podemos correr el comando
```bash
jupyter nbconvert --to notebook --inplace --execute neural_net.ipynb
```
Cuándo haya terminado el nuevo .keras estará en la ruta `model/output_model/geo_recortes.keras`
