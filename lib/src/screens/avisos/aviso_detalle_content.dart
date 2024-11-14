//import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:movil_agenda_sw1_p2/src/helpers/face_recognition.dart';
import 'package:movil_agenda_sw1_p2/src/helpers/location_helper.dart';
import 'package:movil_agenda_sw1_p2/src/screens/avisos/archivo_aviso_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movil_agenda_sw1_p2/src/providers/avisos_provider.dart';

class AvisoDetallesContenido extends StatefulWidget {
  final Map<String, dynamic> aviso;
  final String baseUrl;
  final double latApoderado;
  final double lonApoderado;


  AvisoDetallesContenido({
    required this.aviso,
    required this.baseUrl,
    required this.latApoderado,
    required this.lonApoderado,
  });

  @override
  State<AvisoDetallesContenido> createState() => _AvisoDetallesContenidoState();
}

class _AvisoDetallesContenidoState extends State<AvisoDetallesContenido> {
  late Map<String, dynamic> aviso;
  final FaceRecognitionHelper faceHelper = FaceRecognitionHelper();

  final AvisosProvider avisosProvider = AvisosProvider();

  @override
  void initState() {
    super.initState();
    aviso = widget.aviso;
  }

  Future<void> _refreshAviso() async {
    final updatedAviso = await avisosProvider.getAvisoDetalle(aviso['id']);
    setState(() {
      aviso = updatedAviso;
    });
  }

  Future<void> _startFaceRecognition(BuildContext context) async {
    if (aviso['ha_asistido'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Ya has registrado tu asistencia para este aviso.")),
      );
      return;
    }

    print(
        "Aviso_detalle_content: _startFaceRecognition: Iniciando proceso de reconocimiento facial.");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPhotoBase64 = prefs.getString('user_photo');
    String? userId =
        prefs.getString('user_id'); // Recupera el user_id como apoderado_id

    if (storedPhotoBase64 == null || storedPhotoBase64.isEmpty) {
      print(
          "Aviso_detalle_content: _startFaceRecognition: No hay foto almacenada para este usuario.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No hay foto almacenada para este usuario")),
      );
      return;
    }

    if (userId == null || userId.isEmpty) {
      print(
          "Aviso_detalle_content: _startFaceRecognition: Error: No se pudo obtener el ID del usuario.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: No se pudo obtener el ID del usuario")),
      );
      return;
    }

    print(
        "Aviso_detalle_content: _startFaceRecognition: Foto almacenada encontrada. Decodificando imagen....");
    Uint8List storedPhotoBytes =
        faceHelper.decodeBase64Image(storedPhotoBase64);
    print(
        "Aviso_detalle_content: _startFaceRecognition: Capturando nueva imagen para comparación...");
    final Uint8List? capturedImage = await faceHelper.captureImage();
    if (capturedImage != null) {
      print(
          "Aviso_detalle_content: _startFaceRecognition: Nueva imagen capturada, iniciando detección de rostros");
      // Detección de rostro en la imagen almacenada
      bool isMatch =
          await faceHelper.compareFaces(storedPhotoBytes, capturedImage);

      if (isMatch) {
        final isUpdated = await avisosProvider.actualizarAsistencia(
            widget.aviso['id'], int.parse(userId));
        if (isUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Asistencia registrada con éxito")));
          // Actualizar el estado llamando a la función de recarga
          await _refreshAviso();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Reconocimiento facial fallido")));
      }
    } else {
      print("No se capturó una nueva imagen para el reconocimiento facial.");
    }
  }

  String _formatDateTime(String dateTimeString) {
    final dateTime =
        DateTime.parse(dateTimeString).subtract(Duration(hours: 4));
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');
    return '${dateFormat.format(dateTime)} ${timeFormat.format(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final archivos = aviso['archivos'] ?? [];

    // Parsear ubicación GPS del aviso
    final ubicacionAviso = aviso['ubicacion_gps'].split(', ');
    final latAviso = double.parse(ubicacionAviso[0]);
    final lonAviso = double.parse(ubicacionAviso[1]);

    // Obtener la hora de finalización y convertirla a DateTime ajustado
    final horaFinalizacion = aviso['hora_finalizacion'] != null
        ? DateTime.parse(aviso['hora_finalizacion'])
            .subtract(Duration(hours: 4))
        : null;

    // Condición para mostrar botón de asistencia
    bool puedeMarcarAsistencia = false;
    String mensaje = '';

    // Verificar si la reunión es de tipo "reunion" y está dentro del rango de tiempo y distancia
    if (aviso['tipo_aviso'] == 'reunion' && horaFinalizacion != null) {
      if (horaFinalizacion.isBefore(DateTime.now())) {
        mensaje = 'Reunión Finalizada';
      } else {
        // Calcular la distancia
        double distancia = LocationHelper.calculateDistance(
            latAviso, lonAviso, widget.latApoderado, widget.lonApoderado);
        print(
            'Distancia entre ubicación Aviso y Ubicación apoderado: $distancia');
        if (distancia <= 50) {
          puedeMarcarAsistencia = true;
        } else {
          mensaje = 'Fuera del rango de ubicación';
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            aviso['titulo']?.toString().toUpperCase() ?? '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 45, 70, 40),
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Descripción: ${aviso['descripcion'] ?? ''}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8.0),
          Text(
            'Fecha: ${aviso['fecha'] ?? ''}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(height: 8.0),
          Text(
            'Tipo de Aviso: ${aviso['tipo_aviso'] ?? ''}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(height: 8.0),
          if (aviso['hora_finalizacion'] != null)
            Text(
              'Hora de Finalización: ${_formatDateTime(aviso['hora_finalizacion'])}',
              style: TextStyle(color: Colors.grey[700]),
            ),
          SizedBox(height: 8.0),
          if (aviso['ha_asistido'] != null)
            Text(
              'Asistencia Confirmada: ${aviso['ha_asistido'] ? 'Sí' : 'No'}',
              style: TextStyle(
                  color: aviso['ha_asistido'] ? Colors.green : Colors.red),
            ),
          if (puedeMarcarAsistencia)
            ElevatedButton(
              onPressed: () {
                _startFaceRecognition(context);
              },
              child: Text('Marcar Asistencia con Reconocimiento Facial'),
            ),
          SizedBox(height: 8.0),
          if (!puedeMarcarAsistencia)
            Text(
              mensaje,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 16.0),
          Text(
            'Archivos:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          archivos.isEmpty
              ? Text(
                  'No hay archivos disponibles para este aviso.',
                  style: TextStyle(color: Colors.grey),
                )
              : ListView.builder(
                  itemCount: archivos.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var archivo = archivos[index];
                    return ArchivoAvisoCard(
                      archivo: archivo,
                      baseUrl: widget.baseUrl,
                    );
                  },
                ),
        ],
      ),
    );
  }
}
