import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/screens/login/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 240, 244, 248),
        body: Stack(
          // POSICIONAR ELEMENTOS UNO ENCIMA DEL OTRO
          children: [
            _backgroundCover(context),
            _boxForm(context),
            Column(
              // POSICIONAR ELEMENTOS UNO DEBAJO DEL OTRO (VERTICAL)
              children: [_imageCover()],
            ),
          ],
        ),
      ),
    );
  }

  Widget _backgroundCover(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.37,
      color: const Color.fromARGB(255, 45, 70, 40),
    );
  }

  Widget _boxForm(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.34,
            left: 33,
            right: 33),
        height: MediaQuery.of(context).size.height * 0.49,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                  color: Color.fromARGB(51, 0, 0, 0),
                  blurRadius: 15,
                  offset: Offset(0, 0.75))
            ],
            border: Border.all(
              color: const Color.fromARGB(255, 200, 200, 200),
              width: 3,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(15))),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              _textYourInfo(),
              _textFieldEmail(),
              _textFieldPassword(),
              const SizedBox(height: 20),
              _buttonLogin()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttonLogin() {
    return Container(
      margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
      child: ElevatedButton(
        onPressed: () {
          controller.login();
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: const Text(
          'Iniciar sesión',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }

  Widget _textFieldEmail() {
    return Container(
      margin: const EdgeInsets.only(top: 30, left: 30, right: 30),
      child: TextField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          hintText: 'Correo electrónico',
          icon: Icon(Icons.email, color: Color.fromARGB(255, 128, 128, 128)),
          labelText: 'Correo electrónico',
          labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0))),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0))),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0))),
        ),
      ),
    );
  }

  Widget _textFieldPassword() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
      child: TextField(
        controller: controller.passwordController,
        obscureText: true,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Contraseña',
          icon: Icon(Icons.lock, color: Color.fromARGB(255, 128, 128, 128)),
          labelText: 'Contraseña',
          labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0))),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0))),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0))),
        ),
      ),
    );
  }

  Widget _textYourInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: const Text(
        'Ingresa tus datos',
        style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }

  Widget _imageCover() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 50, bottom: 15),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/logo-white.png',
          width: 180,
          height: 180,
        ),
      ),
    );
  }
}
