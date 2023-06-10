import 'dart:io';

import 'package:flutter/material.dart';

import 'c_default_avatar.dart';

class CAvatar extends StatelessWidget {
  const CAvatar(this.avatarPath, {this.size = 100, super.key});

  final String? avatarPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (avatarPath == null || avatarPath!.isEmpty) {
      return CDefaultAvatar(size: size);
    }

    return Image.file(File(avatarPath!), width: size, height: size);
  }
}
