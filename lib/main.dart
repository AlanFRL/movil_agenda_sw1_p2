import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/config/theme/app_theme.dart';
import 'package:movil_agenda_sw1_p2/src/screens/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';
import 'package:movil_agenda_sw1_p2/src/helpers/auth_helper.dart'; // Importa AuthHelper
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura que la inicialización de Flutter se complete
  await Environment
      .initEnvironment(); // Espera a que las variables de entorno se carguen
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Inicializar Firebase antes de ejecutar la app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Agenda Académica',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginScreen()),
        GetPage(
          name: '/home',
          page: () => FutureBuilder(
            future:
                AuthHelper.getUserType(), // Llama a AuthHelper.getUserType()
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                final userType = snapshot.data;
                if (userType == 'agenda.estudiante') {
                  return HomeStudentScreen();
                } else if (userType == 'agenda.apoderado') {
                  return HomeGuardianScreen();
                } else {
                  return Center(
                      child: Text('Error: Tipo de usuario no soportado.'));
                }
              } else {
                return Center(
                    child: Text('Error al cargar el tipo de usuario.'));
              }
            },
          ),
        ),
        GetPage(
          name: '/events',
          page: () => EventsScreen(),
        ),
        GetPage(
          name: '/event_detail',
          page: () => EventDetailScreen(),
        ),
        GetPage(
          name: '/profile',
          page: () => ProfileScreen(),
        ),
        GetPage(
          name: '/child_subjects',
          page: () => ChildSubjectsScreen(),
        ),
        GetPage(
          name: '/avisos',
          page: () => AvisosScreen(),
        ),
        GetPage(
          name: '/aviso_detalle',
          page: () => AvisoDetalleScreen(),
        ),
        GetPage(
          name: '/cuestionarios',
          page: () => CuestionariosScreen(),
        ),
        GetPage(
          name: '/cuestionarioDetalle',
          page: () => CuestionarioDetalleScreen(),
        ),
      ],
      navigatorKey: Get.key,
    );
  }
}

class AuthMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isAuthenticated = prefs.getString('token') != null;

    if (!isAuthenticated) {
      return GetNavConfig.fromRoute('/login');
    }
    return null;
  }
}
