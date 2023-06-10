part of 'contact_cubit.dart';

abstract class ContactState with EquatableMixin {
  const ContactState({
    required this.isNew,
    required this.originalContact,
    this.temporaryAvatarPath,
    this.successMessage = '',
    this.failure = const Failure.noFailure(),
  });

  final bool isNew;
  final Contact originalContact;
  final String? temporaryAvatarPath;
  final String successMessage;
  final Failure failure;

  @override
  List<Object?> get props => [isNew, originalContact, temporaryAvatarPath, successMessage, failure];

  bool get isEdit => !isNew;
}

class ContactInitial extends ContactState {
  const ContactInitial({super.isNew = true, super.originalContact = const Contact.noData(), required super.temporaryAvatarPath});
}

class ContactLoading extends ContactState {
  ContactLoading(ContactState previousState)
      : super(isNew: previousState.isNew, originalContact: previousState.originalContact, temporaryAvatarPath: previousState.temporaryAvatarPath);
}

class ContactLoaded extends ContactState {
  ContactLoaded(ContactState previousState, {super.successMessage = '', super.temporaryAvatarPath})
      : super(isNew: previousState.isNew, originalContact: previousState.originalContact);
}

class ContactMessageReseted extends ContactState {
  ContactMessageReseted(ContactState previousState)
      : super(isNew: previousState.isNew, originalContact: previousState.originalContact, temporaryAvatarPath: previousState.temporaryAvatarPath);
}

class ContactFailure extends ContactState {
  ContactFailure(ContactState previousState, {required super.failure})
      : super(isNew: previousState.isNew, originalContact: previousState.originalContact, temporaryAvatarPath: previousState.temporaryAvatarPath);
}

class ContactValidationFailure extends ContactState {
  ContactValidationFailure(ContactState previousState, {required super.failure})
      : super(isNew: previousState.isNew, originalContact: previousState.originalContact, temporaryAvatarPath: previousState.temporaryAvatarPath);
}
