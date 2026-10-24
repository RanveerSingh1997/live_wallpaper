import 'package:equatable/equatable.dart';
import '../core/core.dart';

/// Clean Architecture abstract [UseCase] contract.
/// Represents a single application business rule or user transaction.
/// Follows the Command Pattern and Single Responsibility Principle (SRP).
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Parameter placeholder for use cases requiring no input arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
