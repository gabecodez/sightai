import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

Future<String?> saveImage(Uint8List bytes) async {
  await ImageGallerySaverPlus.saveImage(bytes);
  return null;
}