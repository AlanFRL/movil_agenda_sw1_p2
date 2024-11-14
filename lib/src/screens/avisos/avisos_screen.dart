import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/providers/avisos_provider.dart';

class AvisosScreen extends StatelessWidget {
  final AvisosProvider avisosProvider = AvisosProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lista de Avisos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
      ),
      body: FutureBuilder(
        future: avisosProvider.getGuardianAvisos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            List avisos = snapshot.data as List;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: avisos.length,
              itemBuilder: (context, index) {
                var aviso = avisos[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    title: Text(
                      aviso['titulo'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 45, 70, 40),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aviso['descripcion'] ?? 'No hay descripción',
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Publicado en: ${aviso['fecha']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 18,
                    ),
                    onTap: () {
                      // Navegar a la pantalla de detalles del aviso
                      Get.toNamed('/aviso_detalle', arguments: {'avisoId': aviso['id']});
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No se encontraron avisos.'));
          }
        },
      ),
    );
  }
}
