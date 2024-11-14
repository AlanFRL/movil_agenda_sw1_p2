import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movil_agenda_sw1_p2/src/providers/subjects_provider.dart';
import 'package:movil_agenda_sw1_p2/src/shared/shared.dart';

class HomeStudentScreen extends StatelessWidget {
  const HomeStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Materias',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
      ),
      body: FutureBuilder(
        future: fetchSubjects(),  // Función para obtener materias del estudiante
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            List subjects = snapshot.data as List;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                var subject = subjects[index];
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
                      Icons.book,
                      color: Color.fromARGB(255, 45, 70, 40),
                      size: 30.0,
                    ),
                    title: Text(
                      subject['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 18,
                    ),
                    onTap: () {
                      Get.toNamed('/events', arguments: {'subjectId': subject['id']});
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No se encontraron materias.'));
          }
        },
      ),
      drawer: Sidebar(),
    );
  }

  Future<List> fetchSubjects() async {
    // Obtener el user_id almacenado en SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      // Llamar al API para obtener las materias del estudiante
      SubjectsProvider subjectsProvider = SubjectsProvider();
      return await subjectsProvider.getStudentSubjects(userId);
    } else {
      return [];
    }
  }
}
