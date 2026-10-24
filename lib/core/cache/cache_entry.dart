/// Container for cached values supporting optional Time-To-Live (TTL) expiration.
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final Duration? ttl;

  CacheEntry({
    required this.value,
    DateTime? createdAt,
    this.ttl,
  }) : createdAt = createdAt ?? DateTime.now();

  /// True if entry has exceeded its configured time-to-live.
  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().isAfter(createdAt.add(ttl!));
  }

  Map<String, dynamic> toJson(Object? Function(T value) valueToJson) {
    return {
      'value': valueToJson(value),
      'createdAt': createdAt.toIso8601String(),
      'ttlMilliseconds': ttl?.inMilliseconds,
    };
  }

  static CacheEntry<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(dynamic raw) valueFromJson,
  ) {
    return CacheEntry<T>(
      value: valueFromJson(json['value']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      ttl: json['ttlMilliseconds'] != null
          ? Duration(milliseconds: json['ttlMilliseconds'] as int)
          : null,
    );
  }
}
