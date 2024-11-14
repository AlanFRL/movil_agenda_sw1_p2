// En lib/src/screens/subjects/child_subjects_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/providers/subjects_provider.dart';

class ChildSubjectsScreen extends StatelessWidget {
  final int childId;
  final String childName;

  ChildSubjectsScreen({Key? key})
      : childId = Get.arguments['childId'],
        childName = Get.arguments['childName'],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Materias de $childName',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
      ),
      body: FutureBuilder(
        future: fetchChildSubjects(),
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
                      // En el onTap dentro de ChildSubjectsScreen (en la ListTile)
                      onTap: () {
                        final subjectId = subject['id'];
                        Get.toNamed('/events', arguments: {
                          'subjectId': subjectId,
                          'studentId': childId
                        });
                      }),
                );
              },
            );
          } else {
            return Center(child: Text('No se encontraron materias.'));
          }
        },
      ),
    );
  }

  Future<List> fetchChildSubjects() async {
    SubjectsProvider subjectsProvider = SubjectsProvider();
    return await subjectsProvider.getChildSubjects(childId);
  }
}
