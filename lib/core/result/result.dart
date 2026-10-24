import 'package:equatable/equatable.dart';

/// Clean Architecture functional [Result] pattern for robust error handling.
/// Eliminates runtime exceptions and untyped error maps.
sealed class Result<T> extends Equatable {
  const Result();

  /// Returns true if this instance represents a successful outcome.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this instance represents a failure outcome.
  bool get isFailure => this is Failure<T>;

  /// Extracts data if successful, returns null on failure.
  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => null,
      };

  /// Extracts error message if failure, returns null on success.
  String? get errorMessageOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final message) => message,
      };

  /// Pattern matching handler for both outcomes.
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Object? error, StackTrace? stackTrace) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Failure<T>(:final message, :final error, :final stackTrace) =>
        failure(message, error, stackTrace),
    };
  }

  /// Transforms the successful data value using [transform].
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => Success<R>(transform(data)),
      Failure<T>(:final message, :final error, :final stackTrace) =>
        Failure<R>(message, error: error, stackTrace: stackTrace),
    };
  }
}

/// Represents a successful computation yielding [data].
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

/// Represents a failed computation with a descriptive [message].
final class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const Failure(
    this.message, {
    this.error,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, error];
}
