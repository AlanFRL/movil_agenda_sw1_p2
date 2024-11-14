import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movil_agenda_sw1_p2/src/providers/avisos_provider.dart';
import 'package:movil_agenda_sw1_p2/src/config/environment/environment.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:movil_agenda_sw1_p2/src/helpers/location_helper.dart';
import 'aviso_detalle_content.dart';
//import 'package:movil_agenda_sw1_p2/src/screens/avisos/aviso_detalle_content.dart';


class AvisoDetalleScreen extends StatefulWidget {
  final int avisoId;
  final String baseUrl = Environment.apiUrl;

  AvisoDetalleScreen({Key? key})
      : avisoId = Get.arguments['avisoId'],
        super(key: key);

  @override
  State<AvisoDetalleScreen> createState() => _AvisoDetalleScreenState();
}

class _AvisoDetalleScreenState extends State<AvisoDetalleScreen> {
  late Future<Map<String, dynamic>> _avisoDetalle;
  double? latApoderado;
  double? lonApoderado;

  @override
  void initState() {
    super.initState();
    _avisoDetalle = fetchAvisoDetalle();
    fetchAvisoUbicacionData();
  }

  Future<void> fetchAvisoUbicacionData() async {
    Position? ubicacionActual = await LocationHelper.obtenerUbicacionActual();
    if (ubicacionActual != null) {
      setState(() {
        latApoderado = ubicacionActual.latitude;
        lonApoderado = ubicacionActual.longitude;
      });
    }
  }

  Future<Map<String, dynamic>> fetchAvisoDetalle() async {
    AvisosProvider avisosProvider = AvisosProvider();
    final avisoDetalle = await avisosProvider.getAvisoDetalle(widget.avisoId);

    print("Datos del aviso recibidos: $avisoDetalle");

    return avisoDetalle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles del Aviso',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 45, 70, 40),
      ),
      body: FutureBuilder(
        future: _avisoDetalle,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              latApoderado == null ||
              lonApoderado == null) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            var aviso = snapshot.data as Map<String, dynamic>;
            return AvisoDetallesContenido(
              aviso: aviso,
              baseUrl: widget.baseUrl,
              latApoderado: latApoderado!,
              lonApoderado: lonApoderado!,
            );
          } else {
            return Center(child: Text('No se encontró el aviso.'));
          }
        },
      ),
    );
  }
}
