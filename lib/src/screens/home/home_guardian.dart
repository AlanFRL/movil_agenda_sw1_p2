// En lib/src/screens/home/home_guardian.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movil_agenda_sw1_p2/src/providers/guardians_provider.dart';
import 'package:movil_agenda_sw1_p2/src/shared/shared.dart';

class HomeGuardianScreen extends StatelessWidget {
  const HomeGuardianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Estudiantes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
      ),
      body: FutureBuilder(
        future:
            fetchChildren(), // Llamar a la función para obtener hijos del apoderado
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            List children = snapshot.data as List;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: children.length,
              itemBuilder: (context, index) {
                var child = children[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    leading: Icon(
                      Icons.person,
                      color: Color.fromARGB(255, 45, 70, 40),
                      size: 30.0,
                    ),
                    title: Text(
                      child['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Curso: ${child['course']}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 18,
                    ),
                    onTap: () {
                      print('Imprimiendo childId: ${child['id']}');
                      print('Imprimiendo childName: ${child['name']}');
                      Get.toNamed('/child_subjects', arguments: {
                        'childId': child['id'],
                        'childName': child['name']
                      });
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No se encontraron hijos.'));
          }
        },
      ),
      drawer: Sidebar(), // Agregar el menú lateral si es necesario
    );
  }

  Future<List> fetchChildren() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      GuardiansProvider guardiansProvider = GuardiansProvider();
      return await guardiansProvider.getGuardianChildren(userId);
    } else {
      return [];
    }
  }
}
