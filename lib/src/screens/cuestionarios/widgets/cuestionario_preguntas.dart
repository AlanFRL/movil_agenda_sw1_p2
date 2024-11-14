import 'package:flutter/material.dart';

class CuestionarioPreguntas extends StatefulWidget {
  final List preguntas;
  final Function(Map<int, String>) onFinalizar;

  const CuestionarioPreguntas({required this.preguntas, required this.onFinalizar});

  @override
  _CuestionarioPreguntasState createState() => _CuestionarioPreguntasState();
}

class _CuestionarioPreguntasState extends State<CuestionarioPreguntas> {
  final Map<int, String> respuestasSeleccionadas = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.preguntas.map<Widget>((pregunta) {
          int preguntaId = pregunta['id'];
          return Card(
            child: ListTile(
              title: Text(pregunta['contenido']),
              subtitle: Column(
                children: (pregunta['opciones'] as List).map<Widget>((opcion) {
                  return RadioListTile<String>(
                    title: Text(opcion),
                    value: opcion,
                    groupValue: respuestasSeleccionadas[preguntaId],
                    onChanged: (value) {
                      setState(() {
                        respuestasSeleccionadas[preguntaId] = value!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            widget.onFinalizar(respuestasSeleccionadas);
          },
          child: const Text("Finalizar cuestionario"),
        ),
      ],
    );
  }
}
