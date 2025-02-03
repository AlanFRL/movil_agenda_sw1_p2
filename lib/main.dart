import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/config/theme/app_theme.dart';
import 'package:movil_agenda_sw1_p2/src/screens/screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';
import 'package:movil_agenda_sw1_p2/src/helpers/auth_helper.dart'; // Importa AuthHelper
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura que la inicialización de Flutter se complete
  await Environment
      .initEnvironment(); // Espera a que las variables de entorno se carguen
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Inicializar Firebase antes de ejecutar la app
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Obtener el token FCM
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  // Registrar el token en Odoo solo si el usuario ya está autenticado
  /*
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');
  if (token != null && userId != null) {
    await AuthHelper.registerFcmToken(token);
  }
  */

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message clicked!');
    print('Notification Data: ${message.data}'); // Imprimir datos de la notificación

    // Redirige siempre al login
    Get.offAllNamed('/');
  });


  // Inicializar notificaciones locales
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Icono de la app

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  // Crear y registrar un canal de notificaciones
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel', // ID del canal
    'Notificaciones Generales', // Nombre del canal
    description: 'Canal para notificaciones generales de la app', // Descripción del canal
    importance: Importance.high, // Importancia alta para notificaciones visibles
    playSound: true, // Habilitar el sonido por defecto
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received message in foreground: ${message.notification?.title}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Mostrar la notificación si existe
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id, // Usar el ID del canal configurado
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true, // Habilita el sonido por defecto
          ),
        ),
      );
    }
  });
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
