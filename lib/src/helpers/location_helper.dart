import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  // Calcula la distancia entre dos puntos GPS usando la fórmula Haversine
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371e3; // Radio de la tierra en metros
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Función para obtener la ubicación actual del dispositivo
  static Future<Position?> obtenerUbicacionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Si el servicio de ubicación no está habilitado, se puede mostrar un mensaje o realizar otra acción
      print('El servicio de ubicación está desactivado.');
      return null;
    }

    // Verifica los permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permisos denegados
        print('Los permisos de ubicación fueron denegados.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permisos denegados de forma permanente
      print('Los permisos de ubicación fueron denegados de forma permanente.');
      return null;
    }

    // Obtiene la posición actual
    return await Geolocator.getCurrentPosition();
  }
}
