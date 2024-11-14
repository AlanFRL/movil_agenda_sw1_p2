import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CuestionarioHeader extends StatelessWidget {
  final Map<String, dynamic> cuestionario;

  const CuestionarioHeader({required this.cuestionario});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema de Reforzamiento:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              cuestionario['tema_reforzamiento'].toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 45, 70, 40),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Enlaces de YouTube:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (cuestionario['enlaces_videos'] as List).map<Widget>((link) {
                return GestureDetector(
                  onTap: () => _launchURL(link),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      link,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.grey[700],
                  size: 18,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Estado: ${cuestionario['estado']}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  Icons.score,
                  color: Colors.grey[700],
                  size: 18,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Puntaje Obtenido: ${cuestionario['puntaje_obtenido']}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
