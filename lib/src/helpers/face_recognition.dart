//import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class FaceRecognitionHelper {
  final ImagePicker _picker = ImagePicker();
  //final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector();
  final String apiKey = "jp-cp4y4Ky_OkhHRjGWxpujeSs5evz5T";
  final String apiSecret = "6s1BPnaRoCsy9pddMvhJ4uTht1fSaWJl";

  // Captura una imagen desde la cámara
  Future<Uint8List?> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50, // Reduce calidad para bajar el tamaño del archivo
        maxWidth: 640, // Limitar ancho y alto también reduce el tamaño
        maxHeight: 480,
      );
      if (image != null) {
        print("Imagen capturada exitosamente desde la cámara.");
        return await image.readAsBytes();
      } else {
        print("No se capturó ninguna imagen.");
      }
    } catch (e) {
      print("Error al capturar la imagen: $e");
    }
    return null;
  }

  // Compara las dos imágenes usando Face++ API
  Future<bool> compareFaces(
      Uint8List storedPhoto, Uint8List capturedPhoto) async {
    final url = Uri.parse("https://api-us.faceplusplus.com/facepp/v3/compare");

    try {
      print("Comparando fotos usando Face++...");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          "api_key": apiKey,
          "api_secret": apiSecret,
          "image_base64_1": base64Encode(storedPhoto),
          "image_base64_2": base64Encode(capturedPhoto),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final confidence = jsonResponse['confidence'] ?? 0.0;
        print("Nivel de confianza: $confidence");
        return confidence > 80; // Ajusta el umbral según la precisión deseada
      } else {
        print("Error en la comparación de rostros: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error en la solicitud a Face++: $e");
      return false;
    }
  }

  // Decodifica una imagen en base64 para usar en la comparación
  Uint8List decodeBase64Image(String base64String) {
    print("Decodificando imagen en base64.");
    return base64Decode(base64String);
  }

  // Guarda temporalmente la imagen capturada para procesarla
  Future<String> _saveTempImage(Uint8List imageBytes) async {
    final file = File('${Directory.systemTemp.path}/temp_image.jpg');
    await file.writeAsBytes(imageBytes);
    print("Imagen temporal guardada en: ${file.path}");
    return file.path;
  }
}
