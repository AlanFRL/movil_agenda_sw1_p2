// En lib/src/providers/guardians_provider.dart
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class GuardiansProvider extends GetConnect {
  String url = Environment.apiUrl;

  Future<List> getGuardianChildren(String userId) async {
    Response response = await get('$url/api/guardian/children', query: {'user_id': userId});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return [];
    }
  }
}
