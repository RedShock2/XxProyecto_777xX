import 'dart:io';
import 'package:image_picker/image_picker.dart';

enum ImageSourceType { camera, gallery }

class CameraService {
  static final CameraService _instance = CameraService._();
  factory CameraService() => _instance;
  CameraService._();

  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(ImageSourceType source) async {
    final xFile = await _picker.pickImage(
      source: source == ImageSourceType.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  Future<File?> takeProfilePhoto() => pickImage(ImageSourceType.camera);
  Future<File?> pickFromGallery() => pickImage(ImageSourceType.gallery);

  Future<File?> captureTeamPhoto() => pickImage(ImageSourceType.camera);
}
