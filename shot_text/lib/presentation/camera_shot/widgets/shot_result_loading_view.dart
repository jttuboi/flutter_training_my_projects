import 'package:flutter/material.dart';
import 'package:shot_text/presentation/camera_shot/widgets/shot_result_background.dart';

class ShotResultLoadingView extends StatelessWidget {
  const ShotResultLoadingView({required this.imagePath, Key? key}) : super(key: key);

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShotResultBackground(imagePath: imagePath, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height),
        const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ],
    );
  }
}
