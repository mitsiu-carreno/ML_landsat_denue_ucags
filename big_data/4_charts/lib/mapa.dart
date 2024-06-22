import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'entidad.dart';

/* Future<void> processData() async {
  final geoJsonString = await rootBundle.loadString('assets/your_geojson.json');
  geoJsonParser.parseGeoJsonAsString(geoJsonString);
}

 */
/* import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MensajesMapWidget extends StatefulWidget {
  final String year;
  final String month;

  const MensajesMapWidget({required this.year, required this.month});

  @override
  _MensajesMapWidgetState createState() => _MensajesMapWidgetState();
}

class _MensajesMapWidgetState extends State<MensajesMapWidget> {
  List<Marker> markers = [];
  Map<String, dynamic>? geoJson;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://your_api_endpoint/mensajes?year=${widget.year}&month=${widget.month}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        markers = data.map((estado) {
          final LatLng position = _getLatLngForState(estado['estado']);
          return Marker(
            width: 80.0,
            height: 80.0,
            point: position,
            child: Column(
              children: [
                Text('${estado['cantidad_mensajes']}'),
                Icon(Icons.location_on, color: Colors.red, size: 40.0),
              ],
            ),
          );
        }).toList();
      });

      // Fetch the GeoJSON data
      final geoJsonResponse =
          await http.get(Uri.parse('assets/geojson/your_geojson_file.geojson'));
      if (geoJsonResponse.statusCode == 200) {
        setState(() {
          geoJson = json.decode(geoJsonResponse.body);
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  LatLng _getLatLngForState(String state) {
    // Implementar una función para obtener LatLng de acuerdo al estado
    // Esto podría ser un mapa predefinido de estado a LatLng
    Map<String, LatLng> statePositions = {
      'ciudad de mexico': LatLng(19.432608, -99.133209),
      'estado de mexico': LatLng(19.35529, -99.63087),
      // Agregar otras posiciones de estados aquí
    };

    return statePositions[state.toLowerCase()] ?? LatLng(19.432608, -99.133209);
  }

  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(19.432608, -99.133209),
        initialZoom: 5.0,
      ),
      children: [
        TileLayerWidget(
          options: TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
        ),
        if (geoJson != null)
          GeoJsonWidget(
            options: GeoJsonOptions(
              data: geoJson!,
              style: (context, feature) {
                return Polygon(
                  color: Colors.blue.withOpacity(0.3),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                );
              },
            ),
          ),
        MarkerLayerWidget(
          options: MarkerLayerOptions(
            markers: markers,
          ),
        ),
      ],
    );
  }
}
 */

/* import 'package:charts/chartpage.dart';
import 'package:flutter/material.dart';
// Importamos el archivo donde definimos ChartPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      brightness: MediaQuery.platformBrightnessOf(context),
      seedColor: Colors.indigo,
    );
    return MaterialApp(
      title: 'Flutter Chart Example',
      theme: ThemeData(
        colorScheme: colorScheme,
      ),
      home:
          const ChartPage(), // Aquí especificamos que ChartPage será la página inicial
    );
  }
}
 */

 /* PolygonLayer(
                  polygons: geoJsonParser.polygons.map((polygon) {
                    final state = _normalizeName("Ags");
                    /*  final color = apiData.containsKey(state)
                        ? getColorBasedOnMessages(
                            apiData[state]['cantidad_mensajes'])
                        : Colors.grey; */
                    return Polygon(
                      points: polygon.points,
                      //color: color,
                      //borderColor: color,
                      isFilled: true,
                    );
                  }).toList(),
                ), */