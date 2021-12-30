import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shot_text/presentation/camera_shot/cubit/shot_result_cubit.dart';
import 'package:shot_text/presentation/camera_shot/widgets/shot_icon_button.dart';
import 'package:shot_text/presentation/camera_shot/widgets/shot_result_background.dart';
import 'package:shot_text/presentation/camera_shot/widgets/shot_result_loading_view.dart';
import 'package:shot_text/presentation/camera_shot/widgets/shot_text_button.dart';

class ShotResultPage extends StatelessWidget {
  const ShotResultPage({required this.imagePath, Key? key}) : super(key: key);

  static String routeName = '/result';

  static Route route({required String imagePath}) {
    return MaterialPageRoute(builder: (context) => ShotResultPage(imagePath: imagePath));
  }

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShotResultCubit(imagePath: imagePath),
      child: const ShotResultView(),
    );
  }
}

class ShotResultView extends StatelessWidget {
  const ShotResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShotResultCubit, ShotResultState>(
      listener: (context, state) {
        if (state is ShotResultTextCopiedReady) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard.')));
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Text copied to clipboard.'),
                content: const Text('Do you want to exit?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
                  // OBS: SystemNavigator.pop() não funfa no iOS
                  const TextButton(onPressed: SystemNavigator.pop, child: Text('Yes')),
                ],
              );
            },
          );
        }
      },
      builder: (context, state) {
        if (state is ShotResultTextNotFound) {
          return ShotResultErrorView(imagePath: state.imagePath);
        }
        if (state is ShotResultTextLoading) {
          return ShotResultLoadingView(imagePath: state.imagePath);
        }
        return ShotResultReadyView(imagePath: state.imagePath);
      },
    );
  }
}

class ShotResultReadyView extends StatelessWidget {
  const ShotResultReadyView({required this.imagePath, Key? key}) : super(key: key);

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Container(),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () => print('== settings'),
              icon: const Icon(Icons.more_vert_rounded),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            ShotResultBackground(imagePath: imagePath, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShotIconButton(
                        tooltip: 'Open in browser',
                        icon: Icons.open_in_browser_rounded,
                        onPressed: () => context.read<ShotResultCubit>().urlOpened(),
                      ),
                      const SizedBox(width: 8),
                      ShotIconButton(
                        tooltip: 'Copy to clipboard',
                        icon: Icons.content_copy_rounded,
                        onPressed: () => context.read<ShotResultCubit>().textCopied(),
                      ),
                      const SizedBox(width: 8),
                      ShotIconButton(
                        tooltip: 'Share to',
                        icon: Icons.share_rounded,
                        onPressed: () => context.read<ShotResultCubit>().textShared(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ShotTextButton(
                    text: 'Try another shot.',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class ShotResultErrorView extends StatelessWidget {
  const ShotResultErrorView({required this.imagePath, Key? key}) : super(key: key);

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => print('== settings'),
            icon: const Icon(Icons.more_vert_rounded),
          )
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ShotResultBackground(imagePath: imagePath, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShotTextButton(
                  text: 'Text not found.\nTry another shot.',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
