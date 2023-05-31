import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class DefaultWidgetForCacheManager extends StatefulWidget {
  const DefaultWidgetForCacheManager({
    required this.url,
    this.fileKey,
    this.hasDownloadProgress = false,
    required this.setLoadingWidget,
    required this.setErrorWidget,
    required this.setShowFileWidget,
    super.key,
  });

  final String url;
  final String? fileKey;
  final bool hasDownloadProgress;

  final Widget Function(double? progress)? setLoadingWidget;
  final Widget Function(Object? error)? setErrorWidget;
  final Widget Function(FileInfo? fileInfo) setShowFileWidget;

  @override
  State<DefaultWidgetForCacheManager> createState() => _DefaultWidgetForCacheManagerState();
}

class _DefaultWidgetForCacheManagerState extends State<DefaultWidgetForCacheManager> {
  Stream<FileResponse>? _fileStream;

  @override
  void initState() {
    super.initState();
    _fileStream = DefaultCacheManager().getFileStream(widget.url, key: widget.fileKey, withProgress: widget.hasDownloadProgress);
  }

  @override
  void dispose() {
    _fileStream = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _fileStream,
        builder: (_, snapshot) {
          // error
          if (snapshot.hasError) {
            return (widget.setErrorWidget == null) ? Text(snapshot.error.toString()) : widget.setErrorWidget!.call(snapshot.error);
          } //
          // init
          else if (!snapshot.hasData) {
            return (widget.setLoadingWidget == null) ? const CircularProgressIndicator() : widget.setLoadingWidget!(null);
          } //
          // download
          else if (snapshot.data is DownloadProgress) {
            final downloadProgress = snapshot.data! as DownloadProgress;
            return (widget.setLoadingWidget == null)
                ? CircularProgressIndicator(value: downloadProgress.progress)
                : widget.setLoadingWidget!(downloadProgress.progress);
          }

          final fileInfo = snapshot.data! as FileInfo;
          return widget.setShowFileWidget(fileInfo);
        });
  }
}
