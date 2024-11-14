import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/providers/events_provider.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class EventDetailScreen extends StatelessWidget {
  final int eventId;
  final String baseUrl = Environment.apiUrl;

  EventDetailScreen({Key? key})
      : eventId = Get.arguments['eventId'],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles del Evento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
      ),
      body: FutureBuilder(
        future: fetchEventDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            var event = snapshot.data as Map<String, dynamic>;
            return EventDetailsContent(event: event, baseUrl: baseUrl);
          } else {
            return Center(child: Text('No se encontró el evento.'));
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchEventDetail() async {
    EventsProvider eventsProvider = EventsProvider();
    final eventDetail = await eventsProvider.getEventDetail(eventId);
    //Future.microtask(() => eventsProvider.registerEventView(eventId));
    Future.microtask(() => eventsProvider.registerEventView(eventId, "agenda.apoderado"));
    return eventDetail;
  }
}

class EventDetailsContent extends StatelessWidget {
  final Map<String, dynamic> event;
  final String baseUrl;

  const EventDetailsContent({required this.event, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    final archivos =
        event['archivos'] ?? []; // Asigna una lista vacía si es null

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event['titulo'].toString().toUpperCase(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 45, 70, 40),
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Descripción: ${event['descripcion']}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8.0),
          Text(
            'Publicado: ${event['fecha_publicacion']}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            'Realización: ${event['fecha_realizacion']}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(height: 16.0),
          Text(
            'Archivos:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          archivos.isEmpty
              ? Text(
                  'No hay archivos disponibles para este evento.',
                  style: TextStyle(color: Colors.grey),
                )
              : ListView.builder(
                  itemCount: archivos.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var archivo = archivos[index];
                    return ArchivoCard(
                      archivo: archivo,
                      baseUrl: baseUrl,
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class ArchivoCard extends StatefulWidget {
  final Map<String, dynamic> archivo;
  final String baseUrl;

  const ArchivoCard({required this.archivo, required this.baseUrl});

  @override
  _ArchivoCardState createState() => _ArchivoCardState();
}

class _ArchivoCardState extends State<ArchivoCard> {
  bool isDownloaded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      child: ListTile(
        leading: Icon(
          isDownloaded ? Icons.check_circle : Icons.file_download,
          color: isDownloaded ? Colors.green : Colors.grey,
        ),
        title: Text(widget.archivo['name']),
        subtitle: Text(widget.archivo['mimetype']),
        trailing: Icon(Icons.open_in_new),
        onTap: () async {
          await _downloadAndOpenFile(
            context,
            widget.archivo['url'],
            widget.archivo['name'],
            widget.archivo['mimetype'],
          );
        },
      ),
    );
  }

  Future<void> _downloadAndOpenFile(
    BuildContext context,
    String url,
    String fileName,
    String mimeType,
  ) async {
    final fullUrl = '${widget.baseUrl}$url';
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      print('Archivo ya descargado. Abriendo desde la caché...');
      setState(() => isDownloaded = true);
      await OpenFile.open(filePath, type: mimeType);
      return;
    }

    try {
      dio.Dio dioInstance = dio.Dio();
      dio.Response response = await dioInstance.download(
        fullUrl,
        filePath,
        options: dio.Options(headers: {
          'Authorization': 'Bearer ${await _getToken()}',
          'Content-Type': mimeType,
        }),
      );

      if (response.statusCode == 200) {
        print('Descarga completada');
        setState(() => isDownloaded = true);
        await OpenFile.open(filePath, type: mimeType);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar el archivo.')),
        );
      }
    } catch (e) {
      print('Error al abrir el archivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir el archivo: $e')),
      );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
