import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static Future<String?> getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('model_name');  // Recupera el tipo de usuario (estudiante o apoderado)
  }

  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');  // Recupera el ID de usuario
  }
}
