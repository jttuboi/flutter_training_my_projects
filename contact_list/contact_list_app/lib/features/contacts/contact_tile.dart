import 'package:flutter/material.dart';

import '../../entities/contact.dart';
import '../../utils/strings.dart';
import '../../utils/typedefs.dart';
import '../../widgets/c_button.dart';
import '../../widgets/c_default_avatar.dart';
import '../../widgets/c_snack_bar_mixin.dart';
import '../../widgets/default_widget_for_cache_manager.dart';
import '../contact/contact_dialog_mixin.dart';
import 'data_tile.dart';

class ContactTile extends StatefulWidget {
  const ContactTile(this.contact,
      {this.initialShowData = false,
      required this.onEdit,
      required this.onDelete,
      required this.onOpenDocument,
      required this.onSetAvatarPhonePath,
      super.key});

  final Contact contact;
  final bool initialShowData;
  final FunctionCallback onEdit;
  final FunctionCallback onDelete;
  final FunctionCallback onOpenDocument;
  final FunctionFileInfoCallback onSetAvatarPhonePath;

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile> with ContactDialogMixin, CSnackBarMixin {
  late final ValueNotifier<bool> _showData;

  @override
  void initState() {
    super.initState();
    _showData = ValueNotifier<bool>(widget.initialShowData);
  }

  @override
  void dispose() {
    _showData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showData,
        builder: (_, showData, child) {
          return DataTile(widget.contact, showData: showData, child: child!);
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          DefaultWidgetForCacheManager(
            url: widget.contact.avatarUrl,
            setLoadingWidget: (progress) {
              return const CDefaultAvatar();
            },
            setErrorWidget: (error) {
              return const CDefaultAvatar();
            },
            setShowFileWidget: (fileInfo) {
              if (fileInfo == null) {
                return const CDefaultAvatar();
              }
              widget.onSetAvatarPhonePath(fileInfo);
              return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Image.file(fileInfo.file, width: 100, height: 100),
                const SizedBox(width: 4),
              ]);
            },
          ),
          const SizedBox(width: 4),
          Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${widget.contact.name} (${widget.contact.syncStatus.name})'),
            const SizedBox(height: 4),
            if (widget.contact.documentUrl.isNotEmpty)
              CButton(Strings.contactsOpenDocument(widget.contact.documentPhonePath), onPressed: widget.onOpenDocument),
            const SizedBox(height: 4),
            CButton('Show data', onPressed: () {
              _showData.value = !_showData.value;
            }),
          ]),
          const Spacer(),
          Column(children: [
            CButton.icon(Icons.edit, onPressed: widget.onEdit),
            const SizedBox(height: 16),
            CButton.icon(Icons.delete, onPressed: widget.onDelete),
          ]),
        ]),
      ),
    );
  }
}
