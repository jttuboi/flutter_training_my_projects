import 'package:shot_text/domain/services/url_launcher_service.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class UrlLauncherService implements IUrlLauncherService {
  @override
  Future<void> launch(String url) async {
    if (await url_launcher.canLaunch(url)) {
      await url_launcher.launch(url);
    }
//TODO remove this
    // String? encodeQueryParameters(Map<String, String> params) {
    //   return params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    // }

    // final Uri emailLaunchUri = Uri(
    //   scheme: 'mailto',
    //   path: 'smith@example.com',
    //   query: encodeQueryParameters(<String, String>{'subject': 'Example Subject & Symbols are allowed!'}),
    // );

    // launch(emailLaunchUri.toString());

    // Warning: For any scheme other than http or https, you should use the query parameter and the encodeQueryParameters function shown
    //above rather than Uri's queryParameters constructor argument, due to a bug in the way Uri encodes query parameters. Using
    //queryParameters will result in spaces being converted to + in many cases.

    // Handling missing URL receivers
    // A particular mobile device may not be able to receive all supported URL schemes. For example, a tablet may not have a cellular
    //radio and thus no support for launching a URL using the sms scheme, or a device may not have an email app and thus no support for
    //launching a URL using the mailto scheme.

    // We recommend checking which URL schemes are supported using the canLaunch in most cases. If the canLaunch method returns false,
    //as a best practice we suggest adjusting the application UI so that the unsupported URL is never triggered; for example, if the mailto
    //scheme is not supported, a UI button that would have sent feedback email could be changed to instead open a web-based feedback form using an https URL.
  }
}
