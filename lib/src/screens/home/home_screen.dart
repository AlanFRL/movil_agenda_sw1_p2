import 'package:flutter/material.dart';
import 'package:movil_agenda_sw1_p2/src/shared/shared.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido a la APP',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
        
      ),
      body: const Center(
        child: Text('Home'),
      ),
      drawer: Sidebar(),
    );
  }
}