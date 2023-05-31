import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../entities/contact.dart';
import '../../failures/internet_unavailable_failure.dart';
import '../../failures/unknown_failure.dart';
import '../../repositories/contact_repository.dart';
import '../../services/open/open.dart';
import '../../services/result/failure.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit({ContactRepository? repository})
      : _repository = repository ?? ContactRepository(),
        super(const ContactsInitial());

  final ContactRepository _repository;

  Future<void> init() async {
    await _getAll(page: 0);
  }

  // a diferença entre update e refresh list é que o primeiro mantém a página, o segundo pega a lista do zero
  Future<void> updateList() async {
    await _repository.synchronize();

    await _getAll(perPage: false, page: state.currentPage);
  }

  Future<void> refreshList() async {
    emit(const ContactsInitial());

    await _repository.synchronize();

    await _getAll(page: 0);
  }

  Future<void> getMore() async {
    emit(ContactsListLoading(state));

    final nextPage = state.currentPage + 1;

    await _getAll(oldContacts: state.contacts, page: nextPage);
  }

  Future<void> deleteAll() async {
    (await _repository.deleteAll()).result((_) {
      emit(const ContactsLoaded(contacts: <Contact>[], currentPage: 0, isLastPage: true));
    }, (failure) {
      emit(ContactsFailure(state, failure: failure));
      emit(ContactsResetFailure(state));
    });
  }

  Future<void> setAvatarPhonePath(Contact contact, {required String avatarPhonePath}) async {
    final index = state.contacts.indexWhere((c) => c.id == contact.id);
    final contactUpdated = contact.copyWith(avatarPhonePath: avatarPhonePath);

    // atualiza o database
    await _repository.edit(contactUpdated);

    // atualizar a tela
    state.contacts[index] = contactUpdated;
    emit(ContactsLoaded(contacts: state.contacts, currentPage: state.currentPage, isLastPage: state.isLastPage));
  }

  Future<void> openDocument(Contact contact) async {
    if (contact.documentPhonePath.isNotEmpty) {
      await Open.pdf(phonePath: contact.documentPhonePath);
      return;
    }

    await DefaultCacheManager().getSingleFile(contact.documentUrl).then((file) async {
      final documentPhonePath = file.path;
      final index = state.contacts.indexWhere((c) => c.id == contact.id);
      final contactUpdated = contact.copyWith(documentPhonePath: documentPhonePath);

      // atualiza o database
      await _repository.edit(contactUpdated);

      // atualizar a tela
      state.contacts[index] = contactUpdated;
      emit(ContactsLoaded(contacts: state.contacts, currentPage: state.currentPage, isLastPage: state.isLastPage));

      await Open.pdf(phonePath: documentPhonePath);
    }).onError((error, stackTrace) {
      if (error is SocketException) {
        emit(ContactsFailure(state, failure: const InternetUnavailableFailure()));
      } else {
        emit(ContactsFailure(state, failure: const UnknownFailure()));
      }
      emit(ContactsResetFailure(state));
    });
  }

  Future<void> _getAll({List<Contact> oldContacts = const <Contact>[], bool perPage = true, required int page}) async {
    await Future.delayed(const Duration(seconds: 4));
    (await _repository.getAll(page: page, perPage: perPage)).result((r) {
      emit(ContactsLoaded(contacts: [...oldContacts, ...r.contacts], currentPage: page, isLastPage: r.meta.isLastPage));
    }, (failure) {
      emit(ContactsFailure(state, failure: failure));
      emit(ContactsResetFailure(state));
    });
  }

  Future<void> delete(Contact contact) async {
    (await _repository.delete(contact)).result((_) {
      updateList();
    }, (failure) {
      emit(ContactsFailure(state, failure: failure));
      emit(ContactsResetFailure(state));
    });
  }
}
