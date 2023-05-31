import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../entities/contact.dart';
import '../../failures/empty_name_validation_failure.dart';
import '../../repositories/contact_repository.dart';
import '../../services/result/failure.dart';

part 'contact_state.dart';

class ContactCubit extends Cubit<ContactState> {
  ContactCubit({ContactRepository? repository})
      : _repository = repository ?? ContactRepository(),
        super(const ContactInitial());

  final ContactRepository _repository;

  Future<void> save({required Contact contact, required bool isNew}) async {
    if (contact.name.trim().isEmpty) {
      emit(const ContactValidationFailure(failure: EmptyNameValidationFailure()));
      return;
    }

    emit(const ContactLoading());

    if (isNew) {
      (await _repository.add(contact)).result((_) {
        emit(const ContactAdded());
      }, (failure) {
        emit(ContactFailure(failure: failure));
        emit(const ContactResetFailure());
      });
    } else {
      (await _repository.edit(contact)).result((_) {
        emit(const ContactEdited());
      }, (failure) {
        emit(ContactFailure(failure: failure));
        emit(const ContactResetFailure());
      });
    }
  }

  Future<void> delete({required Contact contact}) async {
    emit(const ContactLoading());

    (await _repository.delete(contact)).result((_) {
      emit(const ContactRemoved());
    }, (failure) {
      emit(ContactFailure(failure: failure));
      emit(const ContactResetFailure());
    });
  }
}
