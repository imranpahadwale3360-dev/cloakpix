enum SecurityEventType { failedPin, breakInPhoto, biometricFailure, syncWarning }

class SecurityEvent {
  const SecurityEvent({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.message,
    this.encryptedMediaPath,
  });

  final String id;
  final SecurityEventType type;
  final DateTime createdAt;
  final String message;
  final String? encryptedMediaPath;

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type.name,
        'created_at': createdAt.millisecondsSinceEpoch,
        'message': message,
        'encrypted_media_path': encryptedMediaPath,
      };

  factory SecurityEvent.fromMap(Map<String, Object?> map) {
    return SecurityEvent(
      id: map['id']! as String,
      type: SecurityEventType.values.byName(map['type']! as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
      message: map['message']! as String,
      encryptedMediaPath: map['encrypted_media_path'] as String?,
    );
  }
}
