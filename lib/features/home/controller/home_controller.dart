import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_example/features/home/controller/camera_controller.dart';
import 'package:google_ml_example/features/home/controller/face_detention_controller.dart';
import 'package:google_ml_example/features/home/module/face_model.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  CameraManager? _cameraManager;
  CameraController? cameraController;
  FaceDetetorController? _faceDetect;
  bool _isDetecting = false;
  List<FaceModel>? faces;
  String? faceAtMoment = 'normal_face.png';
  String? label = 'Normal';
  String? otherLabel = 'Normal';
  String? happyLevel = "Normal";
  String? otherLevel = "Normal";

  HomeController() {
    _cameraManager = CameraManager();
    _faceDetect = FaceDetetorController();
  }

  Future<void> loadCamera() async {
    cameraController = await _cameraManager?.load();
    update();
  }

  Future<String> chatbot(BuildContext context, Image faceData) async {
    String result = "";
    Map data = {"input": faceData};
    print(data);
    print("encoded--${json.encode(data)}");
    const url =
        "http://ec2-3-139-93-168.us-east-2.compute.amazonaws.com:8080/face";
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
      },
    );
    print('response---${response.body}');
    // print(response.statusCode);
    try {
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print(json);
        result = json["output"] as String;

        print('---Success');
        // Navigator.pop(context);
        return result;
      }
    } catch (e) {
      // Navigator.pop(context);
      print(e);
    }
    return result;
  }

  Future<void> startImageStream() async {
    CameraDescription camera = cameraController!.description;

    cameraController?.startImageStream((cameraImage) async {
      if (_isDetecting) return;

      _isDetecting = true;

      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in cameraImage.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
          Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

      final InputImageRotation imageRotation =
          InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.Rotation_0deg;

      final InputImageFormat inputImageFormat =
          InputImageFormatMethods.fromRawValue(cameraImage.format.raw) ??
              InputImageFormat.NV21;

      final planeData = cameraImage.planes.map(
        (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: inputImageFormat,
        planeData: planeData,
      );

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        inputImageData: inputImageData,
      );

      processImage(inputImage);
    });
  }

  Future<void> processImage(inputImage) async {
    faces = await _faceDetect?.processImage(inputImage);

    if (faces != null && faces!.isNotEmpty) {
      FaceModel? face = faces?.first;
      label = detectSmile(face?.smile);
      otherLabel = detectOther(face?.smile);
      happyLevel = happyFeature(face?.smile);
      otherLevel = otherFeature(face?.smile);
    } else {
      faceAtMoment = 'normal_face.png';
      label = 'No face detected';
      otherLabel = 'No emotion detectd';
      happyLevel = 'No face';
      otherLevel = 'No face';
    }
    _isDetecting = false;
    update();
  }

  String detectSmile(smileProb) {
    if (smileProb > 0.86) {
      faceAtMoment = 'happy_face.png';
      return 'Big smile';
    } else if (smileProb > 0.6) {
      faceAtMoment = 'happy_face.png';
      return 'Smile';
    } else if (smileProb > 0.3) {
      faceAtMoment = 'happy_face.png';
      return 'Sad';
    } else {
      faceAtMoment = 'sady_face.png';
      return 'Very Sad';
    }
  }

  String detectOther(smileProb) {
    if (smileProb > 0.7) {
      faceAtMoment = 'happy_face.png';
      return 'Happy';
    } else if (smileProb > 0.3) {
      faceAtMoment = 'happy_face.png';
      return 'Normal';
    } else if (smileProb > 0.08) {
      faceAtMoment = 'happy_face.png';
      return 'Fear';
    } else {
      faceAtMoment = 'sady_face.png';
      return 'Disgust';
    }
  }

  String happyFeature(smileProb) {
    if (smileProb > 0.7) {
      faceAtMoment = 'happy_face.png';
      return 'High';
    } else if (smileProb > 0.55) {
      faceAtMoment = 'happy_face.png';
      return 'Moderate';
    } else {
      faceAtMoment = 'sady_face.png';
      return 'Low';
    }
  }

  String otherFeature(smileProb) {
    if (smileProb > 0.2) {
      faceAtMoment = 'sady_face.png';
      return 'Low';
    } else {
      faceAtMoment = 'happy_face.png';
      return 'High';
    }
  }
}
