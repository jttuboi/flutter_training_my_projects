import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../entities/contact.dart';
import '../../failures/empty_name_validation_failure.dart';
import '../../services/open/open.dart';
import '../../utils/strings.dart';
import '../../widgets/after_first_frame_mixin.dart';
import '../../widgets/c_attach_file.dart';
import '../../widgets/c_button.dart';
import '../../widgets/c_icon_button.dart';
import '../../widgets/c_snack_bar_mixin.dart';
import '../../widgets/c_text_field.dart';
import 'contact_cubit.dart';

mixin ContactDialogMixin {
  /// - true se for salvo
  /// - false se clicou em voltar ou fechou a dialog sem salvar os dados
  Future<bool> showContactDialog(BuildContext context, {Contact contact = const Contact.noData()}) async {
    return await showDialog(
        context: context,
        useSafeArea: true,
        barrierDismissible: false,
        builder: (_) {
          return ContactDialog(contact: contact);
        });
  }
}

class ContactDialog extends StatelessWidget {
  ContactDialog({Contact contact = const Contact.noData(), ContactCubit? contactCubit, super.key})
      : _contact = contact,
        _contactCubit = contactCubit ?? ContactCubit();

  final Contact _contact;
  final ContactCubit _contactCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactCubit>(
      create: (_) => _contactCubit,
      child: ContactView(contact: _contact),
    );
  }
}

class ContactView extends StatefulWidget {
  const ContactView({this.contact = const Contact.noData(), super.key});

  final Contact contact;

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> with AfterFirstFrameMixin, CSnackBarMixin {
  final _avatarPathNotifier = ValueNotifier<String>('');
  final _nameController = TextEditingController();
  final _documentPathNotifier = ValueNotifier<String>('');

  @override
  FutureOr<void> afterFirstFrame(BuildContext context) {
    if (widget.contact.hasData) {
      _avatarPathNotifier.value = widget.contact.avatarPhonePath;
      _nameController.text = widget.contact.name;
      _documentPathNotifier.value = widget.contact.documentPhonePath;
    }
  }

  @override
  void dispose() {
    _avatarPathNotifier.dispose();
    _nameController.dispose();
    _documentPathNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          await _onBackPressed(context);
          return false;
        },
        child: AlertDialog(
          iconPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Stack(
            children: [
              Positioned(
                top: 8,
                right: 8,
                child: CIconButton(icon: Icons.close_outlined, onPressed: () async => _onBackPressed(context)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 16),
                child: BlocConsumer<ContactCubit, ContactState>(
                  listener: (_, state) {
                    if (state is ContactFailure) {
                      showSnackBarForError(context, text: state.failure.messageForUser);
                    } else if (state is ContactAdded) {
                      showSnackBarForSuccess(context, text: Strings.contactAddMessage);
                    } else if (state is ContactEdited) {
                      showSnackBarForSuccess(context, text: Strings.contactEditMessage);
                    } else if (state is ContactRemoved) {
                      showSnackBarForSuccess(context, text: Strings.contactDeleteMessage);
                    }
                  },
                  builder: (_, state) {
                    return Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(),
                          Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.person, size: 120, color: Colors.grey),
                          ),
                          if (widget.contact.hasData) CButton.icon(Icons.delete, onPressed: () async => _delete(context)) else const SizedBox(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CTextField(
                          title: Strings.contactName,
                          textController: _nameController,
                          validationMessageError: (state is ContactValidationFailure && state.failure == const EmptyNameValidationFailure())
                              ? state.failure.messageForUser
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CAttachFile(
                          title: Strings.contactDocument,
                          hint: Strings.contactDocumentHint,
                          icon: Icons.picture_as_pdf_outlined,
                          filePathNotifier: _documentPathNotifier,
                          onPressed: _pickPdf,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _nameController,
                          builder: (_, name, __) {
                            return CButton(
                              Strings.contactSave,
                              onPressed: name.text.isNotEmpty ? () async => _save(context) : null,
                            );
                          }),
                    ]);
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _pickPdf() async {
    final filePath = await Open.pickPdf();
    _documentPathNotifier.value = filePath;
  }

  Future<void> _save(BuildContext context) async {
    FocusScope.of(context).unfocus();
    await context
        .read<ContactCubit>()
        .save(
          contact: widget.contact.copyWith(
            name: _nameController.text,
            avatarPhonePath: _avatarPathNotifier.value,
            documentPhonePath: _documentPathNotifier.value,
          ),
          isNew: widget.contact.hasNotData,
        )
        .then((_) async {
      await _onEntityModified(context);
    });
  }

  Future<void> _delete(BuildContext context) async {
    await context.read<ContactCubit>().delete(contact: widget.contact).then((_) async {
      await _onEntityModified(context);
    });
  }

  Future<void> _onBackPressed(BuildContext context) async {
    Navigator.pop(context, false);
  }

  Future<void> _onEntityModified(BuildContext context) async {
    Navigator.pop(context, true);
  }
}
