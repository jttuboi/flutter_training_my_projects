import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

class Open {
  const Open._();

  static Future<OpenResult> pdf({required String phonePath}) async {
    return OpenFilex.open(phonePath, type: 'application/pdf');
  }

  static Future<String> pickPdf() async {
    final f = await FilePicker.platform.pickFiles(allowedExtensions: ['pdf'], type: FileType.custom);
    return f?.paths.first ?? '';
  }
}
