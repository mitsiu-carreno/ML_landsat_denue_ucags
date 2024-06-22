import 'package:charts/chartpage.dart';
import 'package:charts/entidad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:geojson_vi/geojson_vi.dart';

import 'api.dart';

Future<String> loadJsonData() async {
  // Lee el archivo JSON
  final jsonFile = await rootBundle.loadString('mexicoHigh.json');

  // Retorna el contenido como String
  return jsonFile;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/second': (context) => const ChartPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Mapa Mensajes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double currentZoom = 5;
  List<Polygon> polygons = [];
  List<Entidad> chartData = [];
  Map<String, Entidad> apiData = {};
  MapController mapController = MapController();
  LatLng currentCenter = const LatLng(21.882976289200855, -102.2944978103986);
  String selectedMonth = '02'; // Initial state
  String selectedYear = '2019';
  GeoJsonParser geoJsonParser = GeoJsonParser(
    defaultMarkerColor: Colors.red,
    defaultPolygonBorderColor: Colors.red,
    defaultPolygonFillColor: Colors.red.withOpacity(0.1),
    defaultCircleMarkerColor: Colors.red.withOpacity(0.25),
  );

  bool loadingData = false;

  void _zoom() {
    currentZoom = currentZoom - 1;
    mapController.move(currentCenter, currentZoom);
  }

  String _normalizeName(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâã]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n');
  }

  void _showStateDialog(String stateName) {
    final normalizedStateName = _normalizeName(stateName);
    if (apiData.containsKey(normalizedStateName)) {
      final data = apiData[normalizedStateName];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Información del Estado'),
            content: Text(
                'Estado: ${stateName.contains("México") && stateName != "Ciudad de México" ? "Estado de México" : stateName}\nMensajes: ${data?.mensajes}\n'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  bool myFilterFunction(Map<String, dynamic> properties) {
    if (properties['section'].toString().contains('Point M-4')) {
      return false;
    } else {
      return true;
    }
  }

  Color getColorBasedOnMessages(int messages) {
    if (messages > 50000) {
      return Colors.red;
    } else if (messages > 20000) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // this is callback that gets executed when user taps the marker
  void onTapMarkerFunction(Map<String, dynamic> map) {
    // ignore: avoid_print
    print('onTapMarkerFunction: $map');
  }

  Future<void> processData() async {
    // parse a small test geoJson
    // normally one would use http to access geojson on web and this is
    // the reason why this funcyion is async.
    geoJsonParser.parseGeoJsonAsString(await loadJsonData());
  }

  Future<void> _loadMapData() async {
    try {
      final jsonString = await loadJsonData();
      final data = await fetchDataPerMonth(selectedYear, selectedMonth);
      apiData = Map.fromEntries(
          data.map((item) => MapEntry(_normalizeName(item.name), item)));
      /* for (var item in data) {
        final normalizedStateName = _normalizeName(item.name);
        for (var item in data) {
          apiData[_normalizeName(item.name)] = item;
        }
      } */
      setState(() {
        chartData = data;
      });
      final geoJson = jsonDecode(jsonString);
      GeoJSON geo = GeoJSON.fromJSON(jsonString);
      List<Polygon> parsedPolygons = [];
      for (var feature in geoJson['features']) {
        String stateName = feature['properties']['name'];
        var geometry = feature['geometry'];
        var coordinates = feature['geometry']['coordinates'][0];
        var geometryType = feature['geometry']['type'];
        List<LatLng> points = [];
        List<List<List<LatLng>>> coordinate = [];
        if (geometryType == "Polygon") {
          for (var coord in coordinates) {
            if (coord.length >= 2 && coord[0] is num && coord[1] is num) {
              double lng = coord[0].toDouble();
              double lat = coord[1].toDouble();
              points.add(LatLng(lat, lng));
            }
          }
        } else {
          var polygons = geometry['coordinates'];
          for (var polygon in polygons) {
            List<LatLng> polygonPoints = [];
            // Iterar sobre cada anillo del polígono
            for (var ring in polygon) {
              for (var coord in ring) {
                if (coord.length >= 2 && coord[0] is num && coord[1] is num) {
                  double lng = coord[0].toDouble();
                  double lat = coord[1].toDouble();
                  polygonPoints.add(LatLng(lat, lng));
                }
              }
              // Añadir el anillo como un polígono separado
              if (polygonPoints.isNotEmpty) {
                parsedPolygons.add(
                  Polygon(
                    points: polygonPoints,
                    color: getColorBasedOnMessages(
                        apiData[_normalizeName(stateName)]?.mensajes ?? 0),
                    borderColor: Colors.black,
                    borderStrokeWidth: 2.0,
                    isFilled: true,
                    label: stateName,
                  ),
                );
              }
            }
          }
        }
        final normalizedStateName = _normalizeName(stateName);
        final color = apiData.containsKey(normalizedStateName)
            ? getColorBasedOnMessages(apiData[normalizedStateName]?.mensajes)
            : Colors.grey;
        if (points.isNotEmpty) {
          parsedPolygons.add(
            Polygon(
              points: points,
              color: color, // Example color
              borderColor: Colors.black, // Example border color
              borderStrokeWidth: 2.0,
              isFilled: true,
              // Assuming Polygon has a label property to hold the state name
              label: stateName,
            ),
          );
        }
      }
      setState(() {
        loadingData = false;
        polygons = parsedPolygons;
        apiData = apiData;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load map data: $e'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _handleTap(LatLng latLng) {
    for (var polygon in polygons) {
      if (_isPointInPolygon(latLng, polygon.points)) {
        final stateName = polygon.label ?? '';
        _showStateDialog(stateName);
        break;
      }
    }
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if ((polygon[j].latitude > point.latitude) !=
              (polygon[j + 1].latitude > point.latitude) &&
          point.longitude <
              (polygon[j + 1].longitude - polygon[j].longitude) *
                      (point.latitude - polygon[j].latitude) /
                      (polygon[j + 1].latitude - polygon[j].latitude) +
                  polygon[j].longitude) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }

  @override
  void initState() {
    geoJsonParser.setDefaultMarkerTapCallback(onTapMarkerFunction);
    geoJsonParser.filterFunction = myFilterFunction;
    loadingData = true;
    Stopwatch stopwatch2 = Stopwatch()..start();
    processData().then((_) {
      setState(() {
        loadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GeoJson Processing time: ${stopwatch2.elapsed}'),
          duration: const Duration(milliseconds: 5000),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    });
    super.initState();
    _loadMapData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Row(
            children: [
              const Text('Seleccione el año: '),
              DropdownButton<String>(
                value: selectedYear,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedYear = newValue!;
                  });
                },
                items: <String>['2019', '2020', '2021', '2022']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(width: 20),
              const Text('Seleccione el mes: '),
              DropdownButton<String>(
                value: selectedMonth,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMonth = newValue!;
                  });
                },
                items: <String>[
                  '01 - Enero',
                  '02 - Febrero',
                  '03 - Marzo',
                  '04 - Abril',
                  '05 - Mayo',
                  '06 - Junio',
                  '07 - Julio',
                  '08 - Agosto',
                  '09 - Septiembre',
                  '10 - Octubre',
                  '11 - Noviembre',
                  '12 - Diciembre'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value.substring(0, 2), // Solo el número del mes
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    loadingData = true;
                  });
                  _loadMapData();
                },
                child: const Text('Cargar Datos'),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: const LatLng(21.882976289200855, -102.2944978103986),
          //center: LatLng(45.720405218, 14.406593302),
          initialZoom: 5,
          onTap: (tapPosition, latLng) =>
              _handleTap(latLng), // Handle tap on the map
        ),
        children: [
          TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c']),
          //userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          loadingData
              ? const Center(child: CircularProgressIndicator())
              : PolygonLayer(
                  polygons: polygons,
                ),
          if (!loadingData) PolylineLayer(polylines: geoJsonParser.polylines),
          if (!loadingData) MarkerLayer(markers: geoJsonParser.markers),
          if (!loadingData) CircleLayer(circles: geoJsonParser.circles),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/second');
        },
        tooltip: 'Ir a la Gráfica',
        child: const Icon(Icons.access_time),
      ),
    );
  }
}
