import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:shot_text/domain/services/converter_image_to_text_service.dart';
import 'package:shot_text/domain/services/share_service.dart';
import 'package:shot_text/domain/services/url_launcher_service.dart';
import 'package:shot_text/infrastructure/services/converter_image_to_text_service.dart';
import 'package:shot_text/infrastructure/services/share_service.dart';
import 'package:shot_text/infrastructure/services/url_launcher_service.dart';

part 'shot_result_state.dart';

class ShotResultCubit extends Cubit<ShotResultState> {
  ShotResultCubit({
    required this.imagePath,
    IConverterImageToTextService? conversorImageToTextService,
    IUrlLauncherService? urlLauncherService,
    IShareService? shareService,
  })  : conversorImageToTextService = conversorImageToTextService ?? ConverterImageToTextService(),
        urlLauncherService = urlLauncherService ?? UrlLauncherService(),
        shareService = shareService ?? ShareService(),
        super(ShotResultInitial(imagePath)) {
    loaded();
  }

  final String imagePath;
  final IConverterImageToTextService conversorImageToTextService;
  final IUrlLauncherService urlLauncherService;
  final IShareService shareService;

  Future<void> loaded() async {
    emit(ShotResultTextLoading(imagePath));

    final text = await conversorImageToTextService.convert(File(imagePath));

    if (text.isEmpty) {
      emit(ShotResultTextNotFound(imagePath));
    } else {
      emit(ShotResultTextReady(imagePath, text));
    }
  }

  Future<void> urlOpened() async {
    if (state is ShotResultTextReady) {
      await urlLauncherService.launch((state as ShotResultTextReady).text);
    }
  }

  Future<void> textCopied() async {
    if (state is ShotResultTextReady) {
      await Clipboard.setData(ClipboardData(text: (state as ShotResultTextReady).text));
      emit(ShotResultTextCopiedReady((state as ShotResultTextReady).imagePath, (state as ShotResultTextReady).text));
    }
  }

  Future<void> textShared() async {
    if (state is ShotResultTextReady) {
      await shareService.share((state as ShotResultTextReady).text);
    }
  }
}
