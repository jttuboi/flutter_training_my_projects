import 'package:flutter/material.dart';

import '../../utils/route_name.dart';
import 'screen_with_menu.dart';

class PlScreen extends StatelessWidget {
  const PlScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return ScreenWithMenu(RouteName.pl, contents: [
      Text(userId),
    ]);
  }
}
