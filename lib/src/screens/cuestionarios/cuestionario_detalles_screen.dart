import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/providers/cuestionarios_provider.dart';
import 'package:movil_agenda_sw1_p2/src/screens/cuestionarios/widgets/cuestionario_header.dart';
import 'package:movil_agenda_sw1_p2/src/screens/cuestionarios/widgets/cuestionario_preguntas.dart';

class CuestionarioDetalleScreen extends StatefulWidget {
  final int cuestionarioId;

  CuestionarioDetalleScreen({Key? key})
      : cuestionarioId = Get.arguments['cuestionarioId'],
        super(key: key);

  @override
  _CuestionarioDetalleScreenState createState() =>
      _CuestionarioDetalleScreenState();
}

class _CuestionarioDetalleScreenState extends State<CuestionarioDetalleScreen> {
  Map<String, dynamic>? cuestionario;
  bool iniciado = false;

  @override
  void initState() {
    super.initState();
    _fetchCuestionarioDetalle(); // Cargar detalles del cuestionario al inicio
  }

  void _fetchCuestionarioDetalle() async {
    CuestionariosProvider cuestionariosProvider = CuestionariosProvider();
    Map<String, dynamic> detalles =
        await cuestionariosProvider.getCuestionarioDetalle(widget.cuestionarioId);
    setState(() {
      cuestionario = detalles;
      iniciado = false; // Reiniciar el estado de "iniciado"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cuestionario de Repechaje',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchCuestionarioDetalle(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            cuestionario = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CuestionarioHeader(cuestionario: cuestionario!),
                  const SizedBox(height: 16.0),
                  if (cuestionario!['estado'] == 'pendiente' && !iniciado)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          iniciado = true;
                        });
                      },
                      child: const Text("Iniciar cuestionario"),
                    ),
                  if (iniciado && cuestionario!['estado'] == 'pendiente')
                    CuestionarioPreguntas(
                      preguntas: cuestionario!['preguntas'],
                      onFinalizar: _finalizarCuestionario,
                    ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Cuestionario no encontrado.'));
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchCuestionarioDetalle() async {
    CuestionariosProvider cuestionariosProvider = CuestionariosProvider();
    return await cuestionariosProvider
        .getCuestionarioDetalle(widget.cuestionarioId);
  }

  void _finalizarCuestionario(Map<int, String> respuestasSeleccionadas) async {
    // Aquí se puede agregar el código para registrar las respuestas y actualizar el estado del cuestionario en el servidor
    print("Respuestas seleccionadas: $respuestasSeleccionadas");
    // Verificar que todas las preguntas tienen respuesta
    if (respuestasSeleccionadas.length != cuestionario!['preguntas'].length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Por favor, responde todas las preguntas antes de finalizar.")),
      );
      return;
    }
    // Lógica para actualizar el cuestionario como resuelto en el servidor
    CuestionariosProvider cuestionariosProvider = CuestionariosProvider();
    bool actualizado = await cuestionariosProvider.finalizarCuestionario(
      widget.cuestionarioId,
      respuestasSeleccionadas,
    );

    if (actualizado) {
      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cuestionario completado y enviado con éxito.")),
      );
      // Recargar los detalles del cuestionario para reflejar los cambios en la interfaz
      _fetchCuestionarioDetalle();
    } else {
      // Mostrar un mensaje de error si la actualización falló
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Hubo un problema al finalizar el cuestionario.")),
      );
    }
  }
}
