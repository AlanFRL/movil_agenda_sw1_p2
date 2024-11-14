import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/providers/events_provider.dart';

class EventsScreen extends StatelessWidget {
  final int subjectId;
  final int? studentId;
  final int? userId;

  EventsScreen({Key? key})
      : subjectId = Get.arguments['subjectId'],
        studentId = Get.arguments['studentId'],
        userId = Get.arguments['userId'],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Eventos de la Materia',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
      ),
      body: FutureBuilder(
        future: fetchEvents(), // Función para obtener eventos de la materia
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
            return Center(child: Text('No hay eventos pendientes.'));
          } else if (snapshot.hasData) {
            List events = snapshot.data as List;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    leading: _getIconForEventType(event['titulo']),
                    title: Text(
                      event['titulo'].toString().toUpperCase(),
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
                          _getShortDescription(event['descripcion']),
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Publicado: ${event['fecha_publicacion']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'Realización: ${event['fecha_realizacion']}',
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
                      Get.toNamed('/event_detail',
                          arguments: {'eventId': event['id']});
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

  Future<List> fetchEvents() async {
    EventsProvider eventsProvider = EventsProvider();
    return await eventsProvider.getSubjectEvents(subjectId, studentId: studentId);
  }

  // Función para obtener el ícono según el tipo de evento
  Widget _getIconForEventType(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'tarea':
        return Icon(
          Icons.assignment,
          color: Colors.blue,
          size: 30.0,
        );
      case 'recurso':
        return Icon(
          Icons.book,
          color: Colors.green,
          size: 30.0,
        );
      case 'reunion':
        return Icon(
          Icons.meeting_room,
          color: Colors.orange,
          size: 30.0,
        );
      default:
        return Icon(
          Icons.event,
          color: Colors.grey,
          size: 30.0,
        );
    }
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
