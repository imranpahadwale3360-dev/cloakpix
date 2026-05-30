enum VaultItemType { photo, video }

class VaultItem {
  const VaultItem({
    required this.id,
    required this.type,
    required this.encryptedPath,
    required this.originalName,
    required this.createdAt,
    this.deletedAt,
    this.mimeType,
    this.sizeBytes = 0,
    this.cloudPath,
    this.syncedAt,
  });

  final String id;
  final VaultItemType type;
  final String encryptedPath;
  final String originalName;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String? mimeType;
  final int sizeBytes;
  final String? cloudPath;
  final DateTime? syncedAt;

  bool get isDeleted => deletedAt != null;

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type.name,
        'encrypted_path': encryptedPath,
        'original_name': originalName,
        'created_at': createdAt.millisecondsSinceEpoch,
        'deleted_at': deletedAt?.millisecondsSinceEpoch,
        'mime_type': mimeType,
        'size_bytes': sizeBytes,
        'cloud_path': cloudPath,
        'synced_at': syncedAt?.millisecondsSinceEpoch,
      };

  factory VaultItem.fromMap(Map<String, Object?> map) {
    return VaultItem(
      id: map['id']! as String,
      type: VaultItemType.values.byName(map['type']! as String),
      encryptedPath: map['encrypted_path']! as String,
      originalName: map['original_name']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
      deletedAt: map['deleted_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['deleted_at']! as int),
      mimeType: map['mime_type'] as String?,
      sizeBytes: (map['size_bytes'] as int?) ?? 0,
      cloudPath: map['cloud_path'] as String?,
      syncedAt: map['synced_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['synced_at']! as int),
    );
  }
}
