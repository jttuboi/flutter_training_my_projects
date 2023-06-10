import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../entities/contact.dart';
import '../entities/meta.dart';
import '../entities/sync_status.dart';
import '../services/connection_checker/connection_checker.dart';
import '../services/result/result.dart';
import '../utils/logger.dart';
import 'contact_offline_datasource.dart';
import 'contact_online_datasource.dart';
import 'dio_contact_online_datasource.dart';

class ContactRepository {
  ContactRepository(
      {IMyConnectionChecker? connectionChecker, IContactOnlineDataSource? onlineDataSource, IContactOfflineDataSource? offlineDataSource})
      : _connectionChecker = connectionChecker ?? GetIt.I.get<IMyConnectionChecker>(),
        _onlineDataSource = onlineDataSource ?? DioContactOnlineDataSource(),
        _offlineDataSource = offlineDataSource ?? GetIt.I.get<IContactOfflineDataSource>();

  final IMyConnectionChecker _connectionChecker;
  final IContactOnlineDataSource _onlineDataSource;
  final IContactOfflineDataSource _offlineDataSource;

  ///
  /// synchronize local database with server
  ///
  Future<Result<void>> synchronize() async {
    Logger.pContactRepository('synchronize');

    if (!_connectionChecker.hasConnection) {
      // não retorna erro, pois o problema é a falta de internet e não um erro em si.
      // como é necessário internet para sincronizar, não há o pq tentar sincronizar.
      return const SuccessOk();
    }

    if (await _offlineDataSource.isListSynchronized()) {
      return const SuccessOk();
    }

    return (await _offlineDataSource.getAllDesynchronized()).result(
      (contactsDesynchronized) async {
        // se não tem nenhum dado na base local ao sincronizar, pode ser uma nova instalação do app ou alguma coisa inconsistente q limpou a base local,
        // então é necessário verificar se o servidor tem os dados para pegar o "backup".
        if (contactsDesynchronized.isEmpty) {
          return (await _onlineDataSource.hasDataToSynchronize()).result(
            (hasDataToSynchronize) async {
              // se tem data para sincronizar, então recupera tudo e sincroniza com a base local
              if (hasDataToSynchronize) {
                return (await _onlineDataSource.getAll()).result(
                  (contactsSynchronized) async {
                    return (await _offlineDataSource.synchronizeList(contactsSynchronized)).result(
                      (_) => const SuccessOk(),
                      (failure) async => Fail(failure),
                    );
                  },
                  (failure) async => Fail(failure),
                );
              }

              // se não tem data para sincronizar, então apenas finaliza a sincronização
              return (await _offlineDataSource.synchronizeList(const [])).result(
                (_) async => const SuccessOk(),
                (failure) async => Fail(failure),
              );
            },
            (failure) async => Fail(failure),
          );
        }

        return (await _onlineDataSource.synchronize(contactsDesynchronized)).result(
          (contactsSynchronized) async {
            return (await _offlineDataSource.synchronizeList(contactsSynchronized)).result(
              (_) async => const SuccessOk(),
              (failure) async => Fail(failure),
            );
          },
          (failure) async => Fail(failure),
        );
      },
      (failure) async => Fail(failure),
    );
  }

  ///
  /// get partial contacts using page
  ///
  Future<Result<({List<Contact> contacts, Meta meta})>> getAll({bool perPage = true, int page = 0}) async {
    Logger.pContactRepository('getAll', {'perPage': perPage, 'page': page});

    return _offlineDataSource.getAll(perPage: perPage, page: page);
  }

  ///
  /// set to delete all contacts from local database to late synchronize
  /// obs: after call this, must call synchronize
  ///
  Future<Result<void>> deleteAll() async {
    Logger.pContactRepository('deleteAll');

    // refaz os contatos para status removed
    return (await _offlineDataSource.setToRemoveAll(
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.removed,
    ))
        .result(
      (_) async {
        // desincroniza para posteriormente atualizar a lista através da sincronização
        await _offlineDataSource.desynchronizeList();

        return const SuccessOk();
      },
      (failure) => Fail(failure),
    );
  }

  ///
  /// add contact to local database to late synchronize
  /// obs: after call this, must call synchronize
  ///
  Future<Result<void>> add(Contact contact) async {
    Logger.pContactRepository('add', {'contact': contact});

    // refaz o contact para status added
    final contactToAdd = (contact.id.isEmpty || contact.createdAt == null || contact.syncStatus != SyncStatus.added)
        ? contact.copyWith(id: const Uuid().v4(), createdAt: DateTime.now(), syncStatus: SyncStatus.added)
        : contact;

    // salva o contato na base local
    return (await _offlineDataSource.create(contactToAdd)).result(
      (_) async {
        // desincroniza para posteriormente atualizar a lista através da sincronização
        await _offlineDataSource.desynchronizeList();

        return const SuccessOk();
      },
      (failure) async => Fail(failure),
    );
  }

  ///
  /// update contact to local database to late synchronize
  /// obs: after call this, must call synchronize
  ///
  Future<Result<void>> edit(Contact contact) async {
    Logger.pContactRepository('edit', {'contact': contact});

    // refazer o contact para status updated
    final contactToUpdate = (contact.updatedAt == null || contact.syncStatus != SyncStatus.updated)
        ? contact.copyWith(updatedAt: DateTime.now(), syncStatus: SyncStatus.updated)
        : contact;

    // atualiza o contato na base local
    return (await _offlineDataSource.update(contactToUpdate)).result(
      (_) async {
        // desincroniza para posteriormente atualizar a lista através da sincronização
        await _offlineDataSource.desynchronizeList();

        return const SuccessOk();
      },
      (failure) async => Fail(failure),
    );
  }

  ///
  /// set to delete contact from local database to late synchronize
  /// obs: after call this, must call synchronize
  ///
  Future<Result<void>> delete(Contact contact) async {
    Logger.pContactRepository('delete', {'contact': contact});

    // refazer o contact para status removed
    final contactToRemove = (contact.updatedAt == null || contact.syncStatus != SyncStatus.removed)
        ? contact.copyWith(updatedAt: DateTime.now(), syncStatus: SyncStatus.removed)
        : contact;

    // deleta o contato na base local
    return (await _offlineDataSource.setRemove(contactToRemove)).result(
      (_) async {
        // desincroniza para posteriormente atualizar a lista através da sincronização
        await _offlineDataSource.desynchronizeList();

        return const SuccessOk();
      },
      (failure) async => Fail(failure),
    );
  }
}
