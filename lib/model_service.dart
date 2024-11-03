// model_service.dart
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelService {
  static const String _modelPath = "assets/model_unquant.tflite"; // Update to your model path
  static const String _labelPath = "assets/labels.txt"; // Update to your labels path
  static const int _imageSize = 224;

  Interpreter? _interpreter;
  List<String>? _categoryLabels;
  bool _isModelLoaded = false;
  bool _isLoadingModel = true;

  bool get isModelLoaded => _isModelLoaded;
  List<String>? get categoryLabels => _categoryLabels;
  Interpreter? get interpreter => _interpreter;
  int get imageSize => _imageSize;
  bool get isLoadingModel => _isLoadingModel; // Add this getter

  Future<void> initializeModel() async {
    try {
      _isLoadingModel = true; // Set loading state
      if (await _checkAssetFileExists(_modelPath)) {
        _interpreter = await Interpreter.fromAsset(_modelPath);
        _isModelLoaded = true;
        print("model loaded successfully ");
      }

      if (await _checkAssetFileExists(_labelPath)) {
        final labelsData = await rootBundle.loadString(_labelPath);
        _categoryLabels = labelsData.split('\n');
        print("labels loaded successfully ");

      }
    } catch (e) {
      print("Error loading model or labels: $e");
      _isModelLoaded = false;
    } finally {
      _isLoadingModel = false; // Reset loading state
    }
  }

  Future<bool> _checkAssetFileExists(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return data != null;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
