import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsProvider extends GetConnect {
  String url = Environment.apiUrl;

  // OBTENER LA LISTA DE EVENTOS DE UNA MATERIA-CURSO
  Future<List> getSubjectEvents(int subjectId, {int? studentId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    final queryParams = {
      'subject_id': subjectId.toString(),
      if (studentId != null)
        'student_id':
            studentId.toString(), // Agregar student_id si es apoderado
      if (studentId == null && userId != null)
        'user_id': userId, // Usar user_id si es estudiante
    };

    Response response = await get('$url/api/subject/events', query: queryParams);
    if (response.statusCode == 200) {
      print('Imprimiendo response.body: ${response.body}');
      return response.body;
    } else {
      return [];
    }
  }

  // OBTENER LOS DETALLES DE UN EVENTO DETERMINADO
  Future<Map<String, dynamic>> getEventDetail(int eventId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Obtener el token
    print('Token in getEventDetail: $token'); // Imprime el token para verificar

    if (token == null) {
      print('Token is missing');
      return {};
    }

    print('Fetching details for eventId: $eventId');
    Response response = await get(
      '$url/api/event/detail',
      query: {'event_id': eventId.toString()},
      headers: {
        'Authorization': 'Bearer $token', // Incluir el token en el encabezado
      },
    );

    if (response.statusCode == 200) {
      print('Event detail response: ${response.body}');
      return response.body;
    } else {
      print(
          'Failed to fetch event detail, status code: ${response.statusCode}');
      return {};
    }
  }

  // Nueva función para registrar la visualización del evento
  Future<void> registerEventView(int eventId, String userClass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    //int? userId = prefs.getInt('user_id');
    int? userId = int.tryParse(prefs.getString('user_id') ?? '');
    String? userName = prefs.getString('user_name');
    //String? userClass = prefs.getString('model_name');

    print("Intentando registrar visualización del evento $eventId");
    print("token: $token");
    print("userId: $userId");
    print("userName: $userName");
    print("userClass: $userClass");

    if (token == null || userId == null || userName == null) {
      print(
          "Información del usuario faltante para registrar la visualización.");
      return;
    }

    final payload = {
      'user_id': userId,
      'user_name': userName,
      'user_class': userClass,
      'event_id': eventId,
    };

    try {
      Response response = await post(
        '$url/api/event/register_view',
        payload,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Registro de visualización de evento exitoso.");
      } else {
        print(
            "Fallo en el registro de visualización de evento: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al registrar visualización del evento: $e");
    }
  }
}
