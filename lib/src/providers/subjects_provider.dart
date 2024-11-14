import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';

class SubjectsProvider extends GetConnect {
  String url = Environment.apiUrl;

  Future<List> getStudentSubjects(String userId) async {
    Response response = await get('$url/api/student/subjects', query: {'user_id': userId});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return [];
    }
  }

  // Método para obtener materias del hijo
  Future<List> getChildSubjects(int childId) async {
    Response response = await get('$url/api/guardian/child_subjects', query: {'student_id': childId.toString()});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return [];
    }
  }
}
