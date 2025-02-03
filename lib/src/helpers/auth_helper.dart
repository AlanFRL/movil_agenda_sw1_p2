import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';
import 'dart:convert'; // Import necesario para jsonEncode

class AuthHelper {
  static Future<String?> getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('model_name');  // Recupera el tipo de usuario (estudiante o apoderado)
  }

  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');  // Recupera el ID de usuario
  }

 static Future<void> registerFcmToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id'); // Recuperar el user_id
  if (userId != null) {
    final response = await GetConnect().post(
      '${Environment.apiUrl}/api/register_fcm_token',
      jsonEncode({'token': token, 'user_id': userId}), // Enviar token y user_id
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      print('FCM Token registrado correctamente en Odoo');
    } else {
      print('Error al registrar el FCM Token: ${response.body}');
    }
  } else {
    print('Error: No se encontró el user_id en SharedPreferences');
  }
}
}
