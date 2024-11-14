import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CuestionariosProvider extends GetConnect {
  final String url = Environment.apiUrl;

  // Método para obtener los cuestionarios de un estudiante
  Future<List> getCuestionarios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      return [];
    }

    final queryParams = {'user_id': userId};
    print(
        'Intentando obtener los cuestionarios para estudiante con ID $userId');

    Response response = await get('$url/api/cuestionarios', query: queryParams);
    if (response.statusCode == 200) {
      print('Imprimiendo response.body: ${response.body}');
      return response.body;
    } else {
      return [];
    }
  }

  // OBTENER LOS DETALLES DE UN CUESTIONARIO
  Future<Map<String, dynamic>> getCuestionarioDetalle(
      int cuestionarioId) async {
    print('MANDANDO SOLICITUD A LA API PARA LOS DETALLES DEL CUESTIOANRIO');
    print('IMPRIMIENDO ID: $cuestionarioId');
    final queryParams = {'cuestionario_id': cuestionarioId.toString()};
    Response response =
        await get('$url/api/cuestionario_detalle', query: queryParams);
    print('DESPUÉS DE LA LLAMADA');
    if (response.statusCode == 200) {
      print('Imprimiendo response.body ${response.body}');
      return response.body;
    } else {
      print(
          'Error obteniendo detalles del cuestionario: ${response.statusText}');
      return {};
    }
  }

  // Método para finalizar el cuestionario en el servidor
  Future<bool> finalizarCuestionario(
      int cuestionarioId, Map<int, String> respuestasSeleccionadas) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Asegurarse de que todas las respuestas estén en formato String
    final Map<String, String> respuestasFormateadas = respuestasSeleccionadas
        .map((key, value) => MapEntry(key.toString(), value.toString()));

    final payload = {
      'cuestionario_id': cuestionarioId.toString(),
      'respuestas': respuestasFormateadas,
    };

    final response = await post(
      '$url/api/finalizar_cuestionario',
      payload,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }
}
