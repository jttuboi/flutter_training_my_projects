import 'package:flutter/material.dart';
import 'package:shot_text/presentation/camera_shot/pages/camera_shot_page.dart';
import 'package:shot_text/presentation/camera_shot/pages/shot_result_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (settings.name == CameraShotPage.routeName) {
          return CameraShotPage.route();
        }
        if (settings.name == ShotResultPage.routeName) {
          return ShotResultPage.route(imagePath: settings.arguments! as String);
        }
        return null;
      },
    );
  }
}
