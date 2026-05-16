import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Storage Service using Cloudinary (free tier)
/// Replaces Firebase Storage to avoid billing
///
/// Setup:
/// 1. Go to https://cloudinary.com/ → Sign up (free)
/// 2. From Dashboard, copy your Cloud Name
/// 3. Go to Settings → Upload → Add upload preset → Set to "Unsigned"
/// 4. Update the constants below with your values
class StorageService {
  // ═══ CLOUDINARY CONFIG ═══
  // TODO: Replace with your Cloudinary credentials
  static const String cloudName = 'dycudtwkj';
  static const String uploadPreset = 'safenet-ai';

  static String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  final ImagePicker _imagePicker = ImagePicker();

  // ── Pick Image from Camera ──
  Future<File?> pickFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return image != null ? File(image.path) : null;
  }

  // ── Pick Image from Gallery ──
  Future<File?> pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return image != null ? File(image.path) : null;
  }

  // ── Upload to Cloudinary ──
  Future<String?> _uploadToCloudinary({
    required File file,
    required String folder,
    String? publicId,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      if (publicId != null) {
        request.fields['public_id'] = publicId;
      }

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        final secureUrl = jsonData['secure_url'] as String;
        // ignore: avoid_print
        print('Cloudinary upload success: $secureUrl');
        return secureUrl;
      } else {
        // ignore: avoid_print
        print('Cloudinary upload failed: ${jsonData['error']?['message'] ?? responseData}');
        return null;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Upload error: $e');
      return null;
    }
  }

  // ── Upload ID Proof ──
  Future<String?> uploadIdProof(String userId, File file) async {
    return _uploadToCloudinary(
      file: file,
      folder: 'safenet_ai/id_proofs',
      publicId: 'id_$userId',
    );
  }

  // ── Upload Selfie ──
  Future<String?> uploadSelfie(String userId, File file) async {
    return _uploadToCloudinary(
      file: file,
      folder: 'safenet_ai/selfies',
      publicId: 'selfie_$userId',
    );
  }

  // ── Upload Generic Image ──
  Future<String?> uploadImage(File file, String folder) async {
    return _uploadToCloudinary(
      file: file,
      folder: 'safenet_ai/$folder',
    );
  }
}
