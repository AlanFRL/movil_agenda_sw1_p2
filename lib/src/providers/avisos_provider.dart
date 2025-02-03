import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AvisosProvider extends GetConnect {
  String url = Environment.apiUrl;

  // OBTENER LA LISTA DE AVISOS A LOS QUE EL APODERADO ES OBJETIVO
  Future<List> getGuardianAvisos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      return [];
    }

    final queryParams = {'user_id': userId};

    Response response =
        await get('$url/api/guardian/avisos', query: queryParams);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return [];
    }
  }

  // Obtener detalles de un aviso específico
  Future<Map<String, dynamic>> getAvisoDetalle(int avisoId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id'); // Obtener user_id

    // Verificar que userId no sea null antes de hacer la solicitud
    if (userId == null) {
      return {};
    }

    Response response = await get(
      '$url/api/aviso/detalle',
      query: {
        'aviso_id': avisoId.toString(),
        'user_id': userId
      }, // Incluye user_id
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return {};
    }
  }

  // Función para actualizar la asistencia en Odoo
  Future<bool> actualizarAsistencia(int avisoId, int apoderadoId) async {
    final formData = FormData({
      'aviso_id': avisoId.toString(),
      'apoderado_id': apoderadoId.toString(),
    });

    final response = await post(
      '$url/api/actualizar_asistencia',
      formData,
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;
      if (responseBody['success'] == true) {
        print("Asistencia actualizada exitosamente en Odoo.");
        return true;
      } else {
        print("Error al actualizar asistencia: ${responseBody['message']}");
      }
    } else {
      print(
          "Error en la solicitud de actualización de asistencia: ${response.statusCode}");
    }
    return false;
  }

  // Nueva función para registrar la visualización del aviso
  Future<void> registerAvisoView(int avisoId, String userClass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    //int? userId = prefs.getInt('user_id');
    int? userId = int.tryParse(prefs.getString('user_id') ?? '');
    String? userName = prefs.getString('user_name');
    //String? userClass = prefs.getString('model_name');

    print("Intentando registrar visualización del aviso $avisoId");
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
      'aviso_id': avisoId,
    };

    try {
      Response response = await post(
        '$url/api/aviso/register_view',
        payload,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Registro de visualización de aviso exitoso.");
      } else {
        print(
            "Fallo en el registro de visualización de aviso: ${response.statusCode}");
      }
    } catch (e) {
      print("Error al registrar visualización del aviso: $e");
    }
  }
}
