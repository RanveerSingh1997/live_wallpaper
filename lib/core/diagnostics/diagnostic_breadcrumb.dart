/// Immutable breadcrumb record capturing runtime diagnostics and lifecycle transitions.
class DiagnosticBreadcrumb {
  final DateTime timestamp;
  final String category;
  final String message;
  final Map<String, dynamic>? metadata;

  const DiagnosticBreadcrumb({
    required this.timestamp,
    required this.category,
    required this.message,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'message': message,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory DiagnosticBreadcrumb.fromJson(Map<String, dynamic> json) {
    return DiagnosticBreadcrumb(
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      category: json['category'] as String? ?? 'GENERAL',
      message: json['message'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  String toFormattedString() {
    final timeStr = timestamp.toIso8601String().substring(11, 19);
    final metaStr = metadata != null && metadata!.isNotEmpty ? ' $metadata' : '';
    return '[$timeStr] [$category] $message$metaStr';
  }
}
