import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geovisor/infoLatLong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class Mapita extends StatefulWidget {
  const Mapita({super.key});

  @override
  State<StatefulWidget> createState() => _MapitaState();
}

class _MapitaState extends State<Mapita> {
  String latitud = "";
  String longitud = "";
  dynamic prediccion;
  bool coordenadasSeleccionadas = false;
  bool _mapaInteractivo = true;
  int init = 0;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<Map<String, dynamic>> coordenadasYPredicciones = [];

  final Logger _logger = Logger('_MapitaState');

  static const CameraPosition _kUniversidad = CameraPosition(
    target: LatLng(21.881715418726223, -102.30074117088638),
    zoom: 17,
  );

  static const CameraPosition _kInegi = CameraPosition(
    target: LatLng(21.857203725938653, -102.28347478635189),
    zoom: 17,
  );

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('universidad'),
      position: LatLng(21.881715418726223, -102.30074117088638),
      infoWindow:
          InfoWindow(title: 'Universidad de la Ciudad de Aguascalientes'),
    ),
    const Marker(
      markerId: MarkerId('inegi'),
      position: LatLng(21.857203725938653, -102.28347478635189),
      infoWindow:
          InfoWindow(title: 'Instituto Nacional de Estadística y Geografía'),
    )
  };
  @override
  Widget build(BuildContext context) {
    _setupLogging();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Geovisor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              _mostrarDialogoDeGuia(context);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: GoogleMap(
              onTap: _onMapTapped,
              mapType: MapType.hybrid,
              initialCameraPosition: _kUniversidad,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[200],
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                            InfoLatLong(Latitude: latitud, Longitude: longitud),
                      ),
                    ],
                  ),
                  Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _goToUniversity,
                          child: const Text('Ir a la Universidad'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _goToINEGI,
                          child: const Text('Ir al INEGI'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _resetLocation,
                          child: const Text(
                            'Restablecer Zoom',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: (coordenadasYPredicciones.isNotEmpty)
                                ? coordenadasYPredicciones.length
                                : 1,
                            itemBuilder: (context, index) {
                              if (coordenadasYPredicciones.isEmpty) {
                                return const ListTile(
                                  title:
                                      Text('No hay coordenadas seleccionadas'),
                                );
                              }

                              final coordenadas =
                                  coordenadasYPredicciones[index];

                              return Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const ListTile(
                                      title: Text(
                                        'Coordenadas:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: Text(
                                        'Latitud: ${coordenadas['latitud']}',
                                      ),
                                      subtitle: Text(
                                        'Longitud: ${coordenadas['longitud']}',
                                      ),
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Predicción:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(coordenadas['prediccion']),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función para centrar el mapa en la posición de la Universidad
  Future<void> _goToUniversity() async {
    init = 1;
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kUniversidad));
    cleanLatLon();
  }

  // Función para centrar el mapa en la posición del INEGI
  Future<void> _goToINEGI() async {
    init = 2;
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kInegi));
    cleanLatLon();
  }

  Future<void> _resetLocation() async {
    if (latitud == "") {
      switch (init) {
        case 2:
          latitud = "21.857203725938653";
          longitud = "-102.28347478635189";
          break;
        case 1:
        default:
          latitud = "21.881715418726223";
          longitud = "-102.30074117088638";
          break;
      }
    }
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(double.tryParse(latitud)!, double.tryParse(longitud)!),
          zoom: 17,
        ),
      ),
    );
  }

  Future<void> _gotoLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(double.tryParse(latitud)!, double.tryParse(longitud)!),
          zoom: 20,
        ),
      ),
    );
  }

  void _onMapTapped(LatLng latLng) async {
    if (!_mapaInteractivo) {
      return; // Evitar acciones en el mapa si no es interactivo
    }
    latitud = latLng.latitude.toString();
    longitud = latLng.longitude.toString();
    final apiUrl = 'http://localhost:5000/predict?lat=$latitud&lon=$longitud';
    final response = await http.get(Uri.parse(apiUrl));

    setState(() {
      final markerId =
          MarkerId(DateTime.now().millisecondsSinceEpoch.toString());

      if (response.statusCode == 200) {
        final String data = response.body;
        setState(() {
          prediccion = data;
          coordenadasYPredicciones.add({
            'latitud': latitud,
            'longitud': longitud,
            'prediccion': prediccion,
          });
          coordenadasSeleccionadas = true;
        });
      } else {
        //_logger.severe('Error in the request to the API: ${response.statusCode}');
        _logger.severe('Error en la petición a la API: ${response.statusCode}');
        _logger.info('Cuerpo de la respuesta: ${response.body}');

        setState(() {
          prediccion = 'Error al obtener la predicción';
          coordenadasYPredicciones.add({
            'latitud': latitud,
            'longitud': longitud,
            'prediccion': 'Error al obtener la predicción',
          });
          coordenadasSeleccionadas = false;
        });
      }

      _markers.add(
        Marker(
          markerId: markerId,
          position: latLng,
          infoWindow: InfoWindow(title: prediccion),
        ),
      );
      _gotoLocation();
    });
  }

  void cleanLatLon() {
    setState(() {
      latitud = "";
      longitud = "";
    });
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  void _mostrarDialogoDeGuia(BuildContext context) {
    setState(() {
      _mapaInteractivo = false; // Deshabilitar interacción con el mapa
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Guía de Uso del Geovisor"),
          content: const Text(
            "Para obtener las posibles unidades económicas, bastará con solo dar un clic en el mapa presente en la interfaz principal.\n\n"
            "Tras esto, aparecerá una tarjetita a la derecha de la interfaz con la Latitud, Longitud y predicción del marcador agregado.\n\n"
            "Si se desea mover a otras áreas de trabajo, presione los botones para moverse a dos distintas localizaciones del mapa.\n\n"
            "Y por último, si se desea restablecer el zoom tras presionar el mapa, solo presione el botón de Restablecer Zoom.",
            style: TextStyle(fontSize: 16.0),
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    ).then((result) {
      Future.delayed(const Duration(milliseconds: 10), () {
        setState(() {
          _mapaInteractivo =
              true; // Habilitar interacción con el mapa después de un breve retraso
        });
      });
    });
  }
}
