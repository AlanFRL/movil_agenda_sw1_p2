import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersProvider extends GetConnect {
  String url = Environment.apiUrl;

  // Método para iniciar sesión
  Future<Response> login(String email, String password) async {
    Response response = await post(
      '$url/api/login',
      {'email': email, 'password': password},
      headers: {'Content-Type': 'application/json'},
    );

    return response;
  }

  // Método para obtener el nombre del usuario
  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('user_name');
    return userName ?? 'Usuario desconocido';
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      await post(
        '$url/api/logout',
        {},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Limpiar el token y otros datos almacenados en SharedPreferences
      await prefs.clear();

      // Redirigir al usuario a la página de inicio de sesión
      Get.offAllNamed('/');
    }
  }

  // Método para actualizar la foto de perfil
  Future<Response> updateUserPhoto(String base64Photo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      return Response(statusCode: 401, bodyString: "No token found");
    }

    final response = await post(
      '$url/api/update_photo',
      {'photo': base64Photo},
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response;
  }
}
