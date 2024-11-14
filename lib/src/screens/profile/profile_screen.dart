// En profile_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movil_agenda_sw1_p2/src/providers/users_provider.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;
  String? userEmail;
  String? userCI;
  String? userPhone;
  String? userSex;
  String? userCourse;
  String? userStudentCode;
  String? userBirthDate;
  String? userPhoto; // Foto de perfil del apoderado
  String? userQrCode; // QR Code del apoderado
  bool isGuardian = false; // Verifica si el usuario es apoderado

  // Añade esta instancia si no la tienes en la clase _ProfileScreenState
  final UsersProvider usersProvider = UsersProvider();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Cargando todos los atributos que se almacenaron internamente en flutter al hacer login
      userName = prefs.getString('user_name');
      userEmail = prefs.getString('email');
      userCI = prefs.getString('ci');
      userPhone = prefs.getString('telefono');
      userSex = prefs.getString('sexo');
      userCourse = prefs.getString('curso');
      userStudentCode = prefs.getString('student_code');
      userBirthDate = prefs.getString('birth_date');
      userPhoto = prefs.getString('user_photo');
      userQrCode = prefs.getString('qr_code');
      isGuardian = prefs.getString('model_name') == 'agenda.apoderado';
    });
  }

  Future<void> _downloadQrCode() async {
    if (userQrCode == null) return;

    // Check for storage permission
    var status = await Permission.storage.request();

    if (status.isGranted) {
      // Lógica para descargar la imagen del código QR
      Uint8List qrBytes = base64Decode(userQrCode!);
      //final directory = await getExternalStorageDirectory();
      // Obtener el directorio público de imágenes
      final directory = Directory('/storage/emulated/0/Pictures');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      // Guardar el archivo de imagen en el directorio de imágenes públicas
      String path = '${directory.path}/qr_code_${userName ?? 'apoderado'}.png';
      File qrFile = File(path);

      await qrFile.writeAsBytes(qrBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código QR guardado en $path')),
      );
      print('Guardado en: $path');
      // Aquí colocas el código para descargar la imagen
    } else if (status.isDenied) {
      // Muestra mensaje si el permiso fue denegado
      Get.snackbar(
        'Permiso Requerido',
        'Necesitas otorgar permisos de almacenamiento para descargar el código QR',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else if (status.isPermanentlyDenied) {
      // Abre la configuración del dispositivo si el permiso está permanentemente denegado
      await openAppSettings();
    }
  }

  void _showQrCode() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.memory(
                base64Decode(userQrCode!),
                width: 200,
                height: 200,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _downloadQrCode,
              icon: Icon(Icons.download),
              label: Text('Descargar Código QR'),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePhoto() async {
    if (!isGuardian) return;
    final picker = ImagePicker();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleccionar foto de perfil"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Galería"),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    _savePhoto(pickedFile);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Cámara"),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    _savePhoto(pickedFile);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

// Función para guardar la foto seleccionada
  Future<void> _savePhoto(XFile pickedFile) async {
    final bytes = File(pickedFile.path).readAsBytesSync();
    final base64Image = base64Encode(bytes);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_photo', base64Image);

    setState(() {
      userPhoto = base64Image;
    });

    // Llamar a la API de actualización de foto en el servidor
    final response = await usersProvider.updateUserPhoto(base64Image);

    if (response.statusCode == 200) {
      print("Foto de perfil actualizada en el servidor");
    } else {
      print(
          "Error al actualizar la foto de perfil en el servidor: ${response.bodyString}");
    }
  }

  Widget _buildProfileField(String label, String? value, {IconData? icon}) {
    if (value == null || value.isEmpty)
      return SizedBox.shrink(); // Ocultar si el campo es nulo o vacío

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: Colors.grey[700], size: 20),
          if (icon != null) SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  userPhoto != null && userPhoto!.isNotEmpty
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              MemoryImage(base64Decode(userPhoto!)),
                        )
                      : const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                  if (isGuardian)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextButton.icon(
                        onPressed: _updatePhoto,
                        icon: Icon(Icons.camera_alt),
                        label: Text('Actualizar Foto'),
                      ),
                    ),
                  SizedBox(height: 16),
                  Text(
                    userName ?? 'Usuario desconocido',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Divider(thickness: 1.5, height: 30),
                  _buildProfileField('Email', userEmail, icon: Icons.email),
                  _buildProfileField('CI', userCI, icon: Icons.perm_identity),
                  _buildProfileField('Teléfono', userPhone, icon: Icons.phone),
                  _buildProfileField('Sexo', userSex, icon: Icons.person),
                  _buildProfileField('Curso', userCourse, icon: Icons.class_),
                  _buildProfileField('Código de Estudiante', userStudentCode,
                      icon: Icons.code),
                  _buildProfileField('Fecha de Nacimiento', userBirthDate,
                      icon: Icons.calendar_today),
                  if (isGuardian) ...[
                    Divider(thickness: 1.5, height: 30),
                    Text('Código QR',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: _showQrCode,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.memory(
                          base64Decode(userQrCode!),
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _downloadQrCode,
                      icon: Icon(Icons.download),
                      label: Text('Descargar Código QR'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
