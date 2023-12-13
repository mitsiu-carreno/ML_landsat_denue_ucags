import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geovisor/infoLatLong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  int init = 0;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<Map<String, dynamic>> coordenadasYPredicciones = [];

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Geovisor"),
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
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: _goToUniversity,
                            child: const Text('Ir a la Universidad'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: _goToINEGI,
                            child: const Text('Ir al INEGI'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: _resetLocation,
                            child: const Text(
                              'Restablecer Zoom',
                              textAlign: TextAlign.center,
                            ),
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
                          child: DataTable(
                            columns: const <DataColumn>[
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    'Coordenadas Seleccionadas',
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Predicción',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                            rows: (coordenadasYPredicciones.isNotEmpty)
                                ? List<DataRow>.generate(
                                    coordenadasYPredicciones.length,
                                    (index) => DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Text(
                                            'Latitud: ${coordenadasYPredicciones[index]['latitud']}\nLongitud: ${coordenadasYPredicciones[index]['longitud']}',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            coordenadasYPredicciones[index]
                                                ['prediccion'],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : [
                                    const DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Text(
                                            'No hay coordenadas seleccionadas',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        DataCell(
                                          Text(''),
                                        ),
                                      ],
                                    ),
                                  ],
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

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _markers
          .removeWhere((marker) => marker.markerId.value == 'tapped_location');

      _markers.add(
        Marker(
          markerId: const MarkerId('tapped_location'),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Localización Seleccionada.'),
        ),
      );

      latitud = latLng.latitude.toString();
      longitud = latLng.longitude.toString();

      setState(() {
        prediccion = "Holi";
        coordenadasYPredicciones.add({
          'latitud': latitud,
          'longitud': longitud,
          'prediccion': prediccion,
        });
      });
      _gotoLocation();
    });
  }

  void cleanLatLon() {
    setState(() {
      latitud = "";
      longitud = "";
    });
  }
}
