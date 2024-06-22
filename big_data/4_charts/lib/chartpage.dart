import 'package:charts/globalFunctions.dart';
import 'package:charts/holidays.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'api.dart';
import 'chartdata.dart';

List<String> states = [
  'Aguascalientes',
  'Baja California',
  //'Baja California Sur',
  'Campeche',
  'Chiapas',
  'Chihuahua',
  'Ciudad de México',
  'Coahuila',
  'Colima',
  'Durango',
  'Estado de México',
  'Guanajuato',
  'Guerrero',
  'Hidalgo',
  'Jalisco',
  'Michoacán',
  'Morelos',
  'Nayarit',
  'Nuevo León',
  'Oaxaca',
  'Puebla',
  'Querétaro',
  'Quintana Roo',
  'San Luis Potosí',
  'Sinaloa',
  'Sonora',
  'Tabasco',
  'Tamaulipas',
  'Tlaxcala',
  'Veracruz',
  'Yucatán',
  'Zacatecas',
];

List<String> years = ['2019', '2020', '2021', '2022'];

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<ChartData> chartData = [];
  String selectedState = 'Ciudad de México'; // Initial state
  String selectedYear = '2019'; // Initial year
  String selectedState_Copy = 'Ciudad de México'; // Initial state
  String selectedYear_Copy = '2019'; // Initial year
  List<Holidays> allHolidays = [];
  final TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);
  final TrackballBehavior _trackballBehavior = TrackballBehavior(
    enable: true,
    tooltipSettings: const InteractiveTooltip(
      enable: true,
      color: Colors.blue,
      borderColor: Colors.black,
      borderWidth: 1,
      format: 'point.x : point.y',
    ),
  );
  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    try {
      final data = await fetchData(selectedState, selectedYear);
      setState(() {
        chartData = data;
      });
      final holidays = await fetchHolidays(selectedYear);
      setState(() {
        allHolidays = holidays;
      });
      selectedState_Copy = selectedState;
      selectedYear_Copy = selectedYear;
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load chart data: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cantidad de Mensajes'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Campo de entrada para el estado
              DropdownButtonFormField<String>(
                value: selectedState,
                items: states.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      selectedState = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Estado',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedYear,
                items: years.map((String year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      selectedYear = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Año',
                ),
              ),
              const SizedBox(height: 20),

              //Botón para cargar el gráfico
              ElevatedButton(
                onPressed: _loadChartData,
                child: const Text('Cargar Gráfica'),
              ),
              const SizedBox(height: 20),

              // Widget del gráfico
              if (chartData.isNotEmpty)
                Expanded(
                  child: SfCartesianChart(
                    title: ChartTitle(
                        text:
                            "Cantidad de Mensajes por Mes en: $selectedState_Copy durante el año: $selectedYear_Copy"),
                    primaryXAxis: const CategoryAxis(
                      title: AxisTitle(text: 'Mes'),
                    ),
                    primaryYAxis: const NumericAxis(
                      title: AxisTitle(text: 'Tweets'),
                    ),
                    tooltipBehavior: _tooltipBehavior,
                    trackballBehavior: _trackballBehavior,
                    series: <CartesianSeries>[
                      LineSeries<ChartData, dynamic>(
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) =>
                            Globalfunctions.getMonthName(
                                int.tryParse(data.month)),
                        yValueMapper: (ChartData data, _) => data.conteo,
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        onPointTap: (ChartPointDetails args) {
                          final int month =
                              int.parse(chartData[args.pointIndex!].month);
                          _showEphemerisDialog(context, month);
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEphemerisDialog(BuildContext context, int month) {
    final ephemerides =
        allHolidays.where((holiday) => holiday.month == month).toList();
    dynamic mes = Globalfunctions.getMonthName(month);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Efemérides del Mes de $mes'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ephemerides.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(ephemerides[index].name),
                  subtitle: Text(
                      '${ephemerides[index].day}/${ephemerides[index].month}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
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
