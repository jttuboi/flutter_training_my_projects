import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import '../entities/contact.dart';
import '../entities/meta.dart';
import '../entities/sync_status.dart';
import '../failures/unknown_failure.dart';
import '../services/result/result.dart';
import '../utils/constants.dart';
import 'contact_offline_datasource.dart';

class SqfliteContactOfflineDataSource implements IContactOfflineDataSource {
  SqfliteContactOfflineDataSource({Database? database, FlutterSecureStorage? keyValueDatabase})
      : _database = database ?? GetIt.I.get<Database>(),
        _keyValueDatabase = keyValueDatabase ?? GetIt.I.get<FlutterSecureStorage>();

  static const _contactsSynchronizedKey = 'contacts_synchronized_key';

  final Database _database;
  final FlutterSecureStorage _keyValueDatabase;

  @override
  Future<Result<({List<Contact> contacts, Meta meta})>> getAll({bool perPage = true, int page = 0}) async {
    try {
      final totalEntries =
          Sqflite.firstIntValue(await _database.rawQuery('SELECT COUNT(*) FROM ${Contact.tableName} WHERE ${Contact.columnSyncStatus}<>?', [
        SyncStatus.removed.name,
      ]));
      if (totalEntries == null || totalEntries == 0) {
        return const Success((
          contacts: [],
          meta: Meta.empty(),
        ));
      }

      // ignora os contatos com status removed
      final entries = perPage
          ? await _database.rawQuery('SELECT * FROM ${Contact.tableName} WHERE ${Contact.columnSyncStatus}<>? LIMIT ? OFFSET ?', [
              SyncStatus.removed.name,
              qtyContactsPerPage,
              qtyContactsPerPage * page,
            ])
          : await _database.rawQuery('SELECT * FROM ${Contact.tableName} WHERE ${Contact.columnSyncStatus}<>? LIMIT ?', [
              SyncStatus.removed.name,
              qtyContactsPerPage * (page + 1),
            ]);

      final totalPages = (totalEntries / qtyContactsPerPage).ceil();
      final isLastPage = (page + 1) == totalPages;

      return Success((
        contacts: entries.map<Contact>((query) => Contact.fromMap(query)).toList(),
        meta: Meta(
          previousPage: page - 1,
          currentPage: page,
          nextPage: isLastPage ? -1 : page + 1,
          totalPages: totalPages,
          totalEntries: totalEntries,
        )
      ));
    } catch (e, s) {
      return Fail(UnknownFailure(error: e, stackTrace: s));
    }
  }

  @override
  Future<Result<void>> setToRemoveAll({required DateTime? updatedAt, required SyncStatus syncStatus}) async {
    try {
      await _database.rawUpdate(
        'UPDATE ${Contact.tableName} SET ${Contact.columnUpdatedAt}=?, ${Contact.columnSyncStatus}=?',
        [
          if (updatedAt == null) null else updatedAt.toIso8601String(),
          syncStatus.name,
        ],
      );

      return const SuccessOk();
    } catch (e, s) {
      return Fail(UnknownFailure(error: e, stackTrace: s));
    }
  }

  @override
  Future<Result<Contact>> create(Contact contactToAdd) async {
    try {
      await _database.rawInsert(
          'INSERT INTO ${Contact.tableName}(${Contact.columnId}, ${Contact.columnName}, ${Contact.columnAvatarUrl}, ${Contact.columnDocumentUrl}, ${Contact.columnAvatarPhonePath}, ${Contact.columnDocumentPhonePath}, ${Contact.columnCreatedAt}, ${Contact.columnUpdatedAt}, ${Contact.columnSyncStatus}) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            contactToAdd.id,
            contactToAdd.name,
            contactToAdd.avatarUrl,
            contactToAdd.documentUrl,
            contactToAdd.avatarPhonePath,
            contactToAdd.documentPhonePath,
            if (contactToAdd.createdAt == null) null else contactToAdd.createdAt!.toIso8601String(),
            if (contactToAdd.updatedAt == null) null else contactToAdd.updatedAt!.toIso8601String(),
            contactToAdd.syncStatus.name,
          ]);

      return Success(contactToAdd);
    } catch (e, s) {
      return Fail(UnknownFailure(error: e, stackTrace: s));
    }
  }

  @override
  Future<Result<Contact>> update(Contact contactToEdit) async {
    try {
      await _database.rawUpdate(
        'UPDATE ${Contact.tableName} SET ${Contact.columnId}=?, ${Contact.columnName}=?, ${Contact.columnAvatarUrl}=?, ${Contact.columnDocumentUrl}=?, ${Contact.columnAvatarPhonePath}=?, ${Contact.columnDocumentPhonePath}=?, ${Contact.columnCreatedAt}=?, ${Contact.columnUpdatedAt}=?, ${Contact.columnSyncStatus}=? WHERE ${Contact.columnId}=?',
        [
          contactToEdit.id,
          contactToEdit.name,
          contactToEdit.avatarUrl,
          contactToEdit.documentUrl,
          contactToEdit.avatarPhonePath,
          contactToEdit.documentPhonePath,
          if (contactToEdit.createdAt == null) null else contactToEdit.createdAt!.toIso8601String(),
          if (contactToEdit.updatedAt == null) null else contactToEdit.updatedAt!.toIso8601String(),
          contactToEdit.syncStatus.name,
          contactToEdit.id,
        ],
      );

      return Success(contactToEdit);
    } catch (e, s) {
      return Fail(UnknownFailure(error: e, stackTrace: s));
    }
  }

  @override
  Future<Result<void>> setRemove({required String id, required DateTime? updatedAt, required SyncStatus syncStatus}) async {
    try {
      await _database.rawUpdate(
        'UPDATE ${Contact.tableName} SET ${Contact.columnUpdatedAt}=?, ${Contact.columnSyncStatus}=? WHERE ${Contact.columnId}=?',
        [
          if (updatedAt == null) null else updatedAt.toIso8601String(),
          syncStatus.name,
          id,
        ],
      );

      return const SuccessOk();
    } catch (e, s) {
      return Fail(UnknownFailure(error: e, stackTrace: s));
    }
  }

  @override
  Future<Result<List<Contact>>> getAllDesynchronized() async {
    try {
      final entries = await _database.rawQuery('SELECT * FROM ${Contact.tableName} WHERE ${Contact.columnSyncStatus}<>?', [
        SyncStatus.synced.name,
      ]);

      return Success(entries.map<Contact>((entry) => Contact.fromMap(entry)).toList());
    } catch (e, s) {
      return Fail(UnknownFailure(error: e, stackTrace: s));
    }
  }

  @override
  Future<Result<void>> synchronizeList(List<Contact> contactsToSynchronize) async {
    try {
      await _keyValueDatabase.write(key: _contactsSynchronizedKey, value: true.toString());

      final batch = _database.batch();
      for (final contact in contactsToSynchronize) {
        if (contact.syncStatus.isRemoved) {
          batch.rawDelete('DELETE FROM ${Contact.tableName} WHERE ${Contact.columnId}=?', [
            contact.id,
          ]);
        }

        if (contact.syncStatus.isAdded) {
          final qty = Sqflite.firstIntValue(await _database.rawQuery('SELECT COUNT(*) FROM ${Contact.tableName} WHERE ${Contact.columnId}=?', [
            contact.id,
          ]));
          final hasEntry = qty != null && qty == 1;

          if (hasEntry) {
            batch.rawUpdate(
              'UPDATE ${Contact.tableName} SET ${Contact.columnId}=?, ${Contact.columnName}=?, ${Contact.columnAvatarUrl}=?, ${Contact.columnDocumentUrl}=?, ${Contact.columnAvatarPhonePath}=?, ${Contact.columnDocumentPhonePath}=?, ${Contact.columnCreatedAt}=?, ${Contact.columnUpdatedAt}=?, ${Contact.columnSyncStatus}=? WHERE ${Contact.columnId}=?',
              [
                contact.id,
                contact.name,
                contact.avatarUrl,
                contact.documentUrl,
                contact.avatarPhonePath,
                contact.documentPhonePath,
                if (contact.createdAt == null) null else contact.createdAt!.toIso8601String(),
                if (contact.updatedAt == null) null else contact.updatedAt!.toIso8601String(),
                SyncStatus.synced.name,
                contact.id,
              ],
            );
          } else {
            batch.rawInsert(
                'INSERT INTO ${Contact.tableName}(${Contact.columnId}, ${Contact.columnName}, ${Contact.columnAvatarUrl}, ${Contact.columnDocumentUrl}, ${Contact.columnAvatarPhonePath}, ${Contact.columnDocumentPhonePath}, ${Contact.columnCreatedAt}, ${Contact.columnUpdatedAt}, ${Contact.columnSyncStatus}) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
                [
                  contact.id,
                  contact.name,
                  contact.avatarUrl,
                  contact.documentUrl,
                  contact.avatarPhonePath,
                  contact.documentPhonePath,
                  if (contact.createdAt == null) null else contact.createdAt!.toIso8601String(),
                  if (contact.updatedAt == null) null else contact.updatedAt!.toIso8601String(),
                  SyncStatus.synced.name,
                ]);
          }
        }

        batch.rawUpdate(
          'UPDATE ${Contact.tableName} SET ${Contact.columnId}=?, ${Contact.columnName}=?, ${Contact.columnAvatarUrl}=?, ${Contact.columnDocumentUrl}=?, ${Contact.columnAvatarPhonePath}=?, ${Contact.columnDocumentPhonePath}=?, ${Contact.columnCreatedAt}=?, ${Contact.columnUpdatedAt}=?, ${Contact.columnSyncStatus}=? WHERE ${Contact.columnId}=?',
          [
            contact.id,
            contact.name,
            contact.avatarUrl,
            contact.documentUrl,
            contact.avatarPhonePath,
            contact.documentPhonePath,
            if (contact.createdAt == null) null else contact.createdAt!.toIso8601String(),
            if (contact.updatedAt == null) null else contact.updatedAt!.toIso8601String(),
            SyncStatus.synced.name,
            contact.id,
          ],
        );
      }
      await batch.commit();

      return const SuccessOk();
    } catch (e, s) {
      return Fail(UnknownFailure(error: e, stackTrace: s));
    }
  }

  @override
  Future<void> desynchronizeList() async {
    try {
      await _keyValueDatabase.write(key: _contactsSynchronizedKey, value: false.toString());
    } catch (e) {
      //
    }
  }

  @override
  Future<bool> isListSynchronized() async {
    try {
      final value = await _keyValueDatabase.read(key: _contactsSynchronizedKey);

      // quando inicia o app, o valor deve iniciar desincronizado com o servidor
      if (value == null) {
        await desynchronizeList();
        return false;
      }

      return value == true.toString();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isListNotSynchronized() async {
    return !(await isListSynchronized());
  }

  @override
  Future<void> printContacts({bool isShort = false}) async {
    final entries = await _database.rawQuery('SELECT * FROM ${Contact.tableName}');
    log('[');
    for (final contact in entries.map<Contact>((entry) => Contact.fromMap(entry))) {
      log(isShort ? contact.toShortString() : contact.toString());
    }

    log(']');
  }
}
