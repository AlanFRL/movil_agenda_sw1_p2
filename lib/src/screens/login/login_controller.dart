import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/providers/users_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UsersProvider usersProvider = UsersProvider();

  Future<void> login() async {
    String email = emailController.text.trim();
    print('Imprimiendo email en login:  $email');
    String password = passwordController.text.trim();
    print('Imprimiendo email en password:  $password');

    if (isValidForm(email, password)) {
      Response response = await usersProvider.login(email, password);
      print('Imprimiendo response.statusCode:  ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        print('Imprimiendo responseBody:  $responseBody');

        if (responseBody.containsKey('error')) {
          Get.snackbar(
            'Error de Login',
            responseBody['error'],
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', responseBody['token']);
          await prefs.setString('user_id', responseBody['user_id'].toString());
          await prefs.setString('model_name', responseBody['model_name']);
          //await prefs.setString('user_name', responseBody['user_name']);
          await prefs.setString('user_name', responseBody['user_name'] ?? 'Usuario desconocido');
          await prefs.setString('email', responseBody['email']);
          await prefs.setString('ci', responseBody['ci'] ?? '');
          await prefs.setString('telefono', responseBody['telefono'] ?? '');
          await prefs.setString('sexo', responseBody['sexo'] ?? '');
          await prefs.setString('curso', responseBody['curso'] ?? '');
          await prefs.setString('student_code', responseBody['student_code'] ?? '');
          await prefs.setString('birth_date', responseBody['birth_date'] ?? '');
          await prefs.setString('user_photo', responseBody['user_photo'] ?? '');
          await prefs.setString('qr_code', responseBody['qr_code'] ?? '');
          print('LOGIN DETALLES response: ${response.body}');

          Get.toNamed('/home');
        }
      } else {
        Get.snackbar(
          'Error de Login',
          'Por favor vuelve a intentarlo',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  bool isValidForm(String email, String password) {
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Email no válido',
        'Por favor ingrese un email válido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Formulario no válido',
        'Por favor ingrese todos los campos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }
}
