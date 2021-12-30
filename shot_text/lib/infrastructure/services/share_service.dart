import 'package:share_plus/share_plus.dart';
import 'package:shot_text/domain/services/share_service.dart';

class ShareService implements IShareService {
  @override
  Future<void> share(String text) async {
    await Share.share(text);
  }

//TODO remove this
  //   void _onShare(BuildContext context) async {
  //   // A builder is used to retrieve the context immediately
  //   // surrounding the ElevatedButton.
  //   //
  //   // The context's `findRenderObject` returns the first
  //   // RenderObject in its descendent tree when it's not
  //   // a RenderObjectWidget. The ElevatedButton's RenderObject
  //   // has its position and size after it's built.
  //   final box = context.findRenderObject() as RenderBox?;

  //   if (imagePaths.isNotEmpty) {
  //     await Share.shareFiles(imagePaths,
  //         text: text,
  //         subject: subject,
  //         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  //   } else {
  //     await Share.share(text,
  //         subject: subject,
  //         sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  //   }
  // }
}
