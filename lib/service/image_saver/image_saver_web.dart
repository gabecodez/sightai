import 'dart:html' as html;
import 'dart:typed_data';

Future<String?> saveImage(Uint8List bytes) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..setAttribute('download', 'captured_image.jpg')
    ..click();
    
  return url;
}