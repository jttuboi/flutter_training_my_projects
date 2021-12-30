import 'dart:io';

import 'package:flutter/material.dart';

class ShotResultBackground extends StatelessWidget {
  const ShotResultBackground({required this.imagePath, required this.width, required this.height, Key? key}) : super(key: key);

  final String imagePath;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return Container(color: Colors.black, width: width, height: height);
    }
    return Image.file(File(imagePath), width: width, height: height);
  }
}
