import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ArchivoAvisoCard extends StatefulWidget {
  final Map<String, dynamic> archivo;
  final String baseUrl;

  const ArchivoAvisoCard({required this.archivo, required this.baseUrl});

  @override
  _ArchivoAvisoCardState createState() => _ArchivoAvisoCardState();
}

class _ArchivoAvisoCardState extends State<ArchivoAvisoCard> {
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
        setState(() => isDownloaded = true);
        await OpenFile.open(filePath, type: mimeType);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar el archivo.')),
        );
      }
    } catch (e) {
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
