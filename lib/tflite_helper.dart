import 'dart:async';
import 'package:camera/camera.dart';
import 'result.dart';
import 'package:tflite/tflite.dart';

class TFLiteHelper {
  static StreamController<List<Result>> tfLiteResultsController =
      new StreamController.broadcast();
  static List<Result> _outputs = List();
  static var modelLoaded = false;

// loading the model from the file
  static Future<String> loadModel() async {
    return Tflite.loadModel(
      model: 'assets/classifier.tflite', // tflite model
      labels: "assets/labels.txt", // classification label
    );
  }

// function which classifies the image by calling the model
  static classifyImage(CameraImage image) async {
    await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes; // converting an image from bytes
      }).toList(),
      numResults: 5, // number of classes of prediction
    ).then((value) {
      if (value.isNotEmpty) {
        _outputs.clear();
        value.forEach((element) {
          _outputs.add(Result(
              element['confidence'], element['index'], element['label']));
        });
      }
      //Sort results according to most confidence
      _outputs.sort((a, b) => a.confidence.compareTo(b.confidence));
      //Send results
      tfLiteResultsController.add(_outputs);
    });
  }

// closing the model
  static Future<void> disposeModel() async {
    await Tflite.close();
    tfLiteResultsController.close();
  }
}
