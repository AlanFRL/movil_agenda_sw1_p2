import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/providers/cuestionarios_provider.dart';

class CuestionariosScreen extends StatelessWidget {
  final String? userId;

  CuestionariosScreen({Key? key})
      : userId = Get.arguments['userId'],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Entrando a Cuestionarios Screen');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cuestionarios de Repechaje',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
      ),
      body: FutureBuilder(
        future:
            fetchCuestionarios(), // Función para obtener eventos de la materia
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text('No hay cuestionarios pendientes.'));
          } else if (snapshot.hasData) {
            List cuestionarios = snapshot.data as List;
            print('imprimiendo cuestionarios: $cuestionarios');
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: cuestionarios.length,
              itemBuilder: (context, index) {
                var cuestionario = cuestionarios[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    leading: Icon(
                      Icons.assignment,
                      color: Colors.blue,
                      size: 30.0,
                    ),
                    title: Text(
                      'Cuestionario ${index+1}',
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
                          _getShortDescription(
                              cuestionario['tema_reforzamiento']),
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Materia: ${cuestionario['materia']}',
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
                      // Navegar a la pantalla de detalles del evento
                      Get.toNamed('/cuestionarioDetalle',
                          arguments: {'cuestionarioId': cuestionario['id']});
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No se encontraron eventos.'));
          }
        },
      ),
    );
  }

  Future<List> fetchCuestionarios() async {
    CuestionariosProvider cuestionariosProvider = CuestionariosProvider();
    return await cuestionariosProvider.getCuestionarios();
  }

  // Función para mostrar una descripción corta
  String _getShortDescription(String description) {
    const int maxLength = 65; // Número máximo de caracteres visibles
    if (description.length > maxLength) {
      return description.substring(0, maxLength) + '...';
    } else {
      return description;
    }
  }
}
