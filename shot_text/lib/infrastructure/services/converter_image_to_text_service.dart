import 'dart:io';

import 'package:shot_text/domain/services/converter_image_to_text_service.dart';

class ConverterImageToTextService implements IConverterImageToTextService {
  //TODO implementar conversor de imagnes aqui aqui
  @override
  Future<String> convert(File image) {
    return Future.value('');
  }
}
