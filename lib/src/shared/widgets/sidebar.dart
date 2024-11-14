// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/providers/users_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Sidebar extends StatelessWidget {
  Sidebar({super.key});
  final UsersProvider usersProvider = UsersProvider();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: usersProvider.getUserName(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: _getUserPhoto(), // Obtener la foto del usuario si existe
            builder: (context, photoSnapshot) {
              Widget profilePhoto = const CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 30.0,
                  color: Colors.black,
                ),
              );

              // Si la foto existe, mostrarla
              if (photoSnapshot.hasData && photoSnapshot.data != null && photoSnapshot.data!.isNotEmpty) {
                profilePhoto = CircleAvatar(
                  radius: 30.0,
                  backgroundImage: MemoryImage(base64Decode(photoSnapshot.data!)),
                );
              }

              return Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 66, 80, 63),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          profilePhoto,
                          const SizedBox(height: 10.0),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              snapshot.data!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<bool>(
                      future: _isStudent(),
                      builder: (BuildContext context, AsyncSnapshot<bool> studentSnapshot) {
                        if (studentSnapshot.connectionState == ConnectionState.waiting) {
                          return Container(); // Placeholder while loading
                        } else if (studentSnapshot.hasData && studentSnapshot.data!) {
                          return Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.home),
                                title: const Text('Inicio'),
                                onTap: () => _onItemTapped(0),
                              ),
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: const Text('Perfil'),
                                onTap: () => _onItemTapped(1),
                              ),
                              ListTile(
                                leading: const Icon(Icons.question_answer),
                                title: const Text('Cuestionarios'),
                                onTap: () => _onItemTapped(2),
                              ),
                            ],
                          );
                        } else {
                          return FutureBuilder<bool>(
                            future: _isGuardian(),
                            builder: (BuildContext context, AsyncSnapshot<bool> guardianSnapshot) {
                              if (guardianSnapshot.connectionState == ConnectionState.waiting) {
                                return Container(); // Placeholder while loading
                              } else if (guardianSnapshot.hasData && guardianSnapshot.data!) {
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.home),
                                      title: const Text('Inicio'),
                                      onTap: () => _onItemTapped(0),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.person),
                                      title: const Text('Perfil'),
                                      onTap: () => _onItemTapped(1),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.announcement),
                                      title: const Text('Avisos'),
                                      onTap: () => _onItemTapped(3),
                                    ),
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            },
                          );
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _onItemTapped(4),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Drawer();
        }
      },
    );
  }

  Future<String?> _getUserPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? photo = prefs.getString('user_photo');
    return (photo != null && photo.isNotEmpty) ? photo : null; // Recuperar la foto en base64 si existe
  }

  Future<bool> _isStudent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? modelName = prefs.getString('model_name');
    return modelName == 'agenda.estudiante';
  }

  Future<bool> _isGuardian() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? modelName = prefs.getString('model_name');
    return modelName == 'agenda.apoderado';
  }

  void _onItemTapped(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    
    switch (index) {
      case 0:
        Get.offAllNamed('/home');
        break;
      case 1:
        if (userId != null) {
          Get.toNamed('/profile/$userId');
        }
        break;
      case 2:
        if (userId != null) {
          Get.toNamed('/cuestionarios/', arguments: {'userId': userId});
        }
        break;
      case 3:
        if (userId != null) {
          Get.toNamed('/avisos', arguments: {'userId': userId});
        }
        break;
      case 4:
        usersProvider.logout();
        break;
      default:
        print("Unknown index: $index");
    }
  }
}