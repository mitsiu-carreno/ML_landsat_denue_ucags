import 'dart:convert';
import 'package:charts/holidays.dart';
import 'package:http/http.dart' as http;

import 'chartdata.dart';

Future<List<ChartData>> fetchData(String state, String year) async {
  final Uri url = Uri.parse('http://127.0.0.1:5000/get_data_by_year');

  try {
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'estado': state,
        'año': year,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((dynamic item) => ChartData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch chart data: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to fetch chart data: $e');
  }
}

Future<List<Holidays>> fetchHolidays(dynamic year) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:5000/get_holidays_by_year'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'año': year,
    }),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Holidays.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load holidays');
  }
}
