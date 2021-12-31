import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidgetAndroid extends StatelessWidget {
  const AppWidgetAndroid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp().modular(); //added by extension
  }
}
