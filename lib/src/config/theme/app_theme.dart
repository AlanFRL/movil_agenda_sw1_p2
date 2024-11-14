import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true, // Usa Material 3
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(
          color: Colors.white, // Cambia el color de la flecha de retroceso aquí
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 45, 70, 40), // Color del borde del TextField cuando está enfocado
          ),
        ),
      ),
    );
  }
}