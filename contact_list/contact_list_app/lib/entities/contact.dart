import 'package:equatable/equatable.dart';

import 'sync_status.dart';

class Contact with EquatableMixin {
  const Contact({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.documentUrl,
    this.avatarPhonePath = '',
    this.documentPhonePath = '',
    this.createdAt,
    this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  const Contact.noData()
      : id = '',
        name = '',
        avatarUrl = '',
        documentUrl = '',
        avatarPhonePath = '',
        documentPhonePath = '',
        createdAt = null,
        updatedAt = null,
        syncStatus = SyncStatus.synced;

  final String id;
  final String name;
  final String avatarUrl;
  final String documentUrl;
  final String avatarPhonePath;
  final String documentPhonePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SyncStatus syncStatus;

  @override
  List<Object?> get props => [id, name, avatarUrl, documentUrl, avatarPhonePath, documentPhonePath, createdAt, updatedAt, syncStatus];

  @override
  bool? get stringify => true;

  static Contact fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map[columnId] ?? '',
      name: map[columnName] ?? '',
      avatarUrl: map[columnAvatarUrl] ?? '',
      documentUrl: map[columnDocumentUrl] ?? '',
      avatarPhonePath: map[columnAvatarPhonePath] ?? '',
      documentPhonePath: map[columnDocumentPhonePath] ?? '',
      createdAt: DateTime.tryParse(map[columnCreatedAt] ?? ''),
      updatedAt: DateTime.tryParse(map[columnUpdatedAt] ?? ''),
      syncStatus: SyncStatus.fromString(map[columnSyncStatus]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      columnId: id,
      columnName: name,
      columnAvatarUrl: avatarUrl,
      columnDocumentUrl: documentUrl,
      columnAvatarPhonePath: avatarPhonePath,
      columnDocumentPhonePath: documentPhonePath,
      columnCreatedAt: createdAt?.toIso8601String(),
      columnUpdatedAt: updatedAt?.toIso8601String(),
      columnSyncStatus: syncStatus.name,
    };
  }

  static const tableName = 'contact';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnAvatarUrl = 'avatar_url';
  static const columnDocumentUrl = 'document_url';
  static const columnAvatarPhonePath = 'avatar_phone_path';
  static const columnDocumentPhonePath = 'document_phone_path';
  static const columnCreatedAt = 'created_at';
  static const columnUpdatedAt = 'updated_at';
  static const columnSyncStatus = 'sync_status';

  bool get hasData => id.isNotEmpty; //this == const Contact.noData();

  bool get hasNotData => id.isEmpty; //this != const Contact.noData();

  Contact copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? documentUrl,
    String? avatarPhonePath,
    String? documentPhonePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      avatarPhonePath: avatarPhonePath ?? this.avatarPhonePath,
      documentPhonePath: documentPhonePath ?? this.documentPhonePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  String toString() {
    return 'Contact('
        'id: $id, '
        'name: $name, '
        'avatarUrl: $avatarUrl, '
        'documentUrl: $documentUrl, '
        'avatarPhonePath: $avatarPhonePath, '
        'documentPhonePath: $documentPhonePath, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'syncStatus: $syncStatus'
        ')';
  }

  String toShortString() {
    return 'Contact('
        'id: ...${id.substring(id.length - 4)}, '
        'name: $name, '
        'aUrl: ${avatarUrl.split('/').last}, '
        'dUrl: ${documentUrl.split('/').last}, '
        'aPth: ${avatarPhonePath.split('/').last}, '
        'dPth: ${documentPhonePath.split('/').last}, '
        'crAt: ${createdAt?.toShortString()}, '
        'upAt: ${updatedAt?.toShortString()}, '
        'sySt: ${syncStatus.name}'
        ')';
  }
}

extension _DateTimeExtension on DateTime {
  String toShortString() => '${day.toPadLeftZero()}/${month.toPadLeftZero()}/${year - 2000} ${hour.toPadLeftZero()}:${minute.toPadLeftZero()}';
}

extension _IntExtension on int {
  String toPadLeftZero() => toString().padLeft(2, '0');
}
