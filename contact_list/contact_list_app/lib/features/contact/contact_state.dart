part of 'contact_cubit.dart';

abstract class ContactState with EquatableMixin {
  const ContactState({this.failure = const Failure.noFailure()});

  final Failure failure;

  @override
  List<Object> get props => [failure];
}

class ContactInitial extends ContactState {
  const ContactInitial();
}

class ContactAdded extends ContactState {
  const ContactAdded();
}

class ContactEdited extends ContactState {
  const ContactEdited();
}

class ContactRemoved extends ContactState {
  const ContactRemoved();
}

class ContactLoading extends ContactState {
  const ContactLoading();
}

class ContactValidationFailure extends ContactState {
  const ContactValidationFailure({required super.failure});
}

class ContactResetFailure extends ContactState {
  const ContactResetFailure();
}

class ContactFailure extends ContactState {
  const ContactFailure({required super.failure});
}
