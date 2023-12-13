/* import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<String> fetchData() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      // Si la solicitud fue exitosa, devuelve el cuerpo de la respuesta
      return response.body;
    } else {
      // Si la solicitud falla, arroja una excepción
      throw Exception('Failed to load data');
    }
  }
} */
