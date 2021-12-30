import 'dart:io';

import 'package:shot_text/domain/services/converter_image_to_text_service.dart';

class ConverterImageToTextService implements IConverterImageToTextService {
  //TODO implementar conversor de imagnes aqui aqui
  @override
  Future<String> convert(File image) {
    return Future.value('');
  }
}
// https://developers.google.com/ml-kit/guides
// https://developers.google.com/ml-kit/vision/text-recognition/android
// https://github.com/bharat-biradar/Google-Ml-Kit-plugin (tentar implementar sem a ajuda de packages externos)
// https://pub.dev/packages/google_ml_kit

// https://pub.dev/packages/flutter_tesseract_ocr